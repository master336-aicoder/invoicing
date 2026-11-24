# 商用进销存系统（Invoicing）

> 一套面向中小型批发、零售、连锁门店场景的**多租户商用进销存管理系统**，采用 Vue 3 + Spring Boot 微服务架构，覆盖商品、采购、销售、仓储、财务与报表分析等核心业务域。

## 项目简介

本项目从真实业务场景出发（粮油批发、连锁药店、汽配经销、服装分销、社区团购等），围绕「采购入库 → 质检上架 → 销售出库 → 退货盘点 → 财务结算 → 供应商对账 → 客户开票」的完整链路进行建模。

设计上采用**按业务域拆分的微服务架构**：每个服务独立数据库、通过 `tenant_id` 实现多租户数据隔离；服务间通过 OpenFeign 同步调用、通过本地消息表 + 定时任务处理异步场景；配置与注册统一由 Nacos 托管。

> 📌 **当前进度**：目前代码仓库中已落地 `auth`、`common`、`gateway`、`product` 四个后端基础模块与完整的前端页面框架；采购、销售、仓储、财务等业务服务的接口与页面已规划并在前端路由中预留，正按设计文档分阶段推进。详细规划见 [`doc/technical-design.md`](doc/technical-design.md)。

## 技术栈

| 层级 | 技术选型 | 版本 / 说明 |
| --- | --- | --- |
| 前端框架 | Vue 3 + TypeScript | 组合式 API，Vite 5 构建 |
| 状态管理 | Pinia 2 | 用户、权限等状态 |
| UI 组件库 | Element Plus 2.5 | 企业级组件 |
| 图表 | Apache ECharts 5.4 | 销售趋势、库存监控、占比分析 |
| HTTP 客户端 | Axios 1.6 | 统一请求/响应拦截与鉴权 |
| 后端框架 | Spring Boot 2.7.18 | JDK 1.8 / 21 均可运行 |
| 微服务治理 | Spring Cloud 2021.0.8 + Alibaba 2021.0.5.0 | Nacos 注册与配置、Sentinel 限流熔断 |
| 网关 | Spring Cloud Gateway | 统一路由、鉴权、限流过滤器链 |
| 认证 | Spring Security + JWT（jjwt 0.12.3） | Access Token / Refresh Token 双令牌 |
| ORM | MyBatis-Plus 3.5.5 | 分页插件、逻辑删除、通用 CRUD |
| 数据库 | MySQL 8.0 | 按业务域拆分为 5 个独立库 |
| 缓存 | Redis 7.2 | 热点数据旁路缓存、分布式锁 |
| 工具库 | Hutool、Lombok、MapStruct | 提升开发效率 |
| 部署 | Docker Compose | Nginx 反代 + 各服务容器化 |

## 系统架构

```
┌──────────────────────────────────────────────────────────────┐
│ 客户端层：Web(PC) / 移动 App / PDA 终端 / 第三方 Open API      │
└───────────────────────────────┬──────────────────────────────┘
                                ▼
┌──────────────────────────────────────────────────────────────┐
│ 网关层：Spring Cloud Gateway（路由 / JWT 鉴权 / Sentinel 限流）│
└───────────────────────────────┬──────────────────────────────┘
                                ▼
┌──────────────────────────────────────────────────────────────┐
│ 服务层：auth │ product │ purchase │ sales │ warehouse │ finance│
└───────────────────────────────┬──────────────────────────────┘
                                ▼
┌──────────────────────────────────────────────────────────────┐
│ 基础设施：Nacos（注册/配置）│ MySQL（分库）│ Redis（缓存）      │
└──────────────────────────────────────────────────────────────┘
```

### 后端模块

| 模块 | 状态 | 职责 |
| --- | --- | --- |
| `invoicing-common` | ✅ 已实现 | 统一响应 `Result` / 分页 `PageResult`、全局异常处理、`JwtUtils`、`TenantContext`、MyBatis-Plus 配置 |
| `invoicing-auth` | ✅ 已实现 | 用户认证与 JWT 签发、用户 / 角色 / 商品分类等基础接口 |
| `invoicing-gateway` | ✅ 已实现 | 全局鉴权过滤器 `AuthGlobalFilter`、动态路由、限流熔断 |
| `invoicing-product` | ✅ 已实现 | 商品基础信息与商品分类管理（SPU / SKU） |
| `invoicing-purchase` / `sales` / `warehouse` / `finance` | 📐 规划中 | 采购、销售、仓储、财务业务服务，数据库脚本已就绪，见 `scripts/` |

