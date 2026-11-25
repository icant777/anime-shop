package com.anime.backend.service;

import com.anime.backend.common.BizException;
import com.anime.backend.entity.*;
import com.anime.backend.mapper.*;
import com.anime.backend.util.Md5Util;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.*;

/**
 * 管理端服务：商品、SKU、用户的增删改查。
 * 删除一律软删除（商品 deleted=1，用户 status=3），避免外键约束报错误删关联数据。
 */
@Service
@RequiredArgsConstructor
public class AdminService {

    private final GoodsMapper goodsMapper;
    private final GoodsConditionRelMapper skuMapper;
    private final GoodsCategoryMapper categoryMapper;
    private final UserMapper userMapper;
    private final IpMapper ipMapper;
    private final com.anime.backend.mapper.IpCharacterMapper ipCharacterMapper;
    private final MerchantMapper merchantMapper;
    private final ConditionLevelMapper conditionMapper;

    // ============ 商品管理 ============

    /** 全量商品（含下架/删除），管理后台用 */
    public List<Goods> allGoods() {
        return goodsMapper.selectList(new LambdaQueryWrapper<Goods>().orderByDesc(Goods::getId));
    }

    /** 商品详情（含SKU，含已删除） */
    public Map<String, Object> goodsDetail(Long id) {
        Goods g = goodsMapper.selectById(id);
        if (g == null) {
            throw new BizException("商品不存在");
        }
        List<GoodsConditionRel> skus = skuMapper.selectList(
                new LambdaQueryWrapper<GoodsConditionRel>().eq(GoodsConditionRel::getGoodsId, id));
        return Map.of("goods", g, "skus", skus);
    }

    /**
     * 添加商品（SPU）。校验 ip / merchant / category 外键存在。
     * 必填：goodsCode, goodsName, ipId, merchantId；其余有默认值。
     */
    @Transactional(rollbackFor = Exception.class)
    public Goods addGoods(Map<String, Object> p) {
        String code = str(p, "goodsCode");
        String name = str(p, "goodsName");
        Long ipId = lng(p, "ipId");
        Long merchantId = lng(p, "merchantId");
        if (code == null || name == null || ipId == null || merchantId == null) {
            throw new BizException("必填：goodsCode、goodsName、ipId、merchantId");
        }
        if (ipMapper.selectById(ipId) == null) {
            throw new BizException("IP 不存在，id=" + ipId);
        }
        if (merchantMapper.selectById(merchantId) == null) {
            throw new BizException("商家不存在，id=" + merchantId);
        }
        Long categoryId = lng(p, "categoryId");
        if (categoryId != null && categoryMapper.selectById(categoryId) == null) {
            throw new BizException("分类不存在，id=" + categoryId);
        }
        Long dup = goodsMapper.selectCount(new LambdaQueryWrapper<Goods>().eq(Goods::getGoodsCode, code));
        if (dup != null && dup > 0) {
            throw new BizException("商品编码已存在：" + code);
        }

        // character_id 是 NOT NULL 且有外键；没传就取该 IP 下第一个角色
        Long characterId = lng(p, "characterId");
        if (characterId == null) {
            List<IpCharacter> chars = ipCharacterMapper.selectList(
                    new LambdaQueryWrapper<IpCharacter>()
                            .eq(IpCharacter::getIpId, ipId)
                            .orderByAsc(IpCharacter::getSortNo));
            if (chars.isEmpty()) {
                throw new BizException("该 IP 还没有角色，请先添加角色或显式传 characterId");
            }
            characterId = chars.get(0).getId();
        } else if (ipCharacterMapper.selectById(characterId) == null) {
            throw new BizException("角色不存在，id=" + characterId);
        }

        Goods g = new Goods();
        g.setGoodsCode(code);
        g.setGoodsName(name);
        g.setIpId(ipId);
        g.setCharacterId(characterId);
        g.setMerchantId(merchantId);
        g.setCategory(str(p, "category"));
        g.setCategoryId(categoryId);
        g.setSaleMode(intOr(p, "saleMode", 1));
        g.setMinPrice(dec(p, "minPrice"));
        g.setDeposit(decOr(p, "deposit", BigDecimal.ZERO));
        g.setImages(str(p, "images"));
        g.setAttributes(str(p, "attributes"));
        g.setDetail(str(p, "detail"));
        g.setPushStatus(intOr(p, "pushStatus", 0));
        g.setStatus(intOr(p, "status", 1));
        g.setAuditStatus(intOr(p, "auditStatus", 1));
        g.setDeleted(0);
        goodsMapper.insert(g);
        return g;
    }

