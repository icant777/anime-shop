package com.anime.backend.controller;

import com.anime.backend.common.Result;
import com.anime.backend.service.CouponService;
import com.anime.backend.util.AuthUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/** 优惠券接口 */
@RestController
@RequestMapping("/api/coupon")
@RequiredArgsConstructor
public class CouponController {

    private final CouponService couponService;
    private final AuthUtil authUtil;

    /** 可领券列表（无需登录也能看） */
    @GetMapping("/available")
    public Result<?> available() {
        return Result.ok(couponService.available());
    }

    /** 领券（需登录） */
    @PostMapping("/claim/{templateId}")
    public Result<?> claim(@PathVariable Long templateId) {
        return Result.ok(couponService.claim(authUtil.requireUserId(), templateId));
    }

    /** 我的券 */
    @GetMapping("/my")
    public Result<?> my(@RequestParam(required = false) Integer status) {
        return Result.ok(couponService.myCoupons(authUtil.requireUserId(), status));
    }
}