### 数据库设计

采用按业务域拆分的独立库，全部表通过 `tenant_id` 做多租户隔离：

| 数据库 | 所属服务 | 核心表 |
| --- | --- | --- |
| `invoicing_auth` | 认证服务 | `sys_user`、`sys_role` |
| `invoicing_product` | 商品服务 | `product_base`、`product_category`、`supplier`、`warehouse`、`warehouse_location` |
| `invoicing_inventory` | 库存服务 | `inventory_ledger`、`inventory_summary`、`batch`、`inventory_flow` |
| `invoicing_purchase` | 采购服务 | `purchase_order`、`purchase_order_detail`、`purchase_receipt` |
| `invoicing_sales` | 销售服务 | `sales_order`、`sales_order_detail`、`customer`、`sales_delivery` |

初始化脚本位于 [`invoicing-backend/scripts/`](invoicing-backend/scripts/)，包含 `.sql` 与 PowerShell 批量建库脚本。

### 前端功能

`invoicing-web` 已实现完整的后台管理页面框架与路由：

- **首页看板** Dashboard：经营数据概览、ECharts 图表
- **商品管理**：商品列表、商品分类、品牌管理
- **采购管理**：采购订单、供应商管理
- **销售管理**：销售订单、客户管理
- **仓储管理**：库存管理、库存查询
- **报表中心**：销售报表
- **系统**：登录、权限状态、404 页面

## 目录结构

```
invoicing/
├── doc/                          # 需求与技术设计文档
│   ├── requirements.md           # 需求文档 V2.0
│   ├── technical-design.md       # 技术设计文档
│   └── 商用进销存系统设计任务分解.xmind
├── invoicing-backend/            # 后端 Maven 多模块工程
│   ├── config/                   # Nacos 配置示例（common / gateway / auth / product ...）
│   ├── invoicing-auth/           # 认证服务
│   ├── invoicing-common/         # 公共组件
│   ├── invoicing-gateway/        # API 网关
│   ├── invoicing-product/        # 商品服务
│   └── scripts/                  # 数据库初始化脚本
├── invoicing-web/                # 前端 Vue 3 工程
│   ├── src/api/                  # 接口封装
│   ├── src/router/               # 路由配置
│   ├── src/stores/               # Pinia 状态
│   ├── src/views/                # 业务页面
│   └── src/components/charts/    # ECharts 图表组件
├── mock-server.js                # 本地 Mock 服务
└── start-auth-service.bat        # 认证服务启动脚本（Windows）
```

## 快速开始

### 环境依赖

- JDK 1.8+（启动脚本中使用 JDK 21）
- Maven 3.8+
- Node.js 18+ / npm
- MySQL 8.0、Redis 7.2
- Nacos 2.3.0（默认 `192.168.1.20:8848`，命名空间 `ai-dev`，分组 `dev`）

### 后端

```bash
# 1. 初始化数据库
cd invoicing-backend/scripts
# 按需执行 init-*.sql，或使用 init-all-databases.ps1 批量建库

# 2. 将 config/ 下的 yml 配置发布到 Nacos
#    common.yml / invoicing-gateway.yml / auth-service.yml / product-service.yml ...

# 3. 编译并启动服务
cd invoicing-backend
mvn clean package -DskipTests
java -jar invoicing-auth/target/invoicing-auth-1.0.0.jar
```

### 前端

```bash
cd invoicing-web
npm install
npm run dev        # 开发模式
npm run build      # 生产构建（vue-tsc 类型检查 + vite build）
```

接口基础地址通过 `.env` 中的 `VITE_API_BASE_URL=/api` 配置，由网关统一转发。

## 相关文档

- [需求文档](doc/requirements.md) — 业务场景、功能需求、非功能需求、系统集成规划
- [技术设计文档](doc/technical-design.md) — 微服务划分、数据库设计、缓存策略、网关与前端架构、实施路径

---

---

# 关于作者

> 源码猿（master336）—— 一个把「踩过的坑」写成「别人脚下的路」的技术作者。

