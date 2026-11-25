package com.anime.backend.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("user_coupon")
public class UserCoupon {
    @TableId(type = IdType.AUTO)
    private Long id;
    @TableField("user_id")
    private Long userId;
    @TableField("template_id")
    private Long templateId;
    @TableField("coupon_no")
    private String couponNo;
    private Integer status;
    @TableField("receive_time")
    private LocalDateTime receiveTime;
    @TableField("expire_time")
    private LocalDateTime expireTime;
    @TableField("use_time")
    private LocalDateTime useTime;
    @TableField("order_id")
    private Long orderId;
    @TableField("discount_amount")
    private BigDecimal discountAmount;
}
