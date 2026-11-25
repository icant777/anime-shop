package com.anime.backend.controller;

import com.anime.backend.common.Result;
import com.anime.backend.service.SigninService;
import com.anime.backend.util.AuthUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

/** 签到 + 积分接口 */
@RestController
@RequestMapping("/api/point")
@RequiredArgsConstructor
public class SigninController {

    private final SigninService signinService;
    private final AuthUtil authUtil;

    /** 签到 */
    @PostMapping("/signin")
    public Result<?> signin() {
        return Result.ok(signinService.signin(authUtil.requireUserId()));
    }

    /** 积分账户（缓存 10 分钟，积分变动时自动失效） */
    @GetMapping("/account")
    public Result<?> account() {
        return Result.ok(signinService.account(authUtil.requireUserId()));
    }

    /** 积分流水 */
    @GetMapping("/records")
    public Result<?> records() {
        return Result.ok(signinService.pointRecords(authUtil.requireUserId()));
    }

    /** 签到历史 */
    @GetMapping("/history")
    public Result<?> history() {
        return Result.ok(signinService.history(authUtil.requireUserId()));
    }
}
