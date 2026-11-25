package com.anime.backend.service;

import com.anime.backend.common.BizException;
import com.anime.backend.entity.User;
import com.anime.backend.mapper.UserMapper;
import com.anime.backend.util.Md5Util;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

/**
 * 用户服务：注册、登录、会话校验
 * 会话方案：登录成功生成 token，Redis 里存 token -> userId，设 2 小时过期。
 * 前端每次请求带请求头 token，后端靠它认人。
 */
@Service
@RequiredArgsConstructor
public class UserService {

    private final UserMapper userMapper;
    private final RedisTemplate<String, Object> redisTemplate;

    private static final String TOKEN_PREFIX = "anime:token:";
    private static final long TOKEN_TTL_HOURS = 2;

    /** 注册：username / phone 唯一，密码 MD5 存 */
    public Map<String, Object> register(String username, String password, String phone) {
        if (username == null || username.isBlank() || password == null || password.isBlank()) {
            throw new BizException("用户名密码不能为空");
        }
        Long exist = userMapper.selectCount(new LambdaQueryWrapper<User>().eq(User::getUsername, username));
        if (exist != null && exist > 0) {
            throw new BizException("用户名已存在");
        }
        if (phone != null && !phone.isBlank()) {
            Long phoneUsed = userMapper.selectCount(new LambdaQueryWrapper<User>().eq(User::getPhone, phone));
            if (phoneUsed != null && phoneUsed > 0) {
                throw new BizException("手机号已注册");
            }
        }

        User user = new User();
        user.setUsername(username);
        user.setPasswordHash(Md5Util.md5(password));
        user.setPhone(phone);
        user.setStatus(1);
        user.setRealnameStatus(0);
        userMapper.insert(user);

        Map<String, Object> result = new HashMap<>();
        result.put("id", user.getId());
        result.put("username", user.getUsername());
        return result;
    }

    /** 登录：校验密码，生成 token 存 Redis，返回 token + 用户信息 */
    public Map<String, Object> login(String username, String password) {
        User user = userMapper.selectOne(new LambdaQueryWrapper<User>().eq(User::getUsername, username));
        if (user == null) {
            throw new BizException("用户名或密码错误");
        }
        if (!Md5Util.md5(password).equals(user.getPasswordHash())) {
            throw new BizException("用户名或密码错误");
        }
        if (user.getStatus() != null && user.getStatus() != 1) {
            throw new BizException("账号已被冻结或注销");
        }

        String token = UUID.randomUUID().toString().replace("-", "");
        redisTemplate.opsForValue().set(TOKEN_PREFIX + token, user.getId(), TOKEN_TTL_HOURS, TimeUnit.HOURS);

        user.setPasswordHash(null); // 不把密码散列返回前端
        Map<String, Object> result = new HashMap<>();
        result.put("token", token);
        result.put("user", user);
        return result;
    }

    /** 按 token 取当前用户；返回 null 表示未登录 */
    public User currentUser(String token) {
        if (token == null || token.isBlank()) {
            return null;
        }
        Object uid = redisTemplate.opsForValue().get(TOKEN_PREFIX + token);
        if (uid == null) {
            return null;
        }
        User user = userMapper.selectById(((Number) uid).longValue());
        if (user != null) {
            user.setPasswordHash(null);
        }
        return user;
    }

    /** 退出：删 Redis token */
    public void logout(String token) {
        if (token != null) {
            redisTemplate.delete(TOKEN_PREFIX + token);
        }
    }

    /** 内部用：按 id 取用户（不脱敏），其他 Service 调 */
    public User getById(Long id) {
        User user = userMapper.selectById(id);
        if (user == null) {
            throw new BizException("用户不存在");
        }
        return user;
    }
}
