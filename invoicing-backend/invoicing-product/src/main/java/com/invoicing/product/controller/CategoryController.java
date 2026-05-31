package com.invoicing.product.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.invoicing.product.entity.ProductCategory;
import com.invoicing.product.service.ProductCategoryService;
import com.invoicing.common.Result;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/categories")
@RequiredArgsConstructor
public class CategoryController {

    private final ProductCategoryService categoryService;

    @GetMapping
    public Result<List<ProductCategory>> list(
            @RequestParam(required = false) Long parentId,
            @RequestParam(required = false) Integer status) {

        LambdaQueryWrapper<ProductCategory> wrapper = new LambdaQueryWrapper<>();
        if (parentId != null) {
            wrapper.eq(ProductCategory::getParentId, parentId);
        }
        if (status != null) {
            wrapper.eq(ProductCategory::getStatus, status);
        }
        wrapper.orderByAsc(ProductCategory::getSortOrder);

        List<ProductCategory> categories = categoryService.list(wrapper);
        return Result.success(categories);
    }

    @GetMapping("/{id}")
    public Result<ProductCategory> getById(@PathVariable Long id) {
        ProductCategory category = categoryService.getById(id);
        return Result.success(category);
    }

    @PostMapping
    public Result<ProductCategory> create(@RequestBody ProductCategory category) {
        categoryService.save(category);
        return Result.success("创建成功", category);
    }

    @PutMapping("/{id}")
    public Result<ProductCategory> update(@PathVariable Long id, @RequestBody ProductCategory category) {
        category.setId(id);
        categoryService.updateById(category);
        return Result.success("更新成功", category);
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        categoryService.removeById(id);
        return Result.success("删除成功");
    }
}
