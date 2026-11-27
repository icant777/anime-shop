/* ============================================================
   components.js — 各功能页面组件（Vue3 全局组件，挂载到 window.Pages）
   页面：登录 / 主页 / 商品 / 视频社区 / 订单
   悬浮：领券、签到积分（全站可见）
   ============================================================ */
(function (global) {
  const P = {};

  // ============ 登录 / 注册页（背景视频：login-bg.mp4） ============
  P.Login = {
    template: `
      <div class="login-page">
        <!-- 登录页视频背景：替换视频改 assets/video/login-bg.mp4 -->
        <video class="login-video" src="assets/video/login-bg.mp4" autoplay loop muted playsinline></video>
        <div class="login-overlay"></div>
        <!-- 底部白粉渐变填充：盖住视频自带的黑色地面 -->
        <div class="login-bottom-fill"></div>

        <div class="card glass">
          <div class="brand">
            <div class="mark">✦</div>
            <h1>星幻谷子</h1>
            <p>STAR  GOODS</p>
          </div>
          <div class="form-side">
            <div class="tabs">
              <button :class="{active:mode==='login'}" @click="mode='login'">登录</button>
              <button :class="{active:mode==='reg'}" @click="mode='reg'">注册</button>
            </div>
            <div class="field-row">
              <div class="field">
                <label>账号</label>
                <input v-model="form.username" placeholder="请输入用户名" @keyup.enter="submit">
              </div>
              <div class="field">
                <label>密码</label>
                <input v-model="form.password" type="password" placeholder="请输入密码" @keyup.enter="submit">
              </div>
            </div>
            <div class="field" v-if="mode==='reg'">
              <label>手机号</label>
              <input v-model="form.phone" placeholder="请输入手机号">
            </div>
            <div class="btn-row">
              <button class="btn" @click="submit" :disabled="loading">{{loading?'处理中...':(mode==='login'?'进入星幻':'注册并进入')}}</button>
              <div class="switch">
                <span v-if="mode==='login'">还没有账号？<a @click="mode='reg'">立即注册</a></span>
                <span v-else>已有账号？<a @click="mode='login'">去登录</a></span>
              </div>
            </div>
          </div>
        </div>
        <div class="login-tip">
          <div>欢迎来到 <b>星幻谷子</b> ✦ 你的二次元周边小站</div>
          <div>登录即可购物、领券、签到攒积分</div>
        </div>
      </div>`,
    data() {
      return { mode: 'login', loading: false, form: { username: '', password: '', phone: '' } };
    },
    methods: {
      async submit() {
        if (!this.form.username || !this.form.password) return this.$toast('请填写账号和密码', 'err');
        this.loading = true;
        try {
          let res;
          if (this.mode === 'reg') {
            await API.register(this.form.username, this.form.password, this.form.phone);
            res = await API.login(this.form.username, this.form.password);
          } else {
            res = await API.login(this.form.username, this.form.password);
          }
          localStorage.setItem('sg_token', res.token);
          localStorage.setItem('sg_user', this.form.username);
          this.$toast('欢迎，' + this.form.username + '！', 'ok');
          this.$router.push('/home');
        } catch (e) {
          this.$toast(e.message || '登录失败', 'err');
        } finally {
          this.loading = false;
        }
      }
    }
  };

  // ============ 主页（新品上新 + 贴图占位） ============
  P.Home = {
    template: `
      <div class="container page">
        <!-- 顶部大 Banner：文字/字体/模块大小不变，背景换成 3 张轮播图 -->
        <div class="hero glass">
          <div v-for="(s,i) in slides" :key="i" class="hero-slide"
               :class="{active:i===currentSlide}" :style="{backgroundImage:'url('+s+')'}"></div>
          <div class="hero-shade"></div>
          <button class="hero-arrow prev" @click="prev">‹</button>
          <button class="hero-arrow next" @click="next">›</button>
          <div class="hero-in">
            <span class="tag">✦ NEW ARRIVAL 新品企划</span>
            <h2>把喜欢的<em>角色</em><br>带回你的星球</h2>
            <p>吧唧、立牌、色纸、棉花娃娃…… 全网热门谷子持续上新，登录即享新人专属优惠券与签到积分。</p>
            <button class="btn" @click="$router.push('/goods')">探索新品 →</button>
          </div>
          <div class="hero-dots">
            <button v-for="(s,i) in slides" :key="i" :class="{active:i===currentSlide}" @click="currentSlide=i"></button>
          </div>
        </div>

        <!-- 主页横幅图（保留整张图片上半部分，界面不够大已在 CSS 高度加大到 200px） -->
        <img class="banner-img" src="assets/img/banner.jpg?v=20261127i" alt="主页横幅">

        <div class="quick">
          <div class="q glass" @click="$router.push('/goods')">
            <div class="e">🛍️</div><div class="t">逛商品</div><div class="d">按分类发现好物</div>
          </div>
          <div class="q glass" @click="$emit('open-coupon')">
            <div class="e">🎟️</div><div class="t">领优惠券</div><div class="d">每日好券等你拿</div>
          </div>
          <div class="q glass" @click="$emit('open-sign')">
            <div class="e">⭐</div><div class="t">签到积分</div><div class="d">连续签到有奖励</div>
          </div>
          <div class="q glass" @click="$router.push('/video')">
            <div class="e">🎬</div><div class="t">视频社区</div><div class="d">看开箱·发安利</div>
          </div>
        </div>

        <div class="page-head section-title">新品上新</div>
        <div class="grid" style="margin-top:16px">
          <div class="card-g glass" v-for="g in news" :key="g.id" @click="$router.push('/goods/'+g.id)">
            <div class="thumb">
              <span class="badge tag">NEW</span>
              <img v-if="goodsCover(g)" :src="goodsCover(g)" :alt="g.goodsName">
              <span v-else>🎎</span>
            </div>
            <div class="info">
              <div class="nm">{{g.goodsName}}</div>
              <div class="price"><small>¥</small>{{g.minPrice}}</div>
            </div>
          </div>
        </div>
        <div class="empty" v-if="!news.length">暂无上新商品，快去后台添加吧～</div>
      </div>`,
    data() {
      return {
        news: [],
        slides: ['assets/img/slide1.jpg', 'assets/img/slide2.jpg', 'assets/img/slide3.jpg'],
        currentSlide: 0,
        timer: null
      };
    },
    mounted() {
      API.goodsList({ page: 1, size: 8 }).then(d => { this.news = d.records; }).catch(() => {});
      this.timer = setInterval(() => { this.currentSlide = (this.currentSlide + 1) % this.slides.length; }, 3500);
    },
    beforeUnmount() { clearInterval(this.timer); },
    methods: {
      prev() { this.currentSlide = (this.currentSlide - 1 + this.slides.length) % this.slides.length; },
      next() { this.currentSlide = (this.currentSlide + 1) % this.slides.length; }
    }
  };

  // ============ 商品页（分类切换 + 商品页视频横幅 + 购买详情） ============
  P.Goods = {
    template: `
      <div class="container page">
        <!-- 商品页视频横幅：高度 320px，object-position 聚焦人物上半身，不遮挡商品卡片 -->
        <div class="shop-video-wrap">
          <video class="shop-video" src="assets/video/goods-show.mp4" autoplay loop muted playsinline></video>
          <div class="cap">谷子放映室 <small>✦ 沉浸逛谷 · 每日上新不停</small></div>
        </div>

        <div class="goods-layout">
          <!-- 左侧分类 -->
          <aside class="cat-panel glass">
            <h4>商品分类</h4>
            <button class="cat-item all" :class="{active:currentCat===null}" @click="selectCat(null)">全部商品</button>
            <div v-for="c in cats" :key="c.id">
              <button class="cat-item" :class="{active:currentCat===c.id}" @click="selectCat(c.id)">{{c.name}}</button>
              <button v-for="sub in c.children" :key="sub.id" class="cat-item"
                      :class="{active:currentCat===sub.id}" style="padding-left:26px;font-size:13px"
                      @click="selectCat(sub.id)">· {{sub.categoryName}}</button>
            </div>
          </aside>

          <!-- 右侧商品 -->
          <main class="goods-main">
            <div class="page-head" style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:12px">
              <div class="section-title">{{catName}} <span class="muted" style="font-size:13px;font-weight:400">共 {{total}} 件</span></div>
              <input v-model="keyword" @keyup.enter="load" placeholder="搜索商品名…"
                     style="padding:9px 14px;border-radius:10px;background:var(--glass);border:1px solid var(--glass-line);color:#fff;font-size:13px">
            </div>
            <div class="grid" v-if="list.length">
              <div class="card-g glass" v-for="g in list" :key="g.id" @click="openDetail(g)">
                <div class="thumb">
                  <img v-if="goodsCover(g)" :src="goodsCover(g)" :alt="g.goodsName">
                  <span v-else>🎎</span>
                </div>
                <div class="info">
                  <div class="nm">{{g.goodsName}}</div>
                  <div class="price"><small>¥</small>{{g.minPrice}}</div>
                </div>
              </div>
            </div>
            <div class="empty" v-else>该分类暂无商品，去后台添加几件吧～</div>
          </main>
        </div>

        <!-- 商品详情弹窗 -->
        <div class="mask" v-if="detail" @click.self="detail=null">
          <div class="modal" style="width:min(760px,100%)">
            <h3>商品详情 <span class="x" @click="detail=null">×</span></h3>
            <div class="detail-g">
              <img v-if="goodsCover(detail.goods)" class="detail-cover" :src="goodsCover(detail.goods)" :alt="detail.goods.goodsName">
              <div v-else class="ph big-ph">商品大图贴图位</div>
              <div>
                <div class="tag" style="margin-bottom:8px">{{detail.goods.category||'周边'}}</div>
                <h2 style="font-size:20px;margin-bottom:10px">{{detail.goods.goodsName}}</h2>
                <div class="price" style="color:var(--pink);font-size:26px;font-weight:900;margin-bottom:14px">
                  <small style="font-size:14px">¥</small>{{selectedSku?selectedSku.price:detail.goods.minPrice}}</div>
                <div class="muted" style="font-size:13px;margin-bottom:10px">选择规格 / 品相：</div>
                <div class="sku-row" v-for="s in detail.skus" :key="s.id"
                     :class="{active:selectedSku&&selectedSku.id===s.id}" @click="selectedSku=s">
                  <span>{{s.skuCode}} · {{s.conditionLevelId?'品相'+s.conditionLevelId:'现货'}}</span>
                  <span>¥{{s.price}} <span class="muted" style="font-size:11px">库存{{s.stock}}</span></span>
                </div>
                <div class="qty">数量
                  <button @click="qty>1&&qty--">−</button><span>{{qty}}</span><button @click="qty++">+</button>
                </div>
                <button class="btn" style="width:100%" @click="buy">立即购买 · ¥{{totalPrice}}</button>
              </div>
            </div>
          </div>
        </div>

        <!-- 收货信息弹窗 -->
        <div class="mask" v-if="checkout" @click.self="checkout=false">
          <div class="modal" style="width:min(440px,100%)">
            <h3>确认订单 <span class="x" @click="checkout=false">×</span></h3>
            <div class="field"><label>收货人</label><input v-model="addr.name"></div>
            <div class="field"><label>手机号</label><input v-model="addr.phone"></div>
            <div class="field"><label>收货地址</label><input v-model="addr.addr"></div>
            <button class="btn" style="width:100%" @click="doOrder" :disabled="ordering">{{ordering?'提交中...':'提交订单'}}</button>
          </div>
        </div>
      </div>`,
    data() {
      return { cats: [], currentCat: null, keyword: '', list: [], total: 0,
               detail: null, selectedSku: null, qty: 1, checkout: false, ordering: false,
               addr: { name: '', phone: '', addr: '' } };
    },
    computed: {
      catName() {
        if (this.currentCat === null) return '全部商品';
        for (const c of this.cats) {
          if (c.id === this.currentCat) return c.name;
          for (const s of c.children) if (s.id === this.currentCat) return s.categoryName;
        }
        return '商品列表';
      },
      totalPrice() {
        if (!this.selectedSku) return '0';
        return (Number(this.selectedSku.price) * this.qty).toFixed(2);
      }
    },
    mounted() {
      API.categories().then(d => { this.cats = d; }).catch(() => {});
      this.load();
      // 若路由带商品 id，直接弹详情
      if (this.$route.params.id) {
        API.goodsDetail(this.$route.params.id).then(d => {
          this.detail = d; this.selectedSku = d.skus[0] || null;
        }).catch(() => {});
      }
    },
    methods: {
      load() {
        const p = { page: 1, size: 40 };
        if (this.currentCat !== null) p.categoryId = this.currentCat;
        if (this.keyword) p.keyword = this.keyword;
        API.goodsList(p).then(d => { this.list = d.records; this.total = d.total; }).catch(() => {});
      },
      selectCat(id) { this.currentCat = id; this.load(); },
      openDetail(g) {
        API.goodsDetail(g.id).then(d => {
          this.detail = d; this.selectedSku = d.skus[0] || null; this.qty = 1;
        }).catch(e => this.$toast(e.message, 'err'));
      },
      buy() {
        if (!this.selectedSku) return this.$toast('请选择规格', 'err');
        this.addr.name = localStorage.getItem('sg_user') || '';
        this.checkout = true;
      },
      async doOrder() {
        if (!this.addr.name || !this.addr.phone || !this.addr.addr) return this.$toast('请填完整收货信息', 'err');
        this.ordering = true;
        try {
          const r = await API.placeOrder({
            items: [{ skuId: this.selectedSku.id, quantity: this.qty }],
            receiverName: this.addr.name, receiverPhone: this.addr.phone, receiverAddress: this.addr.addr
          });
          this.checkout = false; this.detail = null;
          this.$toast('下单成功！订单号 ' + (r.orderNo || r.id || ''), 'ok');
          this.load();
        } catch (e) { this.$toast(e.message || '下单失败', 'err'); }
        finally { this.ordering = false; }
      }
    }
  };

  // ============ 视频社区页 ============
  P.Video = {
    template: `
      <div class="container page">
        <div class="page-head section-title">视频社区 <span class="muted" style="font-size:13px">看开箱 · 发安利</span></div>
        <div class="upload-zone glass">
          <div style="font-size:26px;margin-bottom:8px">🎬</div>
          <div style="font-size:13px;margin-bottom:12px">分享你的开箱视频</div>
          <input v-model="title" placeholder="视频标题" style="padding:9px 12px;border-radius:10px;background:var(--glass);border:1px solid var(--glass-line);color:#fff;font-size:13px;width:min(300px,80%);margin-bottom:12px">
          <div><input type="file" ref="file" accept="video/*" style="font-size:12px;color:var(--txt-dim)"></div>
          <button class="btn sm" style="margin-top:12px" @click="publish" :disabled="busy">{{busy?'上传中...':'发布视频'}}</button>
        </div>
        <div class="video-grid" v-if="list.length">
          <div class="video-card glass" v-for="v in list" :key="v.id">
            <video :src="videoUrl(v.videoUrl)" controls preload="metadata" @play="view(v.id)"></video>
            <div class="vi">
              <div class="vt">{{v.title}}</div>
              <div class="vm"><span>@{{v.username||'匿名'}}</span>
                <span>❤ {{v.likeCount||0}} · ▶ {{v.viewCount||0}}</span></div>
              <button class="btn sm ghost" style="margin-top:10px;width:100%" @click="like(v.id)">❤ 点赞</button>
            </div>
          </div>
        </div>
        <div class="empty" v-else>还没有视频，来发第一个吧～</div>
      </div>`,
    data() { return { list: [], title: '', busy: false }; },
    mounted() { this.load(); },
    methods: {
      videoUrl: p => API.videoUrl(p),
      load() { API.videoList({ page: 1, size: 24 }).then(d => { this.list = d.records; }).catch(() => {}); },
      async publish() {
        const f = this.$refs.file.files[0];
        if (!this.title || !f) return this.$toast('请填标题并选择视频', 'err');
        this.busy = true;
        const fd = new FormData();
        fd.append('title', this.title); fd.append('description', ''); fd.append('file', f);
        try {
          await API.videoPublish(fd);
          this.title = ''; this.$refs.file.value = '';
          this.$toast('发布成功', 'ok'); this.load();
        } catch (e) { this.$toast(e.message, 'err'); }
        finally { this.busy = false; }
      },
      async like(id) {
        try { const r = await API.videoLike(id); this.$toast('已点赞 ❤ ' + r.likeCount, 'ok'); this.load(); }
        catch (e) { this.$toast(e.message, 'err'); }
      },
      view(id) { API.videoView(id).catch(() => {}); }
    }
  };

  // ============ 我的订单页 ============
  P.Orders = {
    template: `
      <div class="container page">
        <div class="page-head section-title">我的订单</div>
        <div v-if="list.length" v-for="o in list" :key="o.id" class="coupon glass" style="cursor:default">
          <div style="display:flex;justify-content:space-between;align-items:center">
            <div>
              <div class="n">订单号：{{o.orderNo||o.id}}</div>
              <div class="m">下单时间 {{o.createdAt}} · 状态 {{statusText(o.status)}}</div>
            </div>
            <div style="font-size:18px;font-weight:900;color:var(--pink)">¥{{o.totalAmount}}</div>
          </div>
        </div>
        <div class="empty" v-else>还没有订单，去逛逛吧～</div>
      </div>`,
    data() { return { list: [] }; },
    mounted() { API.myOrders().then(d => { this.list = Array.isArray(d) ? d : (d.records || []); }).catch(() => {}); },
    methods: {
      statusText(s) { return ({ 1: '待付款', 2: '已付款', 3: '已完成', 4: '已取消' })[s] || ('状态' + s); }
    }
  };

  global.Pages = P;
})(window);
