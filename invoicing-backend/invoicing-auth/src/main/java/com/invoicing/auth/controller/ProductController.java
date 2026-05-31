package com.invoicing.auth.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.invoicing.auth.entity.Product;
import com.invoicing.auth.service.ProductService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/product/products")
public class ProductController {

    private final ProductService productService;

    public ProductController(ProductService productService) {
        this.productService = productService;
    }

    @GetMapping
    public ResponseEntity<Map<String, Object>> getProductList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String category) {
        
        Page<Product> pageRequest = new Page<>(page, pageSize);
        IPage<Product> productPage = productService.getProductList(pageRequest, keyword, category);
        
        Map<String, Object> response = new HashMap<>();
        response.put("code", 200);
        response.put("message", "success");
        response.put("data", Map.of(
                "list", productPage.getRecords(),
                "total", productPage.getTotal(),
                "page", page,
                "pageSize", pageSize
        ));
        response.put("timestamp", System.currentTimeMillis());
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getProductById(@PathVariable Long id) {
        Product product = productService.getProductById(id);
        
        Map<String, Object> response = new HashMap<>();
        if (product != null) {
            response.put("code", 200);
            response.put("message", "success");
            response.put("data", product);
        } else {
            response.put("code", 404);
            response.put("message", "商品不存在");
            response.put("data", null);
        }
        response.put("timestamp", System.currentTimeMillis());
        
        return ResponseEntity.ok(response);
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> createProduct(@RequestBody Product product) {
        Product created = productService.createProduct(product);
        
        Map<String, Object> response = new HashMap<>();
        response.put("code", 200);
        response.put("message", "创建成功");
        response.put("data", created);
        response.put("timestamp", System.currentTimeMillis());
        
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updateProduct(@PathVariable Long id, @RequestBody Product product) {
        product.setId(id);
        Product updated = productService.updateProduct(product);
        
        Map<String, Object> response = new HashMap<>();
        if (updated != null) {
            response.put("code", 200);
            response.put("message", "更新成功");
            response.put("data", updated);
        } else {
            response.put("code", 404);
            response.put("message", "商品不存在");
            response.put("data", null);
        }
        response.put("timestamp", System.currentTimeMillis());
        
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteProduct(@PathVariable Long id) {
        boolean deleted = productService.deleteProduct(id);
        
        Map<String, Object> response = new HashMap<>();
        if (deleted) {
            response.put("code", 200);
            response.put("message", "删除成功");
            response.put("data", true);
        } else {
            response.put("code", 404);
            response.put("message", "商品不存在");
            response.put("data", null);
        }
        response.put("timestamp", System.currentTimeMillis());
        
        return ResponseEntity.ok(response);
    }
}
