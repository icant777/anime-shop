package com.anime.backend.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("user")
public class User {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String username;
    private String phone;
    private String email;
    @TableField("password_hash")
    private String passwordHash;
    @TableField("realname_status")
    private Integer realnameStatus;
    @TableField("id_card_hash")
    private String idCardHash;
    @TableField("birth_date")
    private LocalDate birthDate;
    @TableField("avatar_url")
    private String avatarUrl;
    private Integer status;
    @TableField("created_at")
    private LocalDateTime createdAt;
    @TableField("updated_at")
    private LocalDateTime updatedAt;
}
