package com.anime.backend.controller;

import com.anime.backend.common.Result;
import com.anime.backend.service.VideoService;
import com.anime.backend.util.AuthUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

/** 视频接口：发布/我的需登录，列表/点赞公开 */
@RestController
@RequestMapping("/api/video")
@RequiredArgsConstructor
public class VideoController {

    private final VideoService videoService;
    private final AuthUtil authUtil;

    /** 发布视频（multipart/form-data） */
    @PostMapping("/publish")
    public Result<?> publish(@RequestParam String title,
                             @RequestParam(required = false) String description,
                             @RequestParam("file") MultipartFile file) {
        return Result.ok(videoService.publish(authUtil.requireUserId(), title, description, file));
    }

    /** 视频列表 */
    @GetMapping("/list")
    public Result<?> list(@RequestParam(required = false) Integer page,
                          @RequestParam(required = false) Integer size) {
        return Result.ok(videoService.list(page, size));
    }

    @GetMapping("/my")
    public Result<?> my() {
        return Result.ok(videoService.myVideos(authUtil.requireUserId()));
    }

    @PostMapping("/like/{id}")
    public Result<?> like(@PathVariable Long id) {
        return Result.ok(videoService.like(id));
    }

    @PostMapping("/view/{id}")
    public Result<?> view(@PathVariable Long id) {
        videoService.addView(id);
        return Result.ok();
    }
}
