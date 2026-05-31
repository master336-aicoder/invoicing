package com.invoicing.product.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.invoicing.common.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("product_base")
public class ProductBase extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String productCode;

    private String productName;

    private String barCode;

    private String spec;

    private String unit;

    private Long categoryId;

    private BigDecimal purchasePrice;

    private BigDecimal salePrice;

    private BigDecimal minPrice;

    private BigDecimal maxPrice;

    private String brand;

    private String origin;

    private Integer stockQuantity;

    private Integer minStock;

    private Integer maxStock;

    private String description;

    private Integer status;

    private String imageUrl;
}
