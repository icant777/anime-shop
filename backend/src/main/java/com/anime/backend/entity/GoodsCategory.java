package com.anime.backend.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("goods_category")
public class GoodsCategory {
    @TableId(type = IdType.AUTO)
    private Long id;
    @com.baomidou.mybatisplus.annotation.TableField("parent_id")
    private Long parentId;
    @com.baomidou.mybatisplus.annotation.TableField("category_name")
    private String categoryName;
    @com.baomidou.mybatisplus.annotation.TableField("category_code")
    private String categoryCode;
    private Integer level;
    @com.baomidou.mybatisplus.annotation.TableField("sort_no")
    private Integer sortNo;
    @com.baomidou.mybatisplus.annotation.TableField("icon_url")
    private String iconUrl;
    private String description;
    private Integer status;
}
