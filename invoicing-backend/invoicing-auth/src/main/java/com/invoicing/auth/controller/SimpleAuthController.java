package com.invoicing.auth.controller;

import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/auth")
public class SimpleAuthController {

    @PostMapping("/login")
    public Map<String, Object> login(@RequestBody Map<String, String> body) {
        String username = body.get("username");
        String password = body.get("password");
        
        Map<String, Object> response = new HashMap<>();
        
        if ("admin".equals(username) && "admin123".equals(password)) {
            response.put("code", 200);
            response.put("message", "success");
            response.put("data", Map.of(
                "accessToken", "test-token-12345",
                "refreshToken", "refresh-token-12345",
                "expiresIn", 7200L
            ));
        } else {
            response.put("code", 401);
            response.put("message", "用户名或密码错误");
            response.put("data", null);
        }
        
        return response;
    }

    @GetMapping("/user/info")
    public Map<String, Object> getUserInfo() {
        Map<String, Object> response = new HashMap<>();
        response.put("code", 200);
        response.put("message", "success");
        response.put("data", Map.of(
            "id", 1L,
            "username", "admin",
            "nickname", "系统管理员",
            "email", "admin@invoicing.com"
        ));
        return response;
    }
}
