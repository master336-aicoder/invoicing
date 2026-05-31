package com.invoicing.auth.service;

import com.invoicing.auth.dto.LoginDTO;
import com.invoicing.auth.dto.TokenDTO;
import com.invoicing.auth.entity.User;
import com.invoicing.common.JwtUtils;
import com.invoicing.common.ServiceException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserService userService;

    public TokenDTO login(LoginDTO loginDTO) {
        User user = userService.getByUsername(loginDTO.getUsername());
        if (user == null) {
            throw ServiceException.unauthorized("用户名或密码错误");
        }

        if (user.getStatus() != 1) {
            throw ServiceException.forbidden("账号已被禁用");
        }

        if (!userService.validatePassword(loginDTO.getPassword(), user.getPassword())) {
            throw ServiceException.unauthorized("用户名或密码错误");
        }

        userService.updateLastLoginInfo(user.getId(), "127.0.0.1");

        String accessToken = JwtUtils.generateAccessToken(user.getId(), user.getUsername(), user.getTenantId());
        String refreshToken = JwtUtils.generateRefreshToken(user.getId(), user.getUsername(), user.getTenantId());

        log.info("User logged in: {}", user.getUsername());

        return TokenDTO.builder()
            .accessToken(accessToken)
            .refreshToken(refreshToken)
            .expiresIn(7200L)
            .build();
    }

    public User getUserInfo(Long userId) {
        User user = userService.getById(userId);
        if (user == null) {
            throw ServiceException.unauthorized("用户不存在");
        }
        user.setPassword(null);
        return user;
    }
}
