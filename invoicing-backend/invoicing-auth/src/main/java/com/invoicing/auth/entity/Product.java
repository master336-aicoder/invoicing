package com.invoicing.auth.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("product_base")
public class Product {

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    @TableField("tenant_id")
    private Long tenantId;

    @TableField("product_code")
    private String code;

    @TableField("product_name")
    private String name;

    @TableField("product_type")
    private Integer type;

    @TableField("category_id")
    private Long categoryId;

    @TableField("category_name")
    private String categoryName;

    @TableField("unit_id")
    private Long unitId;

    @TableField("unit")
    private String unit;

    @TableField("min_order_qty")
    private BigDecimal minOrderQty;

    @TableField("safety_stock")
    private BigDecimal safetyStock;

    @TableField("max_stock")
    private BigDecimal maxStock;

    @TableField("cost_price")
    private BigDecimal costPrice;

    @TableField("sale_price")
    private BigDecimal salePrice;

    @TableField("tax_rate")
    private BigDecimal taxRate;

    @TableField("weight")
    private BigDecimal weight;

    @TableField("volume")
    private BigDecimal volume;

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

    @TableField(exist = false)
    private BigDecimal stock;
}