## 一句话介绍

**源码猿（master336）**，现就职于**某公司**，担任**高级技术架构师 / 产品售前专家**（腾讯云开发者社区认证）。长期深耕 Java 后端与分布式架构，近年将主要精力投向 **AI Agent、大模型私有化部署与工程化落地**，坚持用「能跑通、可复现、讲原理」的标准写每一篇文章。

## 身份与平台

| 平台 | 主页 | 身份 / 荣誉 |
| --- | --- | --- |
| CSDN 博客 | [master336.blog.csdn.net](https://master336.blog.csdn.net) | 人工智能领域**新星创作者**，原力等级 **298**，累计获赞 **461** 次、评论 **86** 条 |
| 腾讯云开发者社区 | [cloud.tencent.com/developer/user/1558800](https://cloud.tencent.com/developer/user/1558800) | 认证作者 · 某公司｜高级技术架构师、产品售前专家 |

## 技术视野

作者的写作版图横跨「从底层到应用、从传统工程到 AI 原生」的完整链路：

- **后端与架构**：Java、Spring / SpringBoot / SpringCloud、微服务架构、Maven
- **数据与存储**：MySQL、Redis、PostgreSQL、Greenplum、GaussDB、ETL 与大数据处理
- **运维与基础设施**：Linux、Nginx、操作系统、网络协议（TCP/UDP、HTTP/HTTPS、OSI 七层模型）、RabbitMQ
- **前端与客户端**：JavaScript、CSS、Vue.js、HTML、Android、微信小程序
- **AI 与智能化**：机器学习、NLP、图像处理、数据分析、AIGC
- **AI 工程化（近期主线）**：AI Agent 架构与多智能体协同、Ollama / ComfyUI 私有大模型部署、MCP 协议、Skill 资产化、大模型评测与上下文召回

## 写作风格

不同于「Hello World 式」的速食教程，作者的文章有三个鲜明特点：

1. **讲透原理** —— 不满足于告诉你「怎么做」，更在意解释「为什么这么做」；
2. **给出可落地的工程** —— 完整目录结构、核心代码、硬件选型、避坑清单，拿来就能改；
3. **有数据、有出处** —— 明确区分哪些是实测、哪些是预测、哪些不可横向比较，拒绝拍脑袋结论。

近期在腾讯云开发者社区连续产出《用 CodeArts 把一个自托管云相册真正做完》《Ollama 私有大模型部署与生态配置完全指南》《从零构建 AI Agent：一份写给工程师的深度开发指南》《一次讲透 HTTP 与 HTTPS》等长文，几乎保持日更节奏。

## 联系方式

- CSDN：[https://master336.blog.csdn.net](https://master336.blog.csdn.net)
- 腾讯云开发者社区：[https://cloud.tencent.com/developer/user/1558800](https://cloud.tencent.com/developer/user/1558800)

---

## ☕ 支持作者

看到这里，说明你已经陪我读到了文章的最后。

如果这些文字曾经帮你**少踩一个坑、少熬一个夜、少走一次弯路**，那它就是有价值的。写作这件事，靠的不只是兴趣，还有一台够用的机器、几个付费的实验环境、以及愿意花在查证与实测上的时间。

**你的每一份支持，都会变成下一篇文章里的一个真实实验、一次更深入的拆解。**

> 不用有压力 —— 一杯咖啡的钱，就足够让我开心很久。
> 当然，一个点赞、一条评论、一次转发，同样是最好的鼓励。

### 打赏渠道

<div align="center">

| 微信支付 | 支付宝 |
| :---: | :---: |
| ![微信支付二维码](images/wx.png) | ![支付宝二维码](images/zfb.jpg) |
| *推荐使用微信支付* | *支持信用卡 / 花呗付款* |

</div>

### 不打烊的支持方式

如果不方便打赏，下面这些同样珍贵：

- 👍 **点赞** —— 让更多人看到这篇内容
- ⭐ **收藏** —— 下次要用时能第一时间找到
- 💬 **评论** —— 你的问题常常是下一篇选题的起点
- 🔗 **转发** —— 把有用的东西分享给需要的朋友

感谢每一位读到这里的人。我们下篇文章见。

---

*Made with ❤️ by 源码猿（master336）*
