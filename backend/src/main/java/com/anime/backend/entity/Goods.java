package com.anime.backend.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("goods")
public class Goods {
    @TableId(type = IdType.AUTO)
    private Long id;
    @TableField("goods_code")
    private String goodsCode;
    @TableField("goods_name")
    private String goodsName;
    @TableField("ip_id")
    private Long ipId;
    @TableField("character_id")
    private Long characterId;
    @TableField("merchant_id")
    private Long merchantId;
    private String category;
    @TableField("category_id")
    private Long categoryId;
    @TableField("sale_mode")
    private Integer saleMode;
    @TableField("min_price")
    private BigDecimal minPrice;
    private BigDecimal deposit;
    private String images;       // JSON 字符串
    private String attributes;   // JSON 字符串
    private String detail;
    @TableField("presale_start")
    private LocalDateTime presaleStart;
    @TableField("presale_end")
    private LocalDateTime presaleEnd;
    @TableField("push_status")
    private Integer pushStatus;
    private Integer status;
    @TableField("audit_status")
    private Integer auditStatus;
    private Integer deleted;
}
