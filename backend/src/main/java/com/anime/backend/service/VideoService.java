package com.anime.backend.service;

import com.anime.backend.common.BizException;
import com.anime.backend.entity.User;
import com.anime.backend.entity.UserVideo;
import com.anime.backend.mapper.UserMapper;
import com.anime.backend.mapper.UserVideoMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.*;

/** 视频服务：发布（上传到本地）、列表、点赞、我的视频 */
@Slf4j
@Service
@RequiredArgsConstructor
public class VideoService {

    private final UserVideoMapper videoMapper;
    private final UserMapper userMapper;

    @Value("${app.video-upload-dir}")
    private String uploadDir;

    /** 发布视频：文件存本地，数据库存访问 URL */
    public UserVideo publish(Long userId, String title, String description, MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new BizException("请选择视频文件");
        }
        if (title == null || title.isBlank()) {
            throw new BizException("标题不能为空");
        }

        // 文件名：时间戳 + 随机串 + 原扩展名，避免中文和重名
        String original = file.getOriginalFilename();
        String ext = "";
        if (original != null && original.contains(".")) {
            ext = original.substring(original.lastIndexOf("."));
        }
        String fileName = System.currentTimeMillis() + "_" + UUID.randomUUID().toString().substring(0, 8) + ext;

        try {
            Path dir = Path.of(uploadDir);
            Files.createDirectories(dir);
            Path target = dir.resolve(fileName);
            Files.copy(file.getInputStream(), target, StandardCopyOption.REPLACE_EXISTING);
            log.info("视频已保存：{}", target.toAbsolutePath());
        } catch (IOException e) {
            throw new BizException("视频保存失败：" + e.getMessage());
        }

        UserVideo video = new UserVideo();
        video.setUserId(userId);
        video.setTitle(title);
        video.setDescription(description);
        video.setVideoUrl("/videos/" + fileName);
        video.setLikeCount(0);
        video.setViewCount(0);
        video.setStatus(1);
        videoMapper.insert(video);
        return video;
    }

    /** 视频列表（分页，只显示正常状态），填充用户名 */
    public Map<String, Object> list(Integer page, Integer size) {
        int p = page == null || page < 1 ? 1 : page;
        int s = size == null || size < 1 || size > 50 ? 12 : size;
        List<UserVideo> all = videoMapper.selectList(new LambdaQueryWrapper<UserVideo>()
                .eq(UserVideo::getStatus, 1)
                .orderByDesc(UserVideo::getId));
        int total = all.size();
        int from = Math.min((p - 1) * s, total);
        int to = Math.min(from + s, total);
        List<UserVideo> records = new ArrayList<>(all.subList(from, to));
        for (UserVideo v : records) {
            User u = userMapper.selectById(v.getUserId());
            v.setUsername(u == null ? "未知用户" : u.getUsername());
        }
        return Map.of(
                "records", records,
                "total", total,
                "current", p,
                "size", s
        );
    }

    /** 我的视频 */
    public List<UserVideo> myVideos(Long userId) {
        return videoMapper.selectList(new LambdaQueryWrapper<UserVideo>()
                .eq(UserVideo::getUserId, userId)
                .orderByDesc(UserVideo::getId));
    }

    /** 点赞：like_count +1 */
    public Map<String, Object> like(Long videoId) {
        UserVideo v = videoMapper.selectById(videoId);
        if (v == null || v.getStatus() != 1) {
            throw new BizException("视频不存在");
        }
        videoMapper.update(null, new com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper<UserVideo>()
                .eq(UserVideo::getId, videoId)
                .setSql("like_count = like_count + 1"));
        return Map.of("likeCount", (v.getLikeCount() == null ? 0 : v.getLikeCount()) + 1);
    }

    /** 播放量 +1 */
    public void addView(Long videoId) {
        videoMapper.update(null, new com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper<UserVideo>()
                .eq(UserVideo::getId, videoId)
                .setSql("view_count = view_count + 1"));
    }
}
