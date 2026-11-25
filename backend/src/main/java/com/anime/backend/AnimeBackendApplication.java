package com.anime.backend;

import org.apache.ibatis.annotations.Mapper;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;

/**
 * 动漫商城后端启动类
 * - @MapperScan 只扫带 @Mapper 的接口，避免把别的 bean 当 Mapper
 * - @EnableCaching 开启 @Cacheable / @CacheEvict
 */
@SpringBootApplication
@EnableCaching
@MapperScan(basePackages = "com.anime.backend.mapper", annotationClass = Mapper.class)
public class AnimeBackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(AnimeBackendApplication.class, args);
    }
}
