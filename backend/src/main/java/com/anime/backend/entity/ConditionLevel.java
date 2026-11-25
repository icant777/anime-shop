package com.anime.backend.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("condition_level")
public class ConditionLevel {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String code;
    private String name;
}
