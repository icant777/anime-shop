package com.anime.backend.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("signin_record")
public class SigninRecord {
    @TableId(type = IdType.AUTO)
    private Long id;
    @TableField("user_id")
    private Long userId;
    @TableField("sign_date")
    private LocalDate signDate;
    @TableField("continuous_days")
    private Integer continuousDays;
    @TableField("points_earned")
    private Integer pointsEarned;
    private Integer source;
    @TableField("sign_time")
    private LocalDateTime signTime;
}
