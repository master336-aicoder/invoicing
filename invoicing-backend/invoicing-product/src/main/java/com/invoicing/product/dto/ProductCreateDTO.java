package com.invoicing.product.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class ProductCreateDTO {

    @NotBlank(message = "商品编码不能为空")
    private String productCode;

    @NotBlank(message = "商品名称不能为空")
    private String productName;

    private String barCode;

    private String spec;

    private String unit;

    private Long categoryId;

    @NotNull(message = "采购价不能为空")
    private BigDecimal purchasePrice;

    @NotNull(message = "销售价不能为空")
    private BigDecimal salePrice;

    private BigDecimal minPrice;

    private BigDecimal maxPrice;

    private String brand;

    private String origin;

    private Integer minStock;

    private Integer maxStock;

    private String description;

    private String imageUrl;
}
