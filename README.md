# 星谷周边 · 动漫周边电商平台

一个可真实运行的全栈电商项目：Vue3 前端 + Spring Boot 后端 + MySQL + Redis，支持 Docker 一键部署。

> 课程作业与考研复试展示两用：既能完整演示注册登录、下单、领券、签到、发视频，也包含下单事务、防超卖、Redis 会话等可展开讲解的工程细节。

## 技术栈

| 层 | 技术 |
|---|---|
| 前端 | Vue 3（全局版）、vue-router（hash 路由）、axios、原生 HTML/CSS/JS |
| 后端 | Spring Boot 4.1.1、MyBatis-Plus 3.5.18 |
| 数据库 | MySQL 8.0（28 张表） |
| 缓存 / 会话 | Redis 7（token 会话 + 缓存） |
| 部署 | Docker + docker-compose + Nginx |

## 功能

- **用户**：注册、登录（MD5 散列 + Redis token，2 小时过期）、登录态检查、退出
- **商品**：列表 / 搜索 / 分类筛选 / 详情，分类树与详情进 Redis 缓存
- **下单**：事务内完成库存原子扣减、库存流水、订单落库、积分到账
- **优惠券**：领券（校验时间窗 / 库存 / 限领）、我的券、过期自动置状态
- **签到积分**：连续签到 + 奖励、积分账户乐观锁防并发、变动流水
- **视频**：发布（multipart 上传）、列表、点赞 / 播放原子自增
- **管理端**：商品 / SKU / 用户的增删改查，软删除保外键完整

## 快速启动

### 方式一：本地联调（IDEA）

1. 启动 Redis：`D:\webAi\redis\启动Redis.bat`（或本机 redis-server）
2. MySQL 建库 `xym-work`，导入 `deploy/mysql/init.sql`
3. IDEA 打开 `backend/`，Run Configuration 的 Environment variables 加一行：
   ```
   MYSQL_PASS=你的数据库密码
   ```
4. 运行 `AnimeBackendApplication.main()`，后端起在 `9091`
5. 前端目录起静态服务器：`python -m http.server 5500`，浏览器打开 `http://localhost:5500`

测试账号：`xiaoxu / 123456`

### 方式二：Docker 一键部署（云服务器）

```bash
cd deploy
cp .env.example .env       # 编辑 .env，填入 MYSQL_PASS
# 把打好的 jar 放到 deploy/backend/app.jar
docker compose up -d
```

访问 `http://服务器公网IP`，安全组放行 80 / 22 端口。详见 `deploy/部署手册.md`。

## 目录结构

```
anime-shop/
├── backend/          Spring Boot 后端源码
│   └── src/main/java/com/anime/backend/
│       ├── controller/   接单：解析请求、返回结果
│       ├── service/      业务：登录校验、下单事务、积分逻辑（核心）
│       ├── mapper/       数据访问：继承 BaseMapper，免写 SQL
│       ├── entity/       数据表对应的 Java 对象
│       ├── common/       统一返回 Result / 全局异常处理
│       ├── config/       Redis 序列化、跨域、视频路径映射
│       └── util/         鉴权 AuthUtil、MD5 工具
├── frontend/         Vue3 前端（无构建，双击即用）
│   ├── index.html
│   ├── css/  js/  vendor/  assets/
├── deploy/           Docker 部署配置
│   ├── docker-compose.yml
│   ├── backend/Dockerfile
│   ├── nginx/nginx.conf
│   ├── mysql/init.sql
│   └── 部署手册.md
└── README.md
```

## 工程亮点（面试可讲）

1. **下单事务 + 防超卖**：`OrderService.placeOrder()` 用一条 `WHERE stock >= qty` 的条件更新做原子扣库存，影响行数为 0 即判定售罄；整个方法 `@Transactional`，任何一步失败全回滚。
2. **Redis token 会话**：登录生成 UUID token 存 `anime:token:<token> → userId`，带 TTL；`AuthUtil` 统一鉴权，退出即删 key。
3. **乐观锁防并发**：积分账户带 `version` 字段，更新时 `WHERE id=? AND version=?`，冲突重读重试。
4. **软删除保外键**：商品删后置 `deleted=1`、用户删后置 `status=3`，不物理删，避免外键约束报错。
5. **缓存一致性**：商品详情 `@Cacheable`，积分变动 `@CacheEvict`，保证读到最新值。
6. **容器化部署**：一份 compose 拉起 MySQL + Redis + 后端 + Nginx，环境变量注入配置，本地 / 云上一份代码通用。

## 安全说明

- 仓库内**不含任何真实密码**：数据库密码走环境变量，部署密码放 `.env`（已被 `.gitignore` 忽略），只提供 `.env.example` 模板。
- 密码用 MD5 散列存储（教学项目够用，生产环境应换 BCrypt）。
- 管理端 `/api/admin` 未做权限校验，仅用于教学演示。
