package com.invoicing.auth.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.invoicing.auth.entity.Product;
import org.apache.ibatis.annotations.Param;

public interface ProductMapper extends BaseMapper<Product> {

    IPage<Product> selectProductPage(Page<Product> page, 
                                      @Param("keyword") String keyword, 
                                      @Param("category") String category);
}
