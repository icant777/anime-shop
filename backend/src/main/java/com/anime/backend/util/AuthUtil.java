package com.anime.backend.util;

import com.anime.backend.common.BizException;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

/**
 * 鉴权工具：从请求头 token 读当前登录用户 id。
 * 和 UserService 用同一个 Redis key 前缀（anime:token:）。
 */
@Component
@RequiredArgsConstructor
public class AuthUtil {

    public static final String TOKEN_PREFIX = "anime:token:";
    private final RedisTemplate<String, Object> redisTemplate;

    private String token() {
        ServletRequestAttributes attrs = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attrs == null) {
            return null;
        }
        HttpServletRequest req = attrs.getRequest();
        String token = req.getHeader("token");
        if (token == null || token.isBlank()) {
            token = req.getParameter("token"); // 也允许 URL 参数，方便调试
        }
        return token;
    }

    /** 未登录返回 null */
    public Long currentUserIdOrNull() {
        String token = token();
        if (token == null || token.isBlank()) {
            return null;
        }
        Object uid = redisTemplate.opsForValue().get(TOKEN_PREFIX + token);
        return uid == null ? null : ((Number) uid).longValue();
    }

    /** 未登录直接抛 401 */
    public Long requireUserId() {
        Long uid = currentUserIdOrNull();
        if (uid == null) {
            throw new BizException(401, "未登录或登录已过期");
        }
        return uid;
    }
}
