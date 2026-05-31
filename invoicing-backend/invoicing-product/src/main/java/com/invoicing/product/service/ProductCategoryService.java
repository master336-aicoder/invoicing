package com.invoicing.product.service;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.invoicing.product.entity.ProductCategory;
import com.invoicing.product.mapper.ProductCategoryMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class ProductCategoryService extends ServiceImpl<ProductCategoryMapper, ProductCategory> {
}
