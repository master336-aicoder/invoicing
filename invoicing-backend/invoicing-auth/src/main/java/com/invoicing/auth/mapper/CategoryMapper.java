package com.invoicing.auth.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.invoicing.auth.entity.Category;
import org.apache.ibatis.annotations.Param;

public interface CategoryMapper extends BaseMapper<Category> {

    IPage<Category> selectCategoryPage(Page<Category> page, @Param("keyword") String keyword);

    IPage<Category> selectAllCategories(Page<Category> page);
}
