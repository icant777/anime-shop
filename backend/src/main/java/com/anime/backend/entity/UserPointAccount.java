package com.anime.backend.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("user_point_account")
public class UserPointAccount {
    @TableId(type = IdType.AUTO)
    private Long id;
    @TableField("user_id")
    private Long userId;
    private Integer balance;
    @TableField("frozen_point")
    private Integer frozenPoint;
    @TableField("total_earned")
    private Integer totalEarned;
    @TableField("total_used")
    private Integer totalUsed;
    @TableField("total_expired")
    private Integer totalExpired;
    private Integer level;
    private Integer version;
    @TableField("created_at")
    private LocalDateTime createdAt;
    @TableField("updated_at")
    private LocalDateTime updatedAt;
}
