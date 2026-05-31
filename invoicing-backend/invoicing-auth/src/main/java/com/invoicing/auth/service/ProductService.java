package com.invoicing.auth.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.invoicing.auth.entity.Product;

public interface ProductService {

    IPage<Product> getProductList(Page<Product> page, String keyword, String category);

    Product getProductById(Long id);

    Product createProduct(Product product);

    Product updateProduct(Product product);

    boolean deleteProduct(Long id);
}
