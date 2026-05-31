package com.invoicing.auth.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("product_category")
public class Category {

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    @TableField("tenant_id")
    private Long tenantId;

    @TableField("category_code")
    private String code;

    @TableField("category_name")
    private String name;

    @TableField("parent_id")
    private Long parentId;

    @TableField("level")
    private Integer level;

    @TableField("sort_order")
    private Integer sortOrder;

    @TableField("status")
    private Integer status;

    @TableField("remark")
    private String remark;

    @TableField("creator")
    private Long creator;

    @TableField("create_time")
    private LocalDateTime createTime;

    @TableField("updater")
    private Long updater;

    @TableField("update_time")
    private LocalDateTime updateTime;

    @TableField("deleted")
    private Integer deleted;
}
