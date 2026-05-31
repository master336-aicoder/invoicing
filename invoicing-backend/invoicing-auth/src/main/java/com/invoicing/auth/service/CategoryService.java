package com.invoicing.auth.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.invoicing.auth.entity.Category;

import java.util.List;

public interface CategoryService {

    IPage<Category> getCategoryList(Page<Category> page, String keyword);

    List<Category> getAllCategories();

    Category getCategoryById(Long id);

    Category createCategory(Category category);

    Category updateCategory(Category category);

    boolean deleteCategory(Long id);
}
