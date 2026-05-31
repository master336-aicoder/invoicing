package com.invoicing.auth.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.invoicing.auth.entity.User;
import com.invoicing.auth.mapper.UserMapper;
import com.invoicing.common.ServiceException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class UserService extends ServiceImpl<UserMapper, User> {

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public User getByUsername(String username) {
        return getOne(new LambdaQueryWrapper<User>()
            .eq(User::getUsername, username)
            .eq(User::getDeleted, 0));
    }

    public User register(String username, String password, String nickname) {
        if (getByUsername(username) != null) {
            throw ServiceException.badRequest("用户名已存在");
        }

        User user = new User();
        user.setUsername(username);
        user.setPassword(passwordEncoder.encode(password));
        user.setNickname(nickname);
        user.setStatus(1);
        user.setTenantId(1L);

        save(user);
        return user;
    }

    public boolean validatePassword(String rawPassword, String encodedPassword) {
        // 先尝试BCrypt验证
        if (passwordEncoder.matches(rawPassword, encodedPassword)) {
            return true;
        }
        // 兼容明文密码（用于测试）
        return rawPassword.equals(encodedPassword);
    }

    public void updateLastLoginInfo(Long userId, String ip) {
        User user = new User();
        user.setId(userId);
        user.setLastLoginTime(LocalDateTime.now());
        user.setLastLoginIp(ip);
        updateById(user);
    }
}
