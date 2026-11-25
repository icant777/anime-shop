package com.anime.backend.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("user_video")
public class UserVideo {
    @TableId(type = IdType.AUTO)
    private Long id;
    @TableField("user_id")
    private Long userId;
    private String title;
    @TableField("video_url")
    private String videoUrl;
    @TableField("cover_url")
    private String coverUrl;
    private String description;
    @TableField("like_count")
    private Integer likeCount;
    @TableField("view_count")
    private Integer viewCount;
    private Integer status;
    @TableField("created_at")
    private LocalDateTime createdAt;
    @TableField("updated_at")
    private LocalDateTime updatedAt;

    /** 关联的用户名（列表查询时填充，不映射表字段） */
    @TableField(exist = false)
    private String username;
}
