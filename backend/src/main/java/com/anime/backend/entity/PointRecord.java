package com.anime.backend.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("point_record")
public class PointRecord {
    @TableId(type = IdType.AUTO)
    private Long id;
    @TableField("user_id")
    private Long userId;
    @TableField("change_type")
    private Integer changeType;
    private Integer points;
    @TableField("balance_after")
    private Integer balanceAfter;
    @TableField("biz_type")
    private String bizType;
    @TableField("biz_no")
    private String bizNo;
    private String remark;
    @TableField("created_at")
    private LocalDateTime createdAt;
}
