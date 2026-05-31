package com.invoicing.product.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.invoicing.product.dto.ProductCreateDTO;
import com.invoicing.product.entity.ProductBase;
import com.invoicing.product.service.ProductBaseService;
import com.invoicing.common.PageResult;
import com.invoicing.common.Result;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/products")
@RequiredArgsConstructor
public class ProductController {

    private final ProductBaseService productBaseService;

    @GetMapping
    public Result<PageResult<ProductBase>> list(
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize,
            @RequestParam(required = false) String productName,
            @RequestParam(required = false) String productCode) {

        Page<ProductBase> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<ProductBase> wrapper = new LambdaQueryWrapper<>();

        if (productName != null) {
            wrapper.like(ProductBase::getProductName, productName);
        }
        if (productCode != null) {
            wrapper.like(ProductBase::getProductCode, productCode);
        }

        IPage<ProductBase> result = productBaseService.page(page, wrapper);
        return Result.success(PageResult.of(result));
    }

    @GetMapping("/{id}")
    public Result<ProductBase> getById(@PathVariable Long id) {
        ProductBase product = productBaseService.getById(id);
        return Result.success(product);
    }

    @PostMapping
    public Result<ProductBase> create(@Valid @RequestBody ProductCreateDTO dto) {
        ProductBase product = productBaseService.create(dto);
        return Result.success("创建成功", product);
    }

    @PutMapping("/{id}")
    public Result<ProductBase> update(@PathVariable Long id, @RequestBody ProductBase product) {
        product.setId(id);
        productBaseService.updateById(product);
        return Result.success("更新成功", product);
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        productBaseService.removeById(id);
        return Result.success("删除成功");
    }

    @GetMapping("/categories")
    public Result<List<ProductBase>> getByCategory(@RequestParam Long categoryId) {
        LambdaQueryWrapper<ProductBase> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ProductBase::getCategoryId, categoryId);
        List<ProductBase> products = productBaseService.list(wrapper);
        return Result.success(products);
    }
}
