/* ============================================================
   app.js — 应用入口：路由 + 根组件 + 全局提示
   路由：登录页 / 主页 / 商品页 / 商品详情 / 视频社区 / 订单
   ============================================================ */
(function () {
  const { createApp } = Vue;
  const { createRouter, createWebHashHistory } = VueRouter;

  // 演示模式：自动植入体验登录态，别人点进来无需注册即可玩转全部功能
  const IS_DEMO = !!(window.API && window.API.DEMO);
  if (IS_DEMO) {
    if (!localStorage.getItem('sg_token')) localStorage.setItem('sg_token', 'demo-' + Date.now());
    if (!localStorage.getItem('sg_user')) localStorage.setItem('sg_user', '体验用户');
  } else {
    // 从 DEMO 切回真实后端时，清掉之前植入的假 token，避免带着假 token 请求后端
    const t = localStorage.getItem('sg_token');
    if (t && t.indexOf('demo-') === 0) {
      localStorage.removeItem('sg_token');
      localStorage.removeItem('sg_user');
    }
  }

  // ---------- 路由 ----------
  const routes = [
    { path: '/', redirect: '/login' },
    { path: '/login', component: Pages.Login },
    { path: '/home', component: Pages.Home, meta: { auth: true } },
    { path: '/goods', component: Pages.Goods },
    { path: '/goods/:id', component: Pages.Goods },
    { path: '/video', component: Pages.Video, meta: { auth: true } },
    { path: '/orders', component: Pages.Orders, meta: { auth: true } }
  ];
  const router = createRouter({ history: createWebHashHistory(), routes });

  // 路由守卫：需要登录的页面没 token 就回登录页
  router.beforeEach((to, from, next) => {
    // 演示模式下放开守卫，任意页面都能直达（别人点链接可以随便逛）
    if (IS_DEMO) return next();
    const token = localStorage.getItem('sg_token');
    if (to.meta.auth && !token) return next('/login');
    if (to.path === '/login' && token) return next('/home');
    next();
  });

  // ---------- 根组件 ----------
  const App = {
    components: {
      CouponFab: Widgets.CouponFab,
      SignFab: Widgets.SignFab,
      CouponPanel: Widgets.CouponPanel,
      SignPanel: Widgets.SignPanel
    },
    data() { return { toast: null, user: localStorage.getItem('sg_user') || '' }; },
    methods: {
      showToast(msg, type) {
        this.toast = { msg, type: type || '' };
        clearTimeout(this._tt);
        this._tt = setTimeout(() => { this.toast = null; }, 2600);
      },
      openSign() { this.$refs.signPanel.open(); },
      logout() {
        API.logout().catch(() => {});
        localStorage.removeItem('sg_token');
        localStorage.removeItem('sg_user');
        this.user = '';
        this.$router.push('/login');
      }
    },
    template: `
      <div>
        <!-- 顶部导航：登录页不显示 -->
        <div class="topbar" v-if="$route.path!=='/login'">
          <div class="container">
            <div class="logo" @click="$router.push('/home')">✦ <b>星幻谷子</b></div>
            <nav class="nav">
              <router-link to="/home">首页</router-link>
              <router-link to="/goods">逛商品</router-link>
              <router-link to="/video">视频社区</router-link>
              <router-link to="/orders">我的订单</router-link>
            </nav>
            <div class="userbox">
              <div class="avatar">{{user?user[0].toUpperCase():'游'}}</div>
              <span class="muted">{{user||'游客'}}</span>
              <button class="btn sm ghost" @click="logout">退出</button>
            </div>
          </div>
        </div>

        <router-view @open-coupon="$refs.couponPanel.open()" @open-sign="openSign"></router-view>

        <!-- 悬浮固定入口：全站可见（登录页隐藏） -->
        <div class="fab-group" v-if="$route.path!=='/login'">
          <coupon-fab></coupon-fab>
          <sign-fab></sign-fab>
        </div>

        <!-- 弹窗面板 -->
        <coupon-panel ref="couponPanel"></coupon-panel>
        <sign-panel ref="signPanel"></sign-panel>

        <!-- 全局提示 -->
        <div class="toast" :class="toast.type" v-if="toast">{{toast.msg}}</div>
      </div>`
  };

  const app = createApp(App);
  // 全局挂载 $toast：每个组件的 this 不同，用一个共享状态对象驱动根组件的 toast
  const toastState = { msg: '', type: '' };
  app.config.globalProperties.$toast = function (msg, type) {
    // 找到根组件实例并显示
    const root = this.$root;
    if (root && root.showToast) root.showToast(msg, type);
  };
  // 商品封面：模板里用 goodsCover(g) 即可（全局属性在模板中自动可用）
  app.config.globalProperties.goodsCover = function (g) {
    return window.goodsCover ? window.goodsCover(g) : '';
  };
  app.use(router);
  app.mount('#app');
})();
