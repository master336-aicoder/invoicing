package com.invoicing.auth.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.invoicing.auth.entity.Category;
import com.invoicing.auth.service.CategoryService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/product/categories")
public class CategoryController {

    private final CategoryService categoryService;

    public CategoryController(CategoryService categoryService) {
        this.categoryService = categoryService;
    }

    @GetMapping
    public ResponseEntity<Map<String, Object>> getCategoryList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(required = false) String keyword) {

        Page<Category> pageRequest = new Page<>(page, pageSize);
        IPage<Category> categoryPage = categoryService.getCategoryList(pageRequest, keyword);

        Map<String, Object> response = new HashMap<>();
        response.put("code", 200);
        response.put("message", "success");
        response.put("data", Map.of(
                "list", categoryPage.getRecords(),
                "total", categoryPage.getTotal(),
                "page", page,
                "pageSize", pageSize
        ));
        response.put("timestamp", System.currentTimeMillis());

        return ResponseEntity.ok(response);
    }

    @GetMapping("/all")
    public ResponseEntity<Map<String, Object>> getAllCategories() {
        List<Category> categories = categoryService.getAllCategories();

        Map<String, Object> response = new HashMap<>();
        response.put("code", 200);
        response.put("message", "success");
        response.put("data", categories);
        response.put("timestamp", System.currentTimeMillis());

        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getCategoryById(@PathVariable Long id) {
        Category category = categoryService.getCategoryById(id);

        Map<String, Object> response = new HashMap<>();
        if (category != null && category.getDeleted() == 0) {
            response.put("code", 200);
            response.put("message", "success");
            response.put("data", category);
        } else {
            response.put("code", 404);
            response.put("message", "分类不存在");
            response.put("data", null);
        }
        response.put("timestamp", System.currentTimeMillis());

        return ResponseEntity.ok(response);
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> createCategory(@RequestBody Category category) {
        Category created = categoryService.createCategory(category);

        Map<String, Object> response = new HashMap<>();
        response.put("code", 200);
        response.put("message", "创建成功");
        response.put("data", created);
        response.put("timestamp", System.currentTimeMillis());

        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updateCategory(@PathVariable Long id, @RequestBody Category category) {
        category.setId(id);
        Category updated = categoryService.updateCategory(category);

        Map<String, Object> response = new HashMap<>();
        if (updated != null) {
            response.put("code", 200);
            response.put("message", "更新成功");
            response.put("data", updated);
        } else {
            response.put("code", 404);
            response.put("message", "分类不存在");
            response.put("data", null);
        }
        response.put("timestamp", System.currentTimeMillis());

        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteCategory(@PathVariable Long id) {
        boolean deleted = categoryService.deleteCategory(id);

        Map<String, Object> response = new HashMap<>();
        if (deleted) {
            response.put("code", 200);
            response.put("message", "删除成功");
            response.put("data", true);
        } else {
            response.put("code", 404);
            response.put("message", "分类不存在");
            response.put("data", null);
        }
        response.put("timestamp", System.currentTimeMillis());

        return ResponseEntity.ok(response);
    }
}
