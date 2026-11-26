/* ============================================================
   api.js — 后端接口封装 + 演示模式
   ------------------------------------------------------------
   本地（localhost:5500）→ 连 http://<host>:9091 真实后端
   线上（云服务器域名/IP）→ 走同源相对路径，由 Nginx 把 /api 反代到后端
   只有手动加 ?demo=1 才进入 DEMO 假数据模式（纯展示用）。
   也可在 index.html 里设 window.API_BASE 覆盖默认判定。
   ============================================================ */
(function (global) {
  const host = location.hostname;
  const isLocal = host === 'localhost' || host === '127.0.0.1' ||
    /^192\.168\.|^10\.|^172\.(1[6-9]|2\d|3[01])\./.test(host);
  // API 根地址：window.API_BASE 优先 → 本地 :9091 → 线上同源（Nginx 反代）
  const BASE = (typeof global.API_BASE === 'string' && global.API_BASE)
    ? global.API_BASE
    : (isLocal ? 'http://' + host + ':9091' : '');

  // ---------- 演示模式判定 ----------
  // 只有 ?demo=1 才用假数据；线上默认连真实后端
  const DEMO = /[?&]demo=1/.test(location.search);

  const http = axios.create({ baseURL: BASE, timeout: 15000 });
  http.interceptors.request.use(cfg => {
    const token = localStorage.getItem('sg_token');
    if (token) cfg.headers['token'] = token;
    return cfg;
  });
  http.interceptors.response.use(
    res => {
      const body = res.data;
      if (body && body.code !== undefined) {
        if (body.code === 200) return body.data;
        const err = new Error(body.msg || '请求失败');
        err.code = body.code;
        return Promise.reject(err);
      }
      return body;
    },
    err => Promise.reject(err)
  );

  // ============================================================
  //  演示数据（字段结构与真实后端一致）
  // ============================================================
  const goodsSeed = [
    { id: 1, goodsCode: 'G-001', goodsName: '鬼灭之刃·炭治郎 亚克力立牌', category: '立牌', categoryId: 201, minPrice: 39.9, images: '["assets/img/tanjiro.jpg"]' },
    { id: 2, goodsCode: 'G-002', goodsName: '初音未来 限定吧唧套装', category: '吧唧', categoryId: 202, minPrice: 25.0, images: '["assets/img/miku.jpg"]' },
    { id: 3, goodsCode: 'G-003', goodsName: '原神·胡桃 色纸签名板', category: '色纸', categoryId: 203, minPrice: 58.0, images: '[]' },
    { id: 4, goodsCode: 'G-004', goodsName: '咒术回战·五条悟 棉花娃娃', category: '棉花娃娃', categoryId: 204, minPrice: 89.9, images: '[]' },
    { id: 5, goodsCode: 'G-005', goodsName: '海贼王·路飞 景品手办', category: '手办', categoryId: 205, minPrice: 168.0, images: '[]' },
    { id: 6, goodsCode: 'G-006', goodsName: '崩坏·星穹铁道 痛包', category: '痛包', categoryId: 206, minPrice: 128.0, images: '[]' },
    { id: 7, goodsCode: 'G-007', goodsName: '排球少年·日向 亚克力挂件', category: '立牌', categoryId: 208, minPrice: 32.0, images: '[]' },
    { id: 8, goodsCode: 'G-008', goodsName: '间谍过家家·阿尼亚 一番赏', category: '周边', categoryId: 207, minPrice: 68.0, images: '[]' },
    // ===== 补货：每个分类补足到至少 3 件（商品名取自网上真实在售动漫周边） =====
    // 立牌（201 亚克力立牌 / 208 亚克力挂件）
    { id: 9, goodsCode: 'G-009', goodsName: '咒术回战 霓虹系列 亚克力立牌', category: '立牌', categoryId: 201, minPrice: 45.0, images: '[]' },
    { id: 10, goodsCode: 'G-010', goodsName: '原神 六周年庆典 亚克力立牌', category: '立牌', categoryId: 201, minPrice: 59.0, images: '[]' },
    // 吧唧（202 马口铁吧唧）
    { id: 11, goodsCode: 'G-011', goodsName: '原神 破格锋镞系列 马口铁徽章', category: '吧唧', categoryId: 202, minPrice: 18.0, images: '[]' },
    { id: 12, goodsCode: 'G-012', goodsName: '咒术回战 横滨5周年 闪粉收藏徽章', category: '吧唧', categoryId: 202, minPrice: 22.0, images: '[]' },
    // 色纸（203 签名色纸）
    { id: 13, goodsCode: 'G-013', goodsName: '原神 无神怜爱的雪国 亚克力色纸', category: '色纸', categoryId: 203, minPrice: 58.0, images: '[]' },
    { id: 14, goodsCode: 'G-014', goodsName: '初音未来 日巡米山舞 联动色纸', category: '色纸', categoryId: 203, minPrice: 52.0, images: '[]' },
    // 棉花娃娃（204 正常体娃娃）
    { id: 15, goodsCode: 'G-015', goodsName: '原神 胡桃 40cm棉花娃娃', category: '棉花娃娃', categoryId: 204, minPrice: 119.0, images: '[]' },
    { id: 16, goodsCode: 'G-016', goodsName: '排球少年 日向翔阳 10cm棉花娃娃挂件', category: '棉花娃娃', categoryId: 204, minPrice: 49.9, images: '[]' },
    // 手办（205 景品手办）
    { id: 17, goodsCode: 'G-017', goodsName: 'FURYU 初音未来 泡面压景品手办', category: '手办', categoryId: 205, minPrice: 83.3, images: '[]' },
    { id: 18, goodsCode: 'G-018', goodsName: '原神 蒙德城主题 粘土人 凯亚', category: '手办', categoryId: 205, minPrice: 329.0, images: '[]' },
    // 周边（痛包 206 / 一番赏 207）
    { id: 19, goodsCode: 'G-019', goodsName: '初音未来 Spark系列 多功能收纳痛包', category: '痛包', categoryId: 206, minPrice: 128.0, images: '[]' },
    { id: 20, goodsCode: 'G-020', goodsName: 'bilibili 一番赏 初音未来 抽赏', category: '周边', categoryId: 207, minPrice: 28.0, images: '[]' }
  ];
  const categoriesSeed = [
    { id: 1, name: '立牌', children: [{ id: 201, categoryName: '亚克力立牌' }, { id: 208, categoryName: '亚克力挂件' }] },
    { id: 2, name: '吧唧', children: [{ id: 202, categoryName: '马口铁吧唧' }] },
    { id: 3, name: '色纸', children: [{ id: 203, categoryName: '签名色纸' }] },
    { id: 4, name: '棉花娃娃', children: [{ id: 204, categoryName: '正常体娃娃' }] },
    { id: 5, name: '手办', children: [{ id: 205, categoryName: '景品手办' }] },
    { id: 6, name: '周边', children: [{ id: 206, categoryName: '痛包' }, { id: 207, categoryName: '一番赏' }] }
  ];
  const couponSeed = [
    { id: 1, couponName: '新人专享券', discountValue: 10, thresholdAmount: 50, perUserLimit: 1 },
    { id: 2, couponName: '满百减二十', discountValue: 20, thresholdAmount: 100, perUserLimit: 2 },
    { id: 3, couponName: '谷子狂欢券', discountValue: 5, thresholdAmount: 30, perUserLimit: 3 }
  ];
  const videoSeed = [
    { id: 1, title: '炭治郎立牌开箱！做工太精致了', videoUrl: '/videos/demo.mp4', username: '星幻用户', likeCount: 42, viewCount: 318 },
    { id: 2, title: '我的谷子收纳展示 ✦ 桌面改造', videoUrl: '/videos/demo.mp4', username: '谷子控', likeCount: 28, viewCount: 205 },
    { id: 3, title: '初音吧唧现货拆箱，血赚！', videoUrl: '/videos/demo.mp4', username: 'Miku粉丝', likeCount: 65, viewCount: 512 }
  ];

  const state = {
    claimed: false, myCoupons: [], signed: false,
    balance: 20, totalEarned: 20, pointsSeq: 2, orderSeq: 1,
    points: [{ id: 1, remark: '新人注册奖励', bizType: 'REGISTER', changeType: 1, points: 20 }],
    videos: JSON.parse(JSON.stringify(videoSeed)), orders: []
  };
  const wait = ms => new Promise(r => setTimeout(r, ms === undefined ? 160 : ms));
  const today = () => { const d = new Date(); return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0'); };

  const demo = {
    register: async () => { await wait(); return { id: 1 }; },
    login: async (u) => { await wait(); return { token: 'demo-' + Date.now(), username: u }; },
    check: async () => ({ loggedIn: !!localStorage.getItem('sg_token') }),
    me: async () => ({ id: 1, username: localStorage.getItem('sg_user') || '演示用户' }),
    logout: async () => true,
    categories: async () => categoriesSeed,
    goodsList: async (p) => {
      await wait(); p = p || {};
      let arr = goodsSeed.slice();
      if (p.categoryId) {
        const parent = categoriesSeed.find(c => c.id === p.categoryId);
        if (parent) { const subs = parent.children.map(c => c.id); arr = arr.filter(g => subs.indexOf(g.categoryId) >= 0); }
        else arr = arr.filter(g => g.categoryId === p.categoryId);
      }
      if (p.keyword) arr = arr.filter(g => g.goodsName.indexOf(p.keyword) >= 0);
      const size = p.size || 40, page = p.page || 1;
      return { records: arr.slice((page - 1) * size, page * size), total: arr.length, current: page, size: size };
    },
    goodsDetail: async (id) => {
      await wait();
      const g = goodsSeed.find(x => x.id === Number(id)) || goodsSeed[0];
      return { goods: g, skus: [
        { id: g.id * 10 + 1, skuCode: g.goodsCode + '-M', price: g.minPrice, stock: 66, conditionLevelId: 1 },
        { id: g.id * 10 + 2, skuCode: g.goodsCode + '-NM', price: (Number(g.minPrice) * 0.85).toFixed(2), stock: 23, conditionLevelId: 2 }
      ] };
    },
    placeOrder: async (body) => {
      await wait(400);
      const amount = (body.items || []).reduce((s, it) => s + (it.price || 39.9) * (it.quantity || 1), 0) || 39.9;
      const orderNo = 'DEMO' + Date.now();
      state.orders.unshift({ id: state.orderSeq++, orderNo, totalAmount: Number(amount.toFixed(2)), status: 2, createdAt: new Date().toLocaleString() });
      const add = Math.floor(amount);
      state.balance += add; state.totalEarned += add;
      state.points.unshift({ id: state.pointsSeq++, remark: '购物奖励', bizType: 'ORDER', changeType: 1, points: add });
      return { orderNo, id: state.orderSeq - 1 };
    },
    myOrders: async () => { await wait(); return state.orders; },
    orderDetail: async (id) => state.orders.find(o => o.id === Number(id)) || state.orders[0] || {},
    couponAvailable: async () => { await wait(); return couponSeed.slice(); },
    couponMy: async () => { await wait(); return state.myCoupons; },
    couponClaim: async (id) => {
      await wait();
      const c = couponSeed.find(x => x.id === Number(id)) || couponSeed[0];
      const uc = { id: Date.now(), couponNo: 'CP' + Date.now(), couponName: c.couponName, status: 1, expireTime: new Date(Date.now() + 30 * 864e5).toISOString() };
      state.myCoupons.unshift(uc); return uc;
    },
    signin: async () => {
      await wait(); state.signed = true;
      state.balance += 5; state.totalEarned += 5;
      state.points.unshift({ id: state.pointsSeq++, remark: '每日签到', bizType: 'SIGNIN', changeType: 1, points: 5 });
      return { pointsEarned: 5, continuousDays: 3 };
    },
    pointAccount: async () => ({ balance: state.balance, totalEarned: state.totalEarned, totalUsed: 0 }),
    pointRecords: async () => state.points.slice(),
    signinHistory: async () => state.signed ? [{ id: 1, signDate: today(), continuousDays: 3 }] : [],
    videoList: async (p) => { await wait(); const size = (p && p.size) || 24; return { records: state.videos.slice(0, size), total: state.videos.length, current: 1, size }; },
    videoPublish: async (fd) => {
      await wait(500);
      const v = { id: Date.now(), title: fd.get('title') || '我的视频', videoUrl: '/videos/demo.mp4', username: localStorage.getItem('sg_user') || '我', likeCount: 0, viewCount: 0 };
      state.videos.unshift(v); return v;
    },
    videoMy: async () => state.videos.slice(),
    videoLike: async (id) => { await wait(); const v = state.videos.find(x => x.id === Number(id)); if (v) v.likeCount = (v.likeCount || 0) + 1; return { likeCount: v ? v.likeCount : 1 }; },
    videoView: async (id) => { const v = state.videos.find(x => x.id === Number(id)); if (v) v.viewCount = (v.viewCount || 0) + 1; return {}; },
    videoUrl: () => 'assets/video/goods-show.mp4'
  };

  // 真实后端实现
  const real = {
    register: (username, password, phone) => http.post('/api/user/register', { username, password, phone }),
    login: (username, password) => http.post('/api/user/login', { username, password }),
    check: () => http.get('/api/user/check'),
    me: () => http.get('/api/user/me'),
    logout: () => http.post('/api/user/logout'),
    goodsList: (params) => http.get('/api/goods/list', { params }),
    goodsDetail: (id) => http.get('/api/goods/detail/' + id),
    categories: () => http.get('/api/goods/categories'),
    placeOrder: (body) => http.post('/api/order/place', body),
    myOrders: () => http.get('/api/order/my'),
    orderDetail: (id) => http.get('/api/order/detail/' + id),
    couponAvailable: () => http.get('/api/coupon/available'),
    couponClaim: (templateId) => http.post('/api/coupon/claim/' + templateId),
    couponMy: (status) => http.get('/api/coupon/my', { params: { status } }),
    signin: () => http.post('/api/point/signin'),
    pointAccount: () => http.get('/api/point/account'),
    pointRecords: () => http.get('/api/point/records'),
    signinHistory: () => http.get('/api/point/history'),
    videoPublish: (formData) => http.post('/api/video/publish', formData, { headers: { 'Content-Type': 'multipart/form-data' } }),
    videoList: (params) => http.get('/api/video/list', { params }),
    videoMy: () => http.get('/api/video/my'),
    videoLike: (id) => http.post('/api/video/like/' + id),
    videoView: (id) => http.post('/api/video/view/' + id),
    videoUrl: (path) => path ? (BASE + path) : ''
  };

  const api = DEMO ? demo : real;
  api.DEMO = DEMO;
  global.API = api;

  // 商品封面解析：DEMO 与真实后端通用。
  // 匹配优先级：① 商品名关键词（覆盖两种模式，最可靠）② 商品编码 ③ images 字段。
  // 注意：真实库里 G-001=初音、G-002=炭治郎（与 DEMO 假数据编码相反），
  // 所以优先按“商品名关键词”匹配，避免编码冲突。
  const NAME_COVER = [
    ['炭治郎', 'assets/img/tanjiro.jpg'],
    ['初音', 'assets/img/miku.jpg'],
    ['芙莉莲', 'assets/img/frieren-badge.jpg'],
    ['T恤', 'assets/img/jjk-tshirt.jpg'],
    ['立牌', 'assets/img/gojo-stand.jpg'],
    ['拍立得', 'assets/img/jjk-polaroid.jpg'],
    ['色纸', 'assets/img/genshin-shikishi.jpg'],
    ['纪念票', 'assets/img/genshin-card.jpg'],
    ['收藏卡', 'assets/img/genshin-card.jpg'],
    ['徽章', 'assets/img/genshin-card.jpg']
  ];
  const LOCAL_COVER = {
    'G-001': 'assets/img/miku.jpg',
    'G-002': 'assets/img/tanjiro.jpg'
  };
  global.goodsCover = function (g) {
    if (!g) return '';
    const name = g.goodsName || '';
    // ① 商品名关键词（ specificity 从具体到宽泛，越靠前越优先）
    for (let i = 0; i < NAME_COVER.length; i++) {
      if (name.indexOf(NAME_COVER[i][0]) >= 0) return NAME_COVER[i][1];
    }
    // ② 商品编码兜底
    if (g.goodsCode && LOCAL_COVER[g.goodsCode]) return LOCAL_COVER[g.goodsCode];
    // ③ images 字段（真实后端 JSON 数组字符串）
    try {
      const imgs = JSON.parse(g.images || '[]');
      if (Array.isArray(imgs) && imgs.length) {
        let u = typeof imgs[0] === 'string' ? imgs[0] : (imgs[0].url || imgs[0].imageUrl || '');
        if (u) return u.indexOf('http') === 0 || u.charAt(0) === '/' ? u : (DEMO ? u : BASE + (u.charAt(0) === '/' ? '' : '/') + u);
      }
    } catch (e) {}
    return '';
  };
})(window);
