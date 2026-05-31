package com.invoicing.common;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@Slf4j
public class JwtUtils {

    private static final String SECRET_KEY = "invoicing-secret-key-for-jwt-token-must-be-at-least-256-bits";
    private static final long ACCESS_TOKEN_EXPIRE_TIME = 2 * 60 * 60 * 1000L;
    private static final long REFRESH_TOKEN_EXPIRE_TIME = 7 * 24 * 60 * 60 * 1000L;

    private static final SecretKey KEY = Keys.hmacShaKeyFor(SECRET_KEY.getBytes(StandardCharsets.UTF_8));

    public static String generateAccessToken(Long userId, String username, Long tenantId) {
        return generateToken(userId, username, tenantId, ACCESS_TOKEN_EXPIRE_TIME);
    }

    public static String generateRefreshToken(Long userId, String username, Long tenantId) {
        return generateToken(userId, username, tenantId, REFRESH_TOKEN_EXPIRE_TIME);
    }

    private static String generateToken(Long userId, String username, Long tenantId, long expireTime) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("userId", userId);
        claims.put("username", username);
        claims.put("tenantId", tenantId);

        return Jwts.builder()
            .claims(claims)
            .subject(username)
            .issuedAt(new Date())
            .expiration(new Date(System.currentTimeMillis() + expireTime))
            .signWith(KEY)
            .compact();
    }

    public static Claims parseToken(String token) {
        try {
            return Jwts.parser()
                .verifyWith(KEY)
                .build()
                .parseSignedClaims(token)
                .getPayload();
        } catch (ExpiredJwtException e) {
            log.warn("Token expired: {}", e.getMessage());
            throw e;
        } catch (JwtException e) {
            log.warn("Invalid token: {}", e.getMessage());
            throw e;
        }
    }

    public static boolean validateToken(String token) {
        try {
            parseToken(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public static Long getUserIdFromToken(String token) {
        Claims claims = parseToken(token);
        return claims.get("userId", Long.class);
    }

    public static String getUsernameFromToken(String token) {
        Claims claims = parseToken(token);
        return claims.get("username", String.class);
    }

    public static Long getTenantIdFromToken(String token) {
        Claims claims = parseToken(token);
        return claims.get("tenantId", Long.class);
    }
}
