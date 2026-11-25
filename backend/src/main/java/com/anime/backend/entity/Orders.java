package com.anime.backend.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("orders")
public class Orders {
    @TableId(type = IdType.AUTO)
    private Long id;
    @TableField("order_no")
    private String orderNo;
    @TableField("user_id")
    private Long userId;
    @TableField("merchant_id")
    private Long merchantId;
    @TableField("order_type")
    private Integer orderType;
    @TableField("total_amount")
    private BigDecimal totalAmount;
    @TableField("deposit_paid")
    private BigDecimal depositPaid;
    @TableField("balance_amount")
    private BigDecimal balanceAmount;
    @TableField("balance_paid")
    private BigDecimal balancePaid;
    private Integer status;
    @TableField("receiver_name")
    private String receiverName;
    @TableField("receiver_phone")
    private String receiverPhone;
    @TableField("receiver_address")
    private String receiverAddress;
    @TableField("pay_time")
    private LocalDateTime payTime;
    @TableField("created_at")
    private LocalDateTime createdAt;
}