    /** 修改商品：只更新传入的字段 */
    @Transactional(rollbackFor = Exception.class)
    public Goods updateGoods(Long id, Map<String, Object> p) {
        Goods g = goodsMapper.selectById(id);
        if (g == null) {
            throw new BizException("商品不存在");
        }
        if (p.containsKey("goodsName")) g.setGoodsName(str(p, "goodsName"));
        if (p.containsKey("category")) g.setCategory(str(p, "category"));
        if (p.containsKey("categoryId")) g.setCategoryId(lng(p, "categoryId"));
        if (p.containsKey("minPrice")) g.setMinPrice(dec(p, "minPrice"));
        if (p.containsKey("detail")) g.setDetail(str(p, "detail"));
        if (p.containsKey("images")) g.setImages(str(p, "images"));
        if (p.containsKey("status")) g.setStatus(intOr(p, "status", g.getStatus()));
        if (p.containsKey("auditStatus")) g.setAuditStatus(intOr(p, "auditStatus", g.getAuditStatus()));
        goodsMapper.updateById(g);
        return g;
    }

    /** 软删除商品：deleted=1，并下架全部 SKU（status=2） */
    @Transactional(rollbackFor = Exception.class)
    public void deleteGoods(Long id) {
        Goods g = goodsMapper.selectById(id);
        if (g == null) {
            throw new BizException("商品不存在");
        }
        g.setDeleted(1);
        g.setStatus(2);
        goodsMapper.updateById(g);
        skuMapper.update(null, new com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper<GoodsConditionRel>()
                .eq(GoodsConditionRel::getGoodsId, id)
                .set(GoodsConditionRel::getStatus, 2));
    }

    /** 恢复商品（撤销软删除）：deleted=0 */
    @Transactional(rollbackFor = Exception.class)
    public void restoreGoods(Long id) {
        Goods g = goodsMapper.selectById(id);
        if (g == null) {
            throw new BizException("商品不存在");
        }
        g.setDeleted(0);
        g.setStatus(1);
        goodsMapper.updateById(g);
        skuMapper.update(null, new com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper<GoodsConditionRel>()
                .eq(GoodsConditionRel::getGoodsId, id)
                .set(GoodsConditionRel::getStatus, 1));
    }

    // ============ SKU 管理 ============

    /** 给商品添加 SKU。必填 goodsId, skuCode, price；品相默认取第一个 */
    public GoodsConditionRel addSku(Map<String, Object> p) {
        Long goodsId = lng(p, "goodsId");
        String skuCode = str(p, "skuCode");
        BigDecimal price = dec(p, "price");
        if (goodsId == null || skuCode == null || price == null) {
            throw new BizException("必填：goodsId、skuCode、price");
        }
        if (goodsMapper.selectById(goodsId) == null) {
            throw new BizException("商品不存在，id=" + goodsId);
        }
        Long dup = skuMapper.selectCount(new LambdaQueryWrapper<GoodsConditionRel>()
                .eq(GoodsConditionRel::getSkuCode, skuCode));
        if (dup != null && dup > 0) {
            throw new BizException("SKU 编码已存在：" + skuCode);
        }
        Long condId = lng(p, "conditionLevelId");
        if (condId == null) {
            List<ConditionLevel> levels = conditionMapper.selectList(null);
            condId = levels.isEmpty() ? 1L : levels.get(0).getId();
        }
        GoodsConditionRel sku = new GoodsConditionRel();
        sku.setGoodsId(goodsId);
        sku.setConditionLevelId(condId);
        sku.setSkuCode(skuCode);
        sku.setPrice(price);
        sku.setDeposit(decOr(p, "deposit", BigDecimal.ZERO));
        sku.setStock(intOr(p, "stock", 0));
        sku.setLockedStock(0);
        sku.setStatus(intOr(p, "status", 1));
        skuMapper.insert(sku);
        return sku;
    }

    /** 改 SKU：库存、价格、状态 */
    public GoodsConditionRel updateSku(Long id, Map<String, Object> p) {
        GoodsConditionRel sku = skuMapper.selectById(id);
        if (sku == null) {
            throw new BizException("SKU 不存在");
        }
        if (p.containsKey("price")) sku.setPrice(dec(p, "price"));
        if (p.containsKey("stock")) sku.setStock(intOr(p, "stock", sku.getStock()));
        if (p.containsKey("status")) sku.setStatus(intOr(p, "status", sku.getStatus()));
        skuMapper.updateById(sku);
        return sku;
    }

    /** 删 SKU（有库存锁定或已被下单引用时不许删） */
    public void deleteSku(Long id) {
        GoodsConditionRel sku = skuMapper.selectById(id);
        if (sku == null) {
            throw new BizException("SKU 不存在");
        }
        if (sku.getLockedStock() != null && sku.getLockedStock() > 0) {
            throw new BizException("该 SKU 有锁定库存，不能删除");
        }
        skuMapper.deleteById(id);
    }

