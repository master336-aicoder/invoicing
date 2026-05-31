package com.invoicing.product.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.invoicing.product.dto.ProductCreateDTO;
import com.invoicing.product.entity.ProductBase;
import com.invoicing.product.mapper.ProductBaseMapper;
import com.invoicing.common.ServiceException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class ProductBaseService extends ServiceImpl<ProductBaseMapper, ProductBase> {

    public ProductBase getByCode(String productCode) {
        return getOne(new LambdaQueryWrapper<ProductBase>()
            .eq(ProductBase::getProductCode, productCode)
            .eq(ProductBase::getDeleted, 0));
    }

    public ProductBase create(ProductCreateDTO dto) {
        if (getByCode(dto.getProductCode()) != null) {
            throw ServiceException.badRequest("商品编码已存在");
        }

        ProductBase product = new ProductBase();
        product.setProductCode(dto.getProductCode());
        product.setProductName(dto.getProductName());
        product.setBarCode(dto.getBarCode());
        product.setSpec(dto.getSpec());
        product.setUnit(dto.getUnit());
        product.setCategoryId(dto.getCategoryId());
        product.setPurchasePrice(dto.getPurchasePrice());
        product.setSalePrice(dto.getSalePrice());
        product.setMinPrice(dto.getMinPrice());
        product.setMaxPrice(dto.getMaxPrice());
        product.setBrand(dto.getBrand());
        product.setOrigin(dto.getOrigin());
        product.setStockQuantity(0);
        product.setMinStock(dto.getMinStock() != null ? dto.getMinStock() : 10);
        product.setMaxStock(dto.getMaxStock() != null ? dto.getMaxStock() : 1000);
        product.setDescription(dto.getDescription());
        product.setImageUrl(dto.getImageUrl());
        product.setStatus(1);

        save(product);
        log.info("Created product: {}", product.getProductName());
        return product;
    }
}
