package com.invoicing.auth.controller;

import com.invoicing.auth.dto.LoginDTO;
import com.invoicing.auth.dto.TokenDTO;
import com.invoicing.auth.entity.User;
import com.invoicing.auth.service.AuthService;
import com.invoicing.common.Result;
import com.invoicing.common.TenantContext;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/login")
    public Result<TokenDTO> login(@Valid @RequestBody LoginDTO loginDTO) {
        TokenDTO token = authService.login(loginDTO);
        return Result.success(token);
    }

    @GetMapping("/user/info")
    public Result<User> getUserInfo() {
        Long userId = TenantContext.getUserId();
        User userInfo = authService.getUserInfo(userId);
        return Result.success(userInfo);
    }

    @GetMapping("/permissions")
    public Result<List<String>> getPermissions() {
        return Result.success(List.of("*:*:*"));
    }

    @PostMapping("/logout")
    public Result<Void> logout() {
        return Result.success();
    }
}
