package com.anime.backend.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("stock_log")
public class StockLog {
    @TableId(type = IdType.AUTO)
    private Long id;
    @TableField("sku_id")
    private Long skuId;
    @TableField("change_type")
    private Integer changeType;
    @TableField("change_quantity")
    private Integer changeQuantity;
    @TableField("before_stock")
    private Integer beforeStock;
    @TableField("after_stock")
    private Integer afterStock;
    @TableField("biz_type")
    private String bizType;
    @TableField("biz_no")
    private String bizNo;
    @TableField("operator_id")
    private Long operatorId;
    private String remark;
    @TableField("created_at")
    private LocalDateTime createdAt;
}
