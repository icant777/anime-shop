/* ============================================================
   widgets.js — 悬浮固定组件：领优惠券 + 签到领积分（全站可见）
   无论切换到哪个页面，右下角两个圆钮始终固定显示
   ============================================================ */
(function (global) {
  const W = {};

  // ---------- 优惠券悬浮入口 ----------
  W.CouponFab = {
    template: `
      <div class="fab coupon" @click="open" title="领取优惠券">
        <span class="ico">🎟️</span>
        <span class="lbl">领取优惠券</span>
      </div>`,
    methods: { open() { this.$root.$refs.couponPanel.open(); } }
  };

  // ---------- 签到积分悬浮入口 ----------
  W.SignFab = {
    template: `
      <div class="fab sign" @click="open" title="签到领积分">
        <span class="ico">⭐</span>
        <span class="lbl">签到领积分</span>
        <span class="dot" v-if="!signed">!</span>
      </div>`,
    data() { return { signed: false }; },
    mounted() { this.checkSigned(); },
    methods: {
      checkSigned() {
        API.signinHistory().then(list => {
          const t = new Date().toISOString().slice(0, 10);
          this.signed = (list || []).some(r => (r.signDate || '').slice(0, 10) === t);
        }).catch(() => {});
      },
      open() { this.$root.openSign(); }
    }
  };

  // ---------- 优惠券面板（弹窗） ----------
  W.CouponPanel = {
    template: `
      <div class="mask" v-if="visible" @click.self="visible=false">
        <div class="modal">
          <h3>🎟️ 优惠券中心 <span class="x" @click="visible=false">×</span></h3>
          <div class="tabs">
            <button :class="{active:tab==='avail'}" @click="tab='avail';load()">领券中心</button>
            <button :class="{active:tab==='my'}" @click="tab='my';load()">我的券</button>
          </div>
          <div v-if="tab==='avail'">
            <div class="coupon" v-for="c in list" :key="c.id">
              <div class="v"><small>¥</small>{{c.discountValue}}</div>
              <div class="n">{{c.couponName}}</div>
              <div class="m">满{{c.thresholdAmount}}可用 · 每人限领{{c.perUserLimit||1}}张</div>
              <button class="btn sm" @click="claim(c.id)">领取</button>
            </div>
            <div class="empty center" v-if="!list.length">暂无可领的券</div>
          </div>
          <div v-else>
            <div class="coupon" v-for="c in list" :key="c.id" style="opacity:.85">
              <div class="n">{{c.couponNo}}</div>
              <div class="m">有效期至 {{fmt(c.expireTime)}} · {{statusText(c.status)}}</div>
            </div>
            <div class="empty center" v-if="!list.length">还没有优惠券，去领券中心看看</div>
          </div>
        </div>
      </div>`,
    data() { return { visible: false, tab: 'avail', list: [] }; },
    methods: {
      open() { this.visible = true; this.tab = 'avail'; this.load(); },
      load() {
        if (!localStorage.getItem('sg_token')) { this.$toast('请先登录', 'err'); this.visible = false; return; }
        const p = this.tab === 'avail' ? API.couponAvailable() : API.couponMy();
        p.then(d => { this.list = Array.isArray(d) ? d : []; })
         .catch(e => this.$toast(e.message, 'err'));
      },
      async claim(id) {
        try { const r = await API.couponClaim(id); this.$toast('领取成功：' + r.couponName, 'ok'); this.load(); }
        catch (e) { this.$toast(e.message, 'err'); }
      },
      fmt(t) { return t ? String(t).replace('T', ' ').slice(0, 16) : '-'; },
      statusText(s) { return ({ 1: '未使用', 2: '已使用', 3: '已过期', 4: '已作废' })[s] || s; }
    }
  };

  // ---------- 签到积分面板（弹窗） ----------
  W.SignPanel = {
    template: `
      <div class="mask" v-if="visible" @click.self="visible=false">
        <div class="modal">
          <h3>⭐ 签到领积分 <span class="x" @click="visible=false">×</span></h3>
          <div class="point-hero">
            <div class="num">{{account?account.balance:0}}</div>
            <div class="lb">当前积分 · 累计获得 {{account?account.totalEarned:0}}</div>
          </div>
          <button class="btn" style="width:100%;margin-bottom:18px" @click="sign" :disabled="signing">
            {{signing?'签到中...':(signed?'今日已签到 ✓':'签到 +5 积分')}}
          </button>
          <div class="section-title" style="font-size:15px">积分流水</div>
          <div style="margin-top:10px">
            <div class="rec" v-for="r in records" :key="r.id">
              <span>{{r.remark||r.bizType}}</span>
              <span :class="r.changeType===1?'plus':'minus'">{{r.changeType===1?'+':''}}{{r.points}}</span>
            </div>
            <div class="empty center" v-if="!records.length">暂无积分记录</div>
          </div>
        </div>
      </div>`,
    data() { return { visible: false, signing: false, signed: false, account: null, records: [] }; },
    methods: {
      open() {
        this.visible = true;
        if (!localStorage.getItem('sg_token')) { this.$toast('请先登录', 'err'); this.visible = false; return; }
        this.load();
      },
      load() {
        API.pointAccount().then(d => { this.account = d; }).catch(() => {});
        API.pointRecords().then(d => { this.records = Array.isArray(d) ? d : []; }).catch(() => {});
        API.signinHistory().then(list => {
          const t = new Date().toISOString().slice(0, 10);
          this.signed = (list || []).some(r => (r.signDate || '').slice(0, 10) === t);
        }).catch(() => {});
      },
      async sign() {
        this.signing = true;
        try {
          const r = await API.signin();
          this.$toast('签到成功 +' + r.pointsEarned + ' 积分（连续' + r.continuousDays + '天）', 'ok');
          this.signed = true; this.load();
        } catch (e) { this.$toast(e.message, 'err'); }
        finally { this.signing = false; }
      }
    }
  };

  global.Widgets = W;
})(window);
