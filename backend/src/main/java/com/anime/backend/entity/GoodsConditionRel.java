package com.anime.backend.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;

@Data
@TableName("goods_condition_rel")
public class GoodsConditionRel {
    @TableId(type = IdType.AUTO)
    private Long id;
    @TableField("goods_id")
    private Long goodsId;
    @TableField("condition_level_id")
    private Long conditionLevelId;
    @TableField("sku_code")
    private String skuCode;
    private BigDecimal price;
    private BigDecimal deposit;
    private Integer stock;
    @TableField("locked_stock")
    private Integer lockedStock;
    private Integer status;
}
