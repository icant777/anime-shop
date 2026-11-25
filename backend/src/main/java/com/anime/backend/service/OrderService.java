package com.anime.backend.service;

import com.anime.backend.common.BizException;
import com.anime.backend.entity.*;
import com.anime.backend.mapper.*;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.*;

/**
 * 下单服务：核心事务链路
 * 校验库存 -> 扣减库存(带 stock>=数量 条件) -> 写库存流水 -> 建订单+明细 -> 发积分
 * 任何一步失败，@Transactional 全部回滚。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrderMapper orderMapper;
    private final OrderItemMapper orderItemMapper;
    private final GoodsMapper goodsMapper;
    private final GoodsConditionRelMapper skuMapper;
    private final StockLogMapper stockLogMapper;
    private final PointService pointService;

    /** 下单请求里的一行 */
    public static class OrderLine {
        public Long skuId;
        public Integer quantity;
    }

    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> placeOrder(Long userId, List<Map<String, Object>> items,
                                          String receiverName, String receiverPhone, String receiverAddress) {
        if (items == null || items.isEmpty()) {
            throw new BizException("购物车不能为空");
        }

        BigDecimal total = BigDecimal.ZERO;
        List<Object[]> prepared = new ArrayList<>(); // [sku, goods, qty, lineTotal]

        // 1. 先校验所有商品 + 库存
        for (Map<String, Object> item : items) {
            Long skuId = ((Number) item.get("skuId")).longValue();
            int qty = ((Number) item.get("quantity")).intValue();
            if (qty <= 0) {
                throw new BizException("购买数量必须大于 0");
            }
            GoodsConditionRel sku = skuMapper.selectById(skuId);
            if (sku == null || (sku.getStatus() != null && sku.getStatus() != 1)) {
                throw new BizException("SKU 不存在或已下架：" + skuId);
            }
            if (sku.getStock() == null || sku.getStock() < qty) {
                throw new BizException("库存不足：" + sku.getSkuCode() + " 仅剩 "
                        + (sku.getStock() == null ? 0 : sku.getStock()));
            }
            Goods goods = goodsMapper.selectById(sku.getGoodsId());
            if (goods == null) {
                throw new BizException("商品不存在");
            }
            BigDecimal lineTotal = sku.getPrice().multiply(BigDecimal.valueOf(qty));
            total = total.add(lineTotal);
            prepared.add(new Object[]{sku, goods, qty, lineTotal});
        }

        // 2. 建订单主表
        Orders order = new Orders();
        order.setOrderNo("OD" + System.currentTimeMillis() + UUID.randomUUID().toString().substring(0, 6).toUpperCase());
        order.setUserId(userId);
        // merchant_id 从第一个商品取（本简化版一单一个店铺；多店铺应拆单）
        Goods firstGoods = (Goods) prepared.get(0)[1];
        order.setMerchantId(firstGoods.getMerchantId());
        order.setOrderType(1);                       // 1 现货
        order.setTotalAmount(total);
        order.setDepositPaid(BigDecimal.ZERO);
        order.setBalanceAmount(total);
        order.setBalancePaid(total);
        order.setStatus(2);                          // 2 已付全款待发货
        order.setReceiverName(receiverName);
        order.setReceiverPhone(receiverPhone);
        order.setReceiverAddress(receiverAddress);
        order.setPayTime(LocalDateTime.now());
        orderMapper.insert(order);

        // 3. 逐个扣库存 + 写流水 + 建明细
        for (Object[] row : prepared) {
            GoodsConditionRel sku = (GoodsConditionRel) row[0];
            Goods goods = (Goods) row[1];
            int qty = (Integer) row[2];
            BigDecimal lineTotal = (BigDecimal) row[3];

            // 条件更新：WHERE id=? AND stock>=qty，防止超卖
            LambdaUpdateWrapper<GoodsConditionRel> uw = new LambdaUpdateWrapper<>();
            uw.eq(GoodsConditionRel::getId, sku.getId())
              .ge(GoodsConditionRel::getStock, qty)
              .setSql("stock = stock - " + qty)
              .setSql("locked_stock = locked_stock + " + qty);
            int rows = skuMapper.update(null, uw);
            if (rows == 0) {
                throw new BizException("库存不足，下单失败：" + sku.getSkuCode());
            }

            // 库存流水：change_type=2 下单锁定，数量负数
            StockLog logRec = new StockLog();
            logRec.setSkuId(sku.getId());
            logRec.setChangeType(2);
            logRec.setChangeQuantity(-qty);
            logRec.setBeforeStock(sku.getStock());
            logRec.setAfterStock(sku.getStock() - qty);
            logRec.setBizType("order");
            logRec.setBizNo(order.getOrderNo());
            logRec.setOperatorId(userId);
            logRec.setRemark("下单锁定");
            stockLogMapper.insert(logRec);

            // 订单明细
            OrderItem item = new OrderItem();
            item.setOrderId(order.getId());
            item.setGoodsId(goods.getId());
            item.setGoodsConditionRelId(sku.getId());
            item.setGoodsName(goods.getGoodsName());
            item.setIpId(goods.getIpId());
            item.setCharacterId(goods.getCharacterId());
            item.setUnitPrice(sku.getPrice());
            item.setQuantity(qty);
            item.setDepositAmount(BigDecimal.ZERO);
            item.setTotalAmount(lineTotal);
            orderItemMapper.insert(item);
        }

        // 4. 消费送积分：每 1 元 1 分（向下取整）
        int points = total.setScale(0, java.math.RoundingMode.DOWN).intValue();
        if (points > 0) {
            pointService.change(userId, 2, points, "order", order.getOrderNo(), "消费 " + total + " 元送积分");
        }

        Map<String, Object> result = new HashMap<>();
        result.put("orderId", order.getId());
        result.put("orderNo", order.getOrderNo());
        result.put("totalAmount", total);
        result.put("pointsEarned", points);
        return result;
    }

    /** 我的订单列表 */
    public List<Orders> myOrders(Long userId) {
        return orderMapper.selectList(new LambdaQueryWrapper<Orders>()
                .eq(Orders::getUserId, userId)
                .orderByDesc(Orders::getId));
    }

    /** 订单详情（含明细） */
    public Map<String, Object> detail(Long userId, Long orderId) {
        Orders order = orderMapper.selectById(orderId);
        if (order == null || !order.getUserId().equals(userId)) {
            throw new BizException("订单不存在");
        }
        List<OrderItem> items = orderItemMapper.selectList(
                new LambdaQueryWrapper<OrderItem>().eq(OrderItem::getOrderId, orderId));
        Map<String, Object> result = new HashMap<>();
        result.put("order", order);
        result.put("items", items);
        return result;
    }
}
