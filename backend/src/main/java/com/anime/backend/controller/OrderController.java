package com.anime.backend.controller;

import com.anime.backend.common.Result;
import com.anime.backend.service.OrderService;
import com.anime.backend.util.AuthUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/** 订单接口：下单需要登录 */
@RestController
@RequestMapping("/api/order")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;
    private final AuthUtil authUtil;

    @PostMapping("/place")
    public Result<?> place(@RequestBody Map<String, Object> body) {
        Long userId = authUtil.requireUserId();
        @SuppressWarnings("unchecked")
        List<Map<String, Object>> items = (List<Map<String, Object>>) body.get("items");
        String name = (String) body.get("receiverName");
        String phone = (String) body.get("receiverPhone");
        String address = (String) body.get("receiverAddress");
        return Result.ok(orderService.placeOrder(userId, items, name, phone, address));
    }

    @GetMapping("/my")
    public Result<?> my() {
        return Result.ok(orderService.myOrders(authUtil.requireUserId()));
    }

    @GetMapping("/detail/{id}")
    public Result<?> detail(@PathVariable Long id) {
        return Result.ok(orderService.detail(authUtil.requireUserId(), id));
    }
}
