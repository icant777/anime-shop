package com.anime.backend.controller;

import com.anime.backend.common.Result;
import com.anime.backend.entity.User;
import com.anime.backend.service.UserService;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 用户接口
 * - POST /api/user/register  注册
 * - POST /api/user/login     登录（返回 token）
 * - GET  /api/user/check     登录态检查（前端据此决定跳注册页还是进主页）
 * - POST /api/user/logout    退出
 * - GET  /api/user/me        当前用户信息
 */
@RestController
@RequestMapping("/api/user")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @Data
    @AllArgsConstructor
    public static class RegisterReq {
        private String username;
        private String password;
        private String phone;
    }

    @Data
    @AllArgsConstructor
    public static class LoginReq {
        private String username;
        private String password;
    }

    @PostMapping("/register")
    public Result<?> register(@RequestBody RegisterReq req) {
        return Result.ok(userService.register(req.getUsername(), req.getPassword(), req.getPhone()));
    }

    @PostMapping("/login")
    public Result<?> login(@RequestBody LoginReq req) {
        return Result.ok(userService.login(req.getUsername(), req.getPassword()));
    }

    /**
     * 登录态检查：前端启动时调这个。
     * data.loggedIn=true -> 直接进入主页；false -> 跳注册/登录页。
     * 这正是需求里"未登录跳注册页、已登录进页面"的后端判定依据。
     */
    @GetMapping("/check")
    public Result<?> check(@RequestHeader(value = "token", required = false) String token) {
        User user = userService.currentUser(token);
        return Result.ok(Map.of("loggedIn", user != null, "user", user == null ? "" : user.getUsername()));
    }

    @GetMapping("/me")
    public Result<?> me(@RequestHeader(value = "token", required = false) String token) {
        User user = userService.currentUser(token);
        if (user == null) {
            return Result.unauthorized();
        }
        return Result.ok(user);
    }

    @PostMapping("/logout")
    public Result<?> logout(@RequestHeader(value = "token", required = false) String token) {
        userService.logout(token);
        return Result.ok();
    }
}
