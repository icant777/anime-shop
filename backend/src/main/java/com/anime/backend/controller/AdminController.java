package com.anime.backend.controller;

import com.anime.backend.common.Result;
import com.anime.backend.service.AdminService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 管理端接口：商品、SKU、用户的增删改查。
 * 实际项目应加管理员权限校验，这里教学项目暂不拦截。
 */
@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class AdminController {

    private final AdminService adminService;

    // ---------- 基础数据（添加商品时下拉选） ----------
    @GetMapping("/basics")
    public Result<?> basics() {
        return Result.ok(adminService.basics());
    }

    // ---------- 商品 ----------
    @GetMapping("/goods")
    public Result<?> allGoods() {
        return Result.ok(adminService.allGoods());
    }

    @GetMapping("/goods/{id}")
    public Result<?> goodsDetail(@PathVariable Long id) {
        return Result.ok(adminService.goodsDetail(id));
    }

    @PostMapping("/goods")
    public Result<?> addGoods(@RequestBody Map<String, Object> body) {
        return Result.ok(adminService.addGoods(body));
    }

    @PutMapping("/goods/{id}")
    public Result<?> updateGoods(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        return Result.ok(adminService.updateGoods(id, body));
    }

    @DeleteMapping("/goods/{id}")
    public Result<?> deleteGoods(@PathVariable Long id) {
        adminService.deleteGoods(id);
        return Result.ok();
    }

    @PostMapping("/goods/{id}/restore")
    public Result<?> restoreGoods(@PathVariable Long id) {
        adminService.restoreGoods(id);
        return Result.ok();
    }

    // ---------- SKU ----------
    @GetMapping("/goods/{id}/skus")
    public Result<?> skusOf(@PathVariable Long id) {
        return Result.ok(adminService.skusOf(id));
    }

    @PostMapping("/sku")
    public Result<?> addSku(@RequestBody Map<String, Object> body) {
        return Result.ok(adminService.addSku(body));
    }

    @PutMapping("/sku/{id}")
    public Result<?> updateSku(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        return Result.ok(adminService.updateSku(id, body));
    }

    @DeleteMapping("/sku/{id}")
    public Result<?> deleteSku(@PathVariable Long id) {
        adminService.deleteSku(id);
        return Result.ok();
    }

    // ---------- 用户 ----------
    @GetMapping("/users")
    public Result<?> allUsers() {
        return Result.ok(adminService.allUsers());
    }

    @PostMapping("/users")
    public Result<?> addUser(@RequestBody Map<String, Object> body) {
        return Result.ok(adminService.addUser(body));
    }

    @PutMapping("/users/{id}")
    public Result<?> updateUser(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        return Result.ok(adminService.updateUser(id, body));
    }

    @PostMapping("/users/{id}/resetpwd")
    public Result<?> resetPassword(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        adminService.resetPassword(id, body.get("password") == null ? null : body.get("password").toString());
        return Result.ok();
    }

    @DeleteMapping("/users/{id}")
    public Result<?> deleteUser(@PathVariable Long id) {
        adminService.deleteUser(id);
        return Result.ok();
    }
}
