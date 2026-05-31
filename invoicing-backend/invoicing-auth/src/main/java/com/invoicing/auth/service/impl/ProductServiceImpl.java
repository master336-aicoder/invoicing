package com.invoicing.auth.service.impl;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.invoicing.auth.entity.Product;
import com.invoicing.auth.mapper.ProductMapper;
import com.invoicing.auth.service.ProductService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ProductServiceImpl extends ServiceImpl<ProductMapper, Product> implements ProductService {

    @Override
    public IPage<Product> getProductList(Page<Product> page, String keyword, String category) {
        return baseMapper.selectProductPage(page, keyword, category);
    }

    @Override
    public Product getProductById(Long id) {
        return baseMapper.selectById(id);
    }

    @Override
    @Transactional
    public Product createProduct(Product product) {
        product.setTenantId(1L);
        product.setCreator(1L);
        product.setStatus(1);
        product.setDeleted(0);
        baseMapper.insert(product);
        return product;
    }

    @Override
    @Transactional
    public Product updateProduct(Product product) {
        product.setUpdater(1L);
        baseMapper.updateById(product);
        return baseMapper.selectById(product.getId());
    }

    @Override
    @Transactional
    public boolean deleteProduct(Long id) {
        Product product = baseMapper.selectById(id);
        if (product != null) {
            product.setDeleted(1);
            baseMapper.updateById(product);
            return true;
        }
        return false;
    }
}