    /** 按商品查 SKU */
    public List<GoodsConditionRel> skusOf(Long goodsId) {
        return skuMapper.selectList(new LambdaQueryWrapper<GoodsConditionRel>()
                .eq(GoodsConditionRel::getGoodsId, goodsId).orderByAsc(GoodsConditionRel::getId));
    }

    // ============ 用户管理 ============

    /** 全量用户（不返回密码散列） */
    public List<User> allUsers() {
        List<User> users = userMapper.selectList(new LambdaQueryWrapper<User>().orderByDesc(User::getId));
        users.forEach(u -> u.setPasswordHash(null));
        return users;
    }

    /** 添加用户（密码 MD5 存） */
    public User addUser(Map<String, Object> p) {
        String username = str(p, "username");
        String password = str(p, "password");
        if (username == null || password == null) {
            throw new BizException("必填：username、password");
        }
        Long dup = userMapper.selectCount(new LambdaQueryWrapper<User>().eq(User::getUsername, username));
        if (dup != null && dup > 0) {
            throw new BizException("用户名已存在：" + username);
        }
        User u = new User();
        u.setUsername(username);
        u.setPasswordHash(Md5Util.md5(password));
        u.setPhone(str(p, "phone"));
        u.setEmail(str(p, "email"));
        u.setRealnameStatus(intOr(p, "realnameStatus", 0));
        u.setStatus(intOr(p, "status", 1));
        userMapper.insert(u);
        u.setPasswordHash(null);
        return u;
    }

    /** 修改用户：不改 username（登录名）和密码；改密码走单独接口 */
    public User updateUser(Long id, Map<String, Object> p) {
        User u = userMapper.selectById(id);
        if (u == null) {
            throw new BizException("用户不存在");
        }
        if (p.containsKey("phone")) u.setPhone(str(p, "phone"));
        if (p.containsKey("email")) u.setEmail(str(p, "email"));
        if (p.containsKey("avatarUrl")) u.setAvatarUrl(str(p, "avatarUrl"));
        if (p.containsKey("realnameStatus")) u.setRealnameStatus(intOr(p, "realnameStatus", u.getRealnameStatus()));
        if (p.containsKey("status")) u.setStatus(intOr(p, "status", u.getStatus()));
        userMapper.updateById(u);
        u.setPasswordHash(null);
        return u;
    }

    /** 重置密码（管理端） */
    public void resetPassword(Long id, String newPassword) {
        User u = userMapper.selectById(id);
        if (u == null) {
            throw new BizException("用户不存在");
        }
        if (newPassword == null || newPassword.isBlank()) {
            throw new BizException("新密码不能为空");
        }
        u.setPasswordHash(Md5Util.md5(newPassword));
        userMapper.updateById(u);
    }

    /** 注销用户：status=3（软删除，不物理删，避免外键报错） */
    public void deleteUser(Long id) {
        User u = userMapper.selectById(id);
        if (u == null) {
            throw new BizException("用户不存在");
        }
        u.setStatus(3);
        userMapper.updateById(u);
    }

    // ============ 基础数据下拉（添加商品时用） ============

    public Map<String, Object> basics() {
        return Map.of(
                "ips", ipMapper.selectList(new LambdaQueryWrapper<Ip>().eq(Ip::getStatus, 1)),
                "merchants", merchantMapper.selectList(new LambdaQueryWrapper<Merchant>().eq(Merchant::getStatus, 1)),
                "conditions", conditionMapper.selectList(null),
                "categories", categoryMapper.selectList(new LambdaQueryWrapper<GoodsCategory>()
                        .eq(GoodsCategory::getStatus, 1).orderByAsc(GoodsCategory::getLevel).orderByAsc(GoodsCategory::getSortNo))
        );
    }

    // ============ 参数转换小工具 ============
    private static String str(Map<String, Object> p, String key) {
        Object v = p.get(key);
        return v == null ? null : v.toString();
    }

    private static Long lng(Map<String, Object> p, String key) {
        Object v = p.get(key);
        if (v == null) return null;
        return v instanceof Number ? ((Number) v).longValue() : Long.valueOf(v.toString());
    }

    private static Integer intOr(Map<String, Object> p, String key, int def) {
        Object v = p.get(key);
        if (v == null) return def;
        return v instanceof Number ? ((Number) v).intValue() : Integer.valueOf(v.toString());
    }

    private static BigDecimal dec(Map<String, Object> p, String key) {
        Object v = p.get(key);
        if (v == null) return null;
        return v instanceof BigDecimal ? (BigDecimal) v : new BigDecimal(v.toString());
    }

    private static BigDecimal decOr(Map<String, Object> p, String key, BigDecimal def) {
        BigDecimal v = dec(p, key);
        return v == null ? def : v;
    }
}
