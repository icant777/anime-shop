package com.anime.backend.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("ip")
public class Ip {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String name;
    @TableField("name_en")
    private String nameEn;
    private String category;
    private Integer status;
}
