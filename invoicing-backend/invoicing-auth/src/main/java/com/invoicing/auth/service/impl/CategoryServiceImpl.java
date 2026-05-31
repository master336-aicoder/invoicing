package com.invoicing.auth.service.impl;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.invoicing.auth.entity.Category;
import com.invoicing.auth.mapper.CategoryMapper;
import com.invoicing.auth.service.CategoryService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class CategoryServiceImpl extends ServiceImpl<CategoryMapper, Category> implements CategoryService {

    @Override
    public IPage<Category> getCategoryList(Page<Category> page, String keyword) {
        return baseMapper.selectCategoryPage(page, keyword);
    }

    @Override
    public List<Category> getAllCategories() {
        Page<Category> page = new Page<>(1, 1000);
        return baseMapper.selectAllCategories(page).getRecords();
    }

    @Override
    public Category getCategoryById(Long id) {
        return baseMapper.selectById(id);
    }

    @Override
    @Transactional
    public Category createCategory(Category category) {
        category.setTenantId(1L);
        category.setCreator(1L);
        category.setStatus(1);
        category.setDeleted(0);
        if (category.getLevel() == null) {
            category.setLevel(1);
        }
        if (category.getSortOrder() == null) {
            category.setSortOrder(0);
        }
        baseMapper.insert(category);
        return category;
    }

    @Override
    @Transactional
    public Category updateCategory(Category category) {
        category.setUpdater(1L);
        baseMapper.updateById(category);
        return baseMapper.selectById(category.getId());
    }

    @Override
    @Transactional
    public boolean deleteCategory(Long id) {
        Category category = baseMapper.selectById(id);
        if (category != null) {
            category.setDeleted(1);
            baseMapper.updateById(category);
            return true;
        }
        return false;
    }
}
