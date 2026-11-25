package com.anime.backend.controller;

import com.anime.backend.common.Result;
import com.anime.backend.service.GoodsService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/** 商品接口（公开，无需登录即可浏览） */
@RestController
@RequestMapping("/api/goods")
@RequiredArgsConstructor
public class GoodsController {

    private final GoodsService goodsService;

    @GetMapping("/list")
    public Result<?> list(@RequestParam(required = false) Integer page,
                          @RequestParam(required = false) Integer size,
                          @RequestParam(required = false, name = "categoryId") Long categoryId,
                          @RequestParam(required = false) String keyword) {
        return Result.ok(goodsService.list(page, size, categoryId, keyword));
    }

    @GetMapping("/detail/{id}")
    public Result<?> detail(@PathVariable Long id) {
        return Result.ok(goodsService.detail(id));
    }

    @GetMapping("/categories")
    public Result<?> categories() {
        return Result.ok(goodsService.categoryTree());
    }
}
