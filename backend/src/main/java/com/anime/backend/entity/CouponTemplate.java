package com.anime.backend.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("coupon_template")
public class CouponTemplate {
    @TableId(type = IdType.AUTO)
    private Long id;
    @TableField("coupon_code")
    private String couponCode;
    @TableField("coupon_name")
    private String couponName;
    @TableField("coupon_type")
    private Integer couponType;
    @TableField("discount_value")
    private BigDecimal discountValue;
    @TableField("threshold_amount")
    private BigDecimal thresholdAmount;
    @TableField("max_discount")
    private BigDecimal maxDiscount;
    @TableField("total_count")
    private Integer totalCount;
    @TableField("claimed_count")
    private Integer claimedCount;
    @TableField("used_count")
    private Integer usedCount;
    @TableField("per_user_limit")
    private Integer perUserLimit;
    @TableField("scope_type")
    private Integer scopeType;
    @TableField("scope_id")
    private Long scopeId;
    @TableField("start_time")
    private LocalDateTime startTime;
    @TableField("end_time")
    private LocalDateTime endTime;
    @TableField("valid_days")
    private Integer validDays;
    @TableField("fixed_expire_time")
    private LocalDateTime fixedExpireTime;
    private Integer status;
}
