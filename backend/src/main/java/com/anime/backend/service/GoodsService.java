package com.anime.backend.service;

import com.anime.backend.common.BizException;
import com.anime.backend.entity.Goods;
import com.anime.backend.entity.GoodsCategory;
import com.anime.backend.entity.GoodsConditionRel;
import com.anime.backend.mapper.GoodsCategoryMapper;
import com.anime.backend.mapper.GoodsConditionRelMapper;
import com.anime.backend.mapper.GoodsMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import java.util.*;

/** 商品服务：列表 / 详情 / 分类树（详情和分类树进 Redis 缓存） */
@Service
@RequiredArgsConstructor
public class GoodsService {

    private final GoodsMapper goodsMapper;
    private final GoodsCategoryMapper categoryMapper;
    private final GoodsConditionRelMapper skuMapper;

    /** 商品列表：只显示上架(status=1)、未删除(deleted=0)，可按 categoryId 筛选，分页 */
    public Map<String, Object> list(Integer page, Integer size, Long categoryId, String keyword) {
        int p = page == null || page < 1 ? 1 : page;
        int s = size == null || size < 1 || size > 50 ? 12 : size;

        LambdaQueryWrapper<Goods> qw = new LambdaQueryWrapper<>();
        qw.eq(Goods::getStatus, 1).eq(Goods::getDeleted, 0);
        if (categoryId != null) {
            // 若传的是一级分类，带出它下面所有二级分类的商品（前端点大类时不应为空）
            List<GoodsCategory> children = categoryMapper.selectList(
                    new LambdaQueryWrapper<GoodsCategory>()
                            .eq(GoodsCategory::getParentId, categoryId)
                            .eq(GoodsCategory::getStatus, 1));
            if (children != null && !children.isEmpty()) {
                List<Long> ids = new ArrayList<>();
                ids.add(categoryId);
                for (GoodsCategory c : children) ids.add(c.getId());
                qw.in(Goods::getCategoryId, ids);
            } else {
                qw.eq(Goods::getCategoryId, categoryId);
            }
        }
        if (keyword != null && !keyword.isBlank()) {
            qw.like(Goods::getGoodsName, keyword);
        }
        qw.orderByDesc(Goods::getId);

        // 不依赖分页插件：先查全部，再内存分页（教学项目数据量小，够用且稳）
        List<Goods> all = goodsMapper.selectList(qw);
        int total = all.size();
        int from = Math.min((p - 1) * s, total);
        int to = Math.min(from + s, total);
        List<Goods> records = all.subList(from, to);
        return Map.of(
                "records", records,
                "total", total,
                "current", p,
                "size", s
        );
    }

    /** 商品详情 + SKU 列表，缓存 10 分钟（管理端改商品时需 @CacheEvict，见 OrderService） */
    @Cacheable(cacheNames = "goodsDetail", key = "#id")
    public Map<String, Object> detail(Long id) {
        Goods goods = goodsMapper.selectById(id);
        if (goods == null || (goods.getDeleted() != null && goods.getDeleted() == 1)) {
            throw new BizException("商品不存在或已下架");
        }
        List<GoodsConditionRel> skus = skuMapper.selectList(
                new LambdaQueryWrapper<GoodsConditionRel>()
                        .eq(GoodsConditionRel::getGoodsId, id)
                        .eq(GoodsConditionRel::getStatus, 1)
                        .orderByAsc(GoodsConditionRel::getId));
        Map<String, Object> result = new HashMap<>();
        result.put("goods", goods);
        result.put("skus", skus);
        return result;
    }

    /** 分类树：一级 + 二级，缓存 10 分钟 */
    @Cacheable(cacheNames = "goodsCategoryTree", key = "'tree'")
    public List<Map<String, Object>> categoryTree() {
        List<GoodsCategory> all = categoryMapper.selectList(
                new LambdaQueryWrapper<GoodsCategory>()
                        .eq(GoodsCategory::getStatus, 1)
                        .orderByAsc(GoodsCategory::getLevel)
                        .orderByAsc(GoodsCategory::getSortNo));

        Map<Long, List<GoodsCategory>> children = new HashMap<>();
        List<GoodsCategory> roots = new ArrayList<>();
        for (GoodsCategory c : all) {
            if (c.getParentId() == null || c.getParentId() == 0) {
                roots.add(c);
            } else {
                children.computeIfAbsent(c.getParentId(), k -> new ArrayList<>()).add(c);
            }
        }
        List<Map<String, Object>> tree = new ArrayList<>();
        for (GoodsCategory root : roots) {
            Map<String, Object> node = new HashMap<>();
            node.put("id", root.getId());
            node.put("name", root.getCategoryName());
            node.put("code", root.getCategoryCode());
            node.put("children", children.getOrDefault(root.getId(), Collections.emptyList()));
            tree.add(node);
        }
        return tree;
    }
}
