package com.anime.backend.service;

import com.anime.backend.common.BizException;
import com.anime.backend.entity.PointRecord;
import com.anime.backend.entity.SigninRecord;
import com.anime.backend.entity.UserPointAccount;
import com.anime.backend.mapper.PointRecordMapper;
import com.anime.backend.mapper.SigninRecordMapper;
import com.anime.backend.mapper.UserPointAccountMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 签到服务：每天签一次，连续签到额外奖励。
 * 基础 +5 分；连续每满 7 天额外 +10。
 */
@Service
@RequiredArgsConstructor
public class SigninService {

    private final SigninRecordMapper signinMapper;
    private final PointRecordMapper pointRecordMapper;
    private final UserPointAccountMapper accountMapper;
    private final PointService pointService;

    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> signin(Long userId) {
        LocalDate today = LocalDate.now();

        // 唯一键防重复：今天已签直接拒绝
        Long exists = signinMapper.selectCount(new LambdaQueryWrapper<SigninRecord>()
                .eq(SigninRecord::getUserId, userId)
                .eq(SigninRecord::getSignDate, today));
        if (exists != null && exists > 0) {
            throw new BizException("今天已经签到过了");
        }

        // 算连续天数：找昨天或最近一次的签到记录
        SigninRecord last = signinMapper.selectOne(new LambdaQueryWrapper<SigninRecord>()
                .eq(SigninRecord::getUserId, userId)
                .lt(SigninRecord::getSignDate, today)
                .orderByDesc(SigninRecord::getSignDate)
                .last("limit 1"));

        int continuous = 1;
        if (last != null && last.getSignDate() != null) {
            long gap = java.time.temporal.ChronoUnit.DAYS.between(last.getSignDate(), today);
            if (gap == 1) {
                continuous = (last.getContinuousDays() == null ? 0 : last.getContinuousDays()) + 1;
            }
            // gap > 1 断了，continuous 重置为 1
        }

        int base = 5;
        int bonus = (continuous > 0 && continuous % 7 == 0) ? 10 : 0;
        int total = base + bonus;

        SigninRecord rec = new SigninRecord();
        rec.setUserId(userId);
        rec.setSignDate(today);
        rec.setContinuousDays(continuous);
        rec.setPointsEarned(total);
        rec.setSource(1); // APP
        signinMapper.insert(rec);

        // 发积分（账户 + 流水），change_type=1 签到
        pointService.change(userId, 1, total, "signin", today.toString(),
                "连续签到第" + continuous + "天 +" + base + (bonus > 0 ? "，额外 +" + bonus : ""));

        Map<String, Object> result = new HashMap<>();
        result.put("signDate", today.toString());
        result.put("continuousDays", continuous);
        result.put("pointsEarned", total);
        return result;
    }

    /** 我的签到历史 */
    public List<SigninRecord> history(Long userId) {
        return signinMapper.selectList(new LambdaQueryWrapper<SigninRecord>()
                .eq(SigninRecord::getUserId, userId)
                .orderByDesc(SigninRecord::getSignDate));
    }

    /** 积分账户（缓存 10 分钟；积分变动时由 PointService.change 清缓存） */
    @Cacheable(cacheNames = "pointAccount", key = "#userId")
    public UserPointAccount account(Long userId) {
        return pointService.ensureAccount(userId);
    }

    /** 积分流水 */
    public List<PointRecord> pointRecords(Long userId) {
        return pointRecordMapper.selectList(new LambdaQueryWrapper<PointRecord>()
                .eq(PointRecord::getUserId, userId)
                .orderByDesc(PointRecord::getId));
    }
}
