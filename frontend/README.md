# 星幻谷子 · 二次元商城前端

Vue 3 + 原生 JS/CSS，无构建工具，双击/静态服务器即可运行。
配色：深空紫 + 樱花粉 + 电光青（玻璃拟态）。

## 启动方式（两步）

1. 启动后端：确保 Redis 已开，运行 `D:\webAi\anime-backend` 的 `AnimeBackendApplication`（端口 9091）
2. 启动前端：在本目录执行 `python -m http.server 5500`，浏览器打开 `http://localhost:5500`

> 直接用 IDEA / VSCode 的 Live Server 打开 `index.html` 也可以。
> 不要用 file:// 直接双击打开（部分浏览器会拦截本地资源）。

测试账号：`xiaoxu / 123456`（也可用登录页注册新账号）

## 页面结构

| 路由 | 页面 | 说明 |
|---|---|---|
| #/login | 登录/注册 | **全屏视频背景**（assets/video/login-bg.mp4），登录成功进主页 |
| #/home | 主页 | 新品上新、快捷入口、活动横幅贴图位 |
| #/goods | 商品页 | 分类切换 + **视频横幅**（goods-show.mp4，不遮挡商品）+ 购买 |
| #/goods/:id | 商品详情 | 直接打开某商品详情弹窗 |
| #/video | 视频社区 | 发布/观看/点赞视频 |
| #/orders | 我的订单 | 订单列表 |

**全站固定悬浮按钮**（右下角，任何页面都在）：
- 🎟️ 领优惠券：领券中心 / 我的券
- ⭐ 签到领积分：签到 / 积分账户 / 流水

登录态：token 存 localStorage，请求头自动携带；未登录访问需登录页会自动跳回登录页（对应需求"未登录跳注册、已登录进页面"）。

## 贴图与视频（已按你的要求替换）

- **主页 Hero**：`把喜欢的角色带回你的星球` 模块（字体、模块大小都不变）现在是**轮播图**，3 张图在 `assets/img/slide1~3.jpg`，3.5 秒自动切换，可点左右箭头和下方圆点手动切。改图直接替换这 3 个文件即可。
- **主页横幅**：`assets/img/banner.jpg`（那张蓝色 moment 图），CSS `object-position:center top` 保证保留整张图的上半部分，容器高度 200px（界面不够大可改 `.banner-img` 的 height）。
- **配色**：白色/浅粉底 + 加重的樱花粉，紫/粉/青主色调不变。配色变量都在 `css/style.css` 顶部 `:root`。
- **商品缩略图/详情大图**仍是 emoji 占位（`class="ph"`），换成 `<img>` 即可（商品图在 `g.images`，JSON 字符串取第一张）。

## 视频文件

- `assets/video/login-bg.mp4` — 登录页全屏背景（Video Project 1.mp4）
- `assets/video/goods-show.mp4` — 商品页横幅（Video Project.mp4），高度放大到 320px，`object-position:center 40%` 聚焦人物上半身，正常文档流不遮挡商品卡片

## 目录

```
anime-frontend/
├── index.html          入口（引入本地依赖 + 各 JS）
├── css/style.css       全部样式（配色变量在最顶部 :root）
├── js/api.js           后端接口封装（BASE=9091，自动带 token）
├── js/components.js    页面组件：登录/主页/商品/视频/订单
├── js/widgets.js       悬浮组件：领券 + 签到积分
├── js/app.js           路由 + 根组件 + 全局提示
├── vendor/             本地 Vue3/vue-router/axios（无需联网）
└── assets/video/       两个 mp4
```

## 后端依赖

需登录的接口未登录返回 code=401；后端已配置 CORS 允许跨域。数据库 `xym-work`，端口 9091。
