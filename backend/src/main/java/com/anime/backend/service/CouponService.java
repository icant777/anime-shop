package com.anime.backend.service;

import com.anime.backend.common.BizException;
import com.anime.backend.entity.CouponTemplate;
import com.anime.backend.entity.UserCoupon;
import com.anime.backend.mapper.CouponTemplateMapper;
import com.anime.backend.mapper.UserCouponMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/** 优惠券服务：可领列表、领取、我的券 */
@Service
@RequiredArgsConstructor
public class CouponService {

    private final CouponTemplateMapper templateMapper;
    private final UserCouponMapper userCouponMapper;

    /** 可领取的券：状态启用、在领取时间窗内、未领完 */
    public List<CouponTemplate> available() {
        LocalDateTime now = LocalDateTime.now();
        return templateMapper.selectList(new LambdaQueryWrapper<CouponTemplate>()
                .eq(CouponTemplate::getStatus, 1)
                .le(CouponTemplate::getStartTime, now)
                .ge(CouponTemplate::getEndTime, now)
                .orderByDesc(CouponTemplate::getId));
    }

    /** 领取优惠券：校验限领 + 库存，生成券码，claimed_count+1 */
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> claim(Long userId, Long templateId) {
        CouponTemplate t = templateMapper.selectById(templateId);
        if (t == null || t.getStatus() != 1) {
            throw new BizException("优惠券不存在或已停用");
        }
        LocalDateTime now = LocalDateTime.now();
        if (now.isBefore(t.getStartTime()) || now.isAfter(t.getEndTime())) {
            throw new BizException("不在领取时间内");
        }
        if (t.getTotalCount() != null && t.getTotalCount() > 0
                && t.getClaimedCount() >= t.getTotalCount()) {
            throw new BizException("券已被领完");
        }

        // 每人限领：统计该用户已领这张模板的数量（未作废）
        Long claimed = userCouponMapper.selectCount(new LambdaQueryWrapper<UserCoupon>()
                .eq(UserCoupon::getUserId, userId)
                .eq(UserCoupon::getTemplateId, templateId)
                .ne(UserCoupon::getStatus, 4));
        int limit = t.getPerUserLimit() == null ? 1 : t.getPerUserLimit();
        if (claimed != null && claimed >= limit) {
            throw new BizException("每人限领 " + limit + " 张，你已领过");
        }

        // 有效期：领取后 valid_days 天；valid_days=0 用固定到期时间
        LocalDateTime expire = (t.getValidDays() != null && t.getValidDays() > 0)
                ? now.plusDays(t.getValidDays())
                : t.getFixedExpireTime();
        if (expire == null) {
            expire = now.plusDays(7);
        }

        UserCoupon uc = new UserCoupon();
        uc.setUserId(userId);
        uc.setTemplateId(templateId);
        uc.setCouponNo("CP" + UUID.randomUUID().toString().replace("-", "").substring(0, 16).toUpperCase());
        uc.setStatus(1);
        uc.setExpireTime(expire);
        userCouponMapper.insert(uc);

        // claimed_count +1（条件更新：未超总量）
        LambdaUpdateWrapper<CouponTemplate> uw = new LambdaUpdateWrapper<>();
        uw.eq(CouponTemplate::getId, templateId)
          .setSql("claimed_count = claimed_count + 1");
        templateMapper.update(null, uw);

        Map<String, Object> result = new HashMap<>();
        result.put("couponNo", uc.getCouponNo());
        result.put("couponName", t.getCouponName());
        result.put("expireTime", expire);
        return result;
    }

    /** 我的券：可按状态筛选（1未用 2已用 3过期 4作废），自动把过期未用的标记过期 */
    public List<UserCoupon> myCoupons(Long userId, Integer status) {
        // 把已过期但状态还是"未使用"的，更新为过期
        userCouponMapper.update(null, new LambdaUpdateWrapper<UserCoupon>()
                .eq(UserCoupon::getUserId, userId)
                .eq(UserCoupon::getStatus, 1)
                .lt(UserCoupon::getExpireTime, LocalDateTime.now())
                .set(UserCoupon::getStatus, 3));

        LambdaQueryWrapper<UserCoupon> qw = new LambdaQueryWrapper<UserCoupon>()
                .eq(UserCoupon::getUserId, userId);
        if (status != null) {
            qw.eq(UserCoupon::getStatus, status);
        }
        qw.orderByDesc(UserCoupon::getId);
        return userCouponMapper.selectList(qw);
    }
}
