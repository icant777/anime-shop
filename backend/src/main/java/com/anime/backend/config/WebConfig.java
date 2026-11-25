package com.anime.backend.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.file.Path;

/**
 * 把本地上传目录映射成可访问的 URL：
 * http://localhost:9091/videos/xxx.mp4  ->  D:/webAi/anime-backend/uploads/video/xxx.mp4
 */
@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Value("${app.video-upload-dir}")
    private String uploadDir;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        String location = Path.of(uploadDir).toUri().toString();
        registry.addResourceHandler("/videos/**").addResourceLocations(location);
    }

    /** 允许前端独立端口跨域访问（Vue 开发服务器 / 静态页面） */
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOriginPatterns("*")
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .exposedHeaders("token")
                .allowCredentials(true)
                .maxAge(3600);
    }
}
