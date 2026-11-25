package com.anime.backend.service;

import com.anime.backend.common.BizException;
import com.anime.backend.entity.PointRecord;
import com.anime.backend.entity.UserPointAccount;
import com.anime.backend.mapper.PointRecordMapper;
import com.anime.backend.mapper.UserPointAccountMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.stereotype.Service;

/**
 * 积分服务：账户 + 流水统一入口。
 * 用乐观锁（version）更新账户，防止并发签到/兑换把积分扣成负数。
 * 下单发积分、签到发积分都走这里的 change()。
 */
@Service
@RequiredArgsConstructor
public class PointService {

    private final UserPointAccountMapper accountMapper;
    private final PointRecordMapper recordMapper;

    /** 初始化账户（没有就建一条 0 分账户） */
    public UserPointAccount ensureAccount(Long userId) {
        UserPointAccount acc = accountMapper.selectOne(
                new LambdaQueryWrapper<UserPointAccount>().eq(UserPointAccount::getUserId, userId));
        if (acc == null) {
            acc = new UserPointAccount();
            acc.setUserId(userId);
            acc.setBalance(0);
            acc.setFrozenPoint(0);
            acc.setTotalEarned(0);
            acc.setTotalUsed(0);
            acc.setTotalExpired(0);
            acc.setLevel(1);
            acc.setVersion(0);
            accountMapper.insert(acc);
        }
        return acc;
    }

    /**
     * 积分变动（正数增加、负数扣减）
     * @param changeType 1签到 2消费获得 3兑换抵扣 4过期 5后台调整 6邀请
     * @param points     变动值
     * @param bizType    signin/order/exchange
     * @param bizNo      业务单号
     * @param remark     说明
     * @return 变动后的余额
     */
    @CacheEvict(cacheNames = "pointAccount", key = "#userId")
    public int change(Long userId, int changeType, int points, String bizType, String bizNo, String remark) {
        UserPointAccount acc = ensureAccount(userId);

        int newBalance = acc.getBalance() + points;
        if (newBalance < 0) {
            throw new BizException("积分不足");
        }

        int newEarned = acc.getTotalEarned() + Math.max(points, 0);
        int newUsed = acc.getTotalUsed() + Math.max(-points, 0);

        // 乐观锁：WHERE id=? AND version=?，版本不匹配说明并发改过，重试一次
        LambdaUpdateWrapper<UserPointAccount> uw = new LambdaUpdateWrapper<>();
        uw.eq(UserPointAccount::getId, acc.getId())
          .eq(UserPointAccount::getVersion, acc.getVersion())
          .set(UserPointAccount::getBalance, newBalance)
          .set(UserPointAccount::getTotalEarned, newEarned)
          .set(UserPointAccount::getTotalUsed, newUsed)
          .set(UserPointAccount::getVersion, acc.getVersion() + 1);

        int rows = accountMapper.update(null, uw);
        if (rows == 0) {
            // 并发冲突：重新读一次再改（简单重试一次，够教学场景）
            UserPointAccount fresh = accountMapper.selectById(acc.getId());
            LambdaUpdateWrapper<UserPointAccount> uw2 = new LambdaUpdateWrapper<>();
            int bal2 = fresh.getBalance() + points;
            if (bal2 < 0) {
                throw new BizException("积分不足");
            }
            uw2.eq(UserPointAccount::getId, fresh.getId())
               .eq(UserPointAccount::getVersion, fresh.getVersion())
               .set(UserPointAccount::getBalance, bal2)
               .set(UserPointAccount::getTotalEarned, fresh.getTotalEarned() + Math.max(points, 0))
               .set(UserPointAccount::getTotalUsed, fresh.getTotalUsed() + Math.max(-points, 0))
               .set(UserPointAccount::getVersion, fresh.getVersion() + 1);
            if (accountMapper.update(null, uw2) == 0) {
                throw new BizException("积分更新冲突，请重试");
            }
            newBalance = bal2;
        }

        PointRecord rec = new PointRecord();
        rec.setUserId(userId);
        rec.setChangeType(changeType);
        rec.setPoints(points);
        rec.setBalanceAfter(newBalance);
        rec.setBizType(bizType);
        rec.setBizNo(bizNo);
        rec.setRemark(remark);
        recordMapper.insert(rec);

        return newBalance;
    }
}
