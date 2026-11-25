package com.anime.backend.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("ip_character")
public class IpCharacter {
    @TableId(type = IdType.AUTO)
    private Long id;
    @TableField("ip_id")
    private Long ipId;
    private String name;
    @TableField("sort_no")
    private Integer sortNo;
    private Integer status;
}
