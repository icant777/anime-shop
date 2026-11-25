package com.anime.backend.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;

@Data
@TableName("order_item")
public class OrderItem {
    @TableId(type = IdType.AUTO)
    private Long id;
    @TableField("order_id")
    private Long orderId;
    @TableField("goods_id")
    private Long goodsId;
    @TableField("goods_condition_rel_id")
    private Long goodsConditionRelId;
    @TableField("goods_name")
    private String goodsName;
    @TableField("condition_name")
    private String conditionName;
    @TableField("ip_id")
    private Long ipId;
    @TableField("character_id")
    private Long characterId;
    @TableField("unit_price")
    private BigDecimal unitPrice;
    private Integer quantity;
    @TableField("deposit_amount")
    private BigDecimal depositAmount;
    @TableField("total_amount")
    private BigDecimal totalAmount;
}
