# 商用进销存系统技术设计文档

## 一、项目概述

本文档为商用进销存系统的技术设计文档，基于需求文档进行技术架构设计与技术选型，采用Vue3+Spring Boot微服务架构，MySQL数据库，Redis缓存，构建高可用、高性能、可扩展的企业级进销存管理系统。

---

## 二、技术架构设计

### 2.1 整体架构图

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                   客户端层                                        │
├─────────────────────────────────────────────────────────────────────────────────┤
│  Web端(PC)   │   移动App(iOS/Android)   │   PDA终端   │   第三方系统集成         │
│   Vue3+PWA   │      UniApp + Vue3       │    PDA定制   │   Open API              │
└─────────────────────────────────────────────────────────────────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                  网关层                                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │   API网关   │  │   认证网关  │  │   路由网关  │  │   限流网关  │             │
│  │  Spring     │  │  OAuth2.0   │  │  动态路由   │  │  Sentinel   │             │
│  │  Gateway    │  │  + JWT      │  │  + Nacos    │  │  限流熔断   │             │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘             │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 技术栈总览

| 层级 | 技术选型 | 版本 | 说明 |
|------|---------|------|------|
| **前端框架** | Vue3 | 3.4+ | 组合式API + Composition |
| **前端状态管理** | Pinia | 2.1+ | 轻量级状态管理 |
| **前端UI组件库** | Element Plus | 2.5+ | 企业级Vue3组件库 |
| **前端工程化** | Vite | 5.0+ | 快速构建工具 |
| **后端框架** | Spring Boot | 2.7.18 | JDK 1.8 |
| **服务注册与配置** | Nacos | 2.3.0 | 注册中心+配置中心 | `http://192.168.1.20:8848/` |
| **服务限流熔断** | Sentinel | 1.8.6 | 流量控制与降级 |
| **数据库** | MySQL | 8.0 | InnoDB引擎 |
| **ORM框架** | MyBatis-Plus | 3.5+ | 简化CRUD操作 |
| **缓存** | Redis | 7.2 | 主从模式 |
| **文件存储** | 本地存储/NFS | - | 文件上传存储 |
| **容器编排** | Docker Compose | - | 容器化部署（简化版） |

---

## 三、微服务架构设计

### 3.1 服务划分（精简版）

| 服务名称 | 服务描述 | 主要职责 | 核心技术栈 |
|---------|---------|---------|-----------|
| **product-service** | 商品中心服务 | SPU/SKU管理、商品分类、条码管理、单位换算、序列号管理 | Spring Boot + MyBatis-Plus + Redis |
| **purchase-service** | 采购中心服务 | 供应商管理、采购订单、到货管理、入库管理、供应商评估 | Spring Boot + MyBatis-Plus |
| **sales-service** | 销售中心服务 | 销售订单、价格策略、客户信用、渠道订单、退货管理 | Spring Boot + MyBatis-Plus + Redis |
| **warehouse-service** | 仓储中心服务 | 仓库管理、库位管理、库存台账、批次管理、盘点管理 | Spring Boot + MyBatis-Plus + Redis |
| **finance-service** | 财务中心服务 | 应收应付、凭证管理、发票管理、账龄分析、对账单 | Spring Boot + MyBatis-Plus |
| **system-service** | 系统服务 | 用户管理、角色权限、参数配置、操作日志、消息通知 | Spring Boot |
| **gateway-service** | API网关服务 | 路由转发、限流熔断、统一认证 | Spring Cloud Gateway + Sentinel |
| **auth-service** | 认证服务 | 用户认证、权限管理、JWT | Spring Security + JWT |

> **精简说明**：
> - 移除 `message-service`：消息推送功能合并到 `system-service`
> - 移除 `tms-service`：运输管理功能合并到 `warehouse-service`
> - 移除 `crm-service`：客户管理功能合并到 `sales-service`
> - 移除 `workflow-service`：审批流程简化为状态字段控制
> - 移除 `file-service`：文件上传功能合并到各业务服务，使用本地存储
> - 移除 `monitor-service`：监控功能使用Spring Boot Actuator + 日志分析
> - 移除 `report-service`：报表功能合并到各业务服务

### 3.2 服务通信设计

#### 3.2.1 同步通信（RPC）
- 采用OpenFeign进行服务间HTTP调用
- 启用Sentinel进行流量保护
- 超时时间：默认3000ms
- 重试机制：默认不重试

#### 3.2.2 本地消息表（替代MQ）

对于需要异步处理的场景，采用**本地消息表+定时任务**模式：

| 业务场景 | 消息表 | 处理方式 |
|---------|-------|---------|
| 订单创建 | `order_event` | 订单服务写入，库存服务定时扫描 |
| 库存变更 | `inventory_event` | 仓储服务写入，财务服务定时扫描 |
| 消息通知 | `notification` | 系统服务写入，定时推送 |

---

## 四、数据库设计

### 4.1 数据库架构（按微服务拆分）

#### 4.1.1 数据库拆分策略
采用按业务领域拆分的微服务数据库架构，每个微服务独立拥有自己的数据库：

| 数据库名称 | 所属服务 | 表数量 | 主要功能 |
|-----------|---------|-------|---------|
| `invoicing_auth` | 认证服务 | 2 | 用户管理、角色权限 |
| `invoicing_product` | 商品服务 | 5 | 商品、分类、供应商、仓库、库位 |
| `invoicing_inventory` | 库存服务 | 4 | 库存、批次、库存流水、库存汇总 |
| `invoicing_purchase` | 采购服务 | 3 | 采购订单、采购明细、采购入库 |
| `invoicing_sales` | 销售服务 | 4 | 销售订单、销售明细、客户、销售出库 |

#### 4.1.2 各数据库表归属
- **invoicing_auth 数据库**：
  - `sys_user`（用户表）
  - `sys_role`（角色表，待扩展）

- **invoicing_product 数据库**：
  - `product_base`（商品基础表）
  - `product_category`（商品分类表）
  - `supplier`（供应商表）
  - `warehouse`（仓库表）
  - `warehouse_location`（库位表）

- **invoicing_inventory 数据库**：
  - `inventory_ledger`（库存台账表）
  - `inventory_summary`（库存汇总表）
  - `batch`（批次表）
  - `inventory_flow`（库存流水表，待添加）

- **invoicing_purchase 数据库**：
  - `purchase_order`（采购订单表）
  - `purchase_order_detail`（采购订单明细表）
  - `purchase_receipt`（采购入库单表，待扩展）

- **invoicing_sales 数据库**：
  - `sales_order`（销售订单表）
  - `sales_order_detail`（销售订单明细表）
  - `customer`（客户表）
  - `sales_delivery`（销售出库单表，待扩展）

**租户隔离**：所有数据库表均通过 `tenant_id` 字段实现多租户隔离
- **索引优化**：针对查询热点字段建立复合索引

### 4.2 读写分离（可选）
- 主库（Master）处理写操作
- 从库（Slave）处理读操作（后期扩展时启用）
- **暂不使用ShardingSphere**：简化部署，后期根据数据量再评估

### 4.3 核心表结构

#### 4.3.1 商品基础表（product_base）

```sql
CREATE TABLE `product_base` (
  `id` BIGINT UNSIGNED NOT NULL COMMENT '主键ID',
  `tenant_id` BIGINT UNSIGNED NOT NULL COMMENT '租户ID',
  `product_code` VARCHAR(64) NOT NULL COMMENT '商品编码',
  `product_name` VARCHAR(255) NOT NULL COMMENT '商品名称',
  `product_type` TINYINT NOT NULL DEFAULT 1 COMMENT '商品类型:1=SKU,2=SPU',
  `category_id` BIGINT UNSIGNED COMMENT '商品分类ID',
  `gb_category_code` VARCHAR(32) COMMENT '国标分类码',
  `unit_id` BIGINT UNSIGNED NOT NULL COMMENT '主计量单位ID',
  `min_order_qty` DECIMAL(12,4) NOT NULL DEFAULT 1 COMMENT '最小订购数量',
  `safety_stock` DECIMAL(12,4) DEFAULT 0 COMMENT '安全库存',
  `max_stock` DECIMAL(12,4) DEFAULT 0 COMMENT '最大库存',
  `cost_price` DECIMAL(12,4) DEFAULT 0 COMMENT '成本价',
  `sale_price` DECIMAL(12,4) DEFAULT 0 COMMENT '售价',
  `tax_rate` DECIMAL(5,4) DEFAULT 0 COMMENT '税率',
  `weight` DECIMAL(10,3) COMMENT '重量(kg)',
  `volume` DECIMAL(10,3) COMMENT '体积(m³)',
  `medical_reg_no` VARCHAR(64) COMMENT '医疗器械注册证号',
  `food_prod_license_no` VARCHAR(64) COMMENT '食品生产许可证编号',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态:0=禁用,1=启用',
  `remark` TEXT COMMENT '备注',
  `creator` BIGINT UNSIGNED COMMENT '创建人',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` BIGINT UNSIGNED COMMENT '更新人',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_product_code` (`tenant_id`, `product_code`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_product_name` (`product_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品基础表';
```

#### 4.3.2 供应商表（supplier）

```sql
CREATE TABLE `supplier` (
  `id` BIGINT UNSIGNED NOT NULL COMMENT '主键ID',
  `tenant_id` BIGINT UNSIGNED NOT NULL COMMENT '租户ID',
  `supplier_code` VARCHAR(64) NOT NULL COMMENT '供应商编码',
  `supplier_name` VARCHAR(255) NOT NULL COMMENT '供应商名称',
  `supplier_type` TINYINT NOT NULL DEFAULT 1 COMMENT '供应商类型',
  `contact_name` VARCHAR(64) COMMENT '联系人',
  `contact_phone` VARCHAR(32) COMMENT '联系电话',
  `credit_level` TINYINT COMMENT '信用等级',
  `credit_amount` DECIMAL(15,2) DEFAULT 0 COMMENT '信用额度',
  `payment_days` INT DEFAULT 0 COMMENT '账期(天)',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态',
  `creator` BIGINT UNSIGNED COMMENT '创建人',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` BIGINT UNSIGNED COMMENT '更新人',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_supplier_code` (`tenant_id`, `supplier_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='供应商表';
```

#### 4.3.3 采购订单表（purchase_order）

```sql
CREATE TABLE `purchase_order` (
  `id` BIGINT UNSIGNED NOT NULL COMMENT '主键ID',
  `tenant_id` BIGINT UNSIGNED NOT NULL COMMENT '租户ID',
  `order_no` VARCHAR(64) NOT NULL COMMENT '采购订单号',
  `supplier_id` BIGINT UNSIGNED NOT NULL COMMENT '供应商ID',
  `contract_no` VARCHAR(64) COMMENT '合同编号',
  `total_amount` DECIMAL(15,2) NOT NULL DEFAULT 0 COMMENT '订单总金额',
  `payable_amount` DECIMAL(15,2) NOT NULL DEFAULT 0 COMMENT '应付金额',
  `delivery_date` DATE COMMENT '预计交货日期',
  `approval_status` TINYINT NOT NULL DEFAULT 1 COMMENT '审批状态',
  `order_status` TINYINT NOT NULL DEFAULT 1 COMMENT '订单状态',
  `creator` BIGINT UNSIGNED COMMENT '创建人',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` BIGINT UNSIGNED COMMENT '更新人',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_order_no` (`tenant_id`, `order_no`),
  KEY `idx_supplier_id` (`supplier_id`),
  KEY `idx_order_status` (`order_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='采购订单表';
```

#### 4.3.4 客户表（customer）

```sql
CREATE TABLE `customer` (
  `id` BIGINT UNSIGNED NOT NULL COMMENT '主键ID',
  `tenant_id` BIGINT UNSIGNED NOT NULL COMMENT '租户ID',
  `customer_code` VARCHAR(64) NOT NULL COMMENT '客户编码',
  `customer_name` VARCHAR(255) NOT NULL COMMENT '客户名称',
  `customer_type` TINYINT NOT NULL COMMENT '客户类型',
  `customer_level` TINYINT NOT NULL DEFAULT 3 COMMENT '客户等级',
  `contact_name` VARCHAR(64) COMMENT '联系人',
  `contact_phone` VARCHAR(32) COMMENT '联系电话',
  `address` VARCHAR(512) COMMENT '详细地址',
  `credit_level` TINYINT COMMENT '信用等级',
  `credit_amount` DECIMAL(15,2) DEFAULT 0 COMMENT '信用额度',
  `used_credit_amount` DECIMAL(15,2) DEFAULT 0 COMMENT '已用信用额度',
  `payment_days` INT DEFAULT 0 COMMENT '账期(天)',
  `freeze_status` TINYINT NOT NULL DEFAULT 0 COMMENT '冻结状态',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态',
  `creator` BIGINT UNSIGNED COMMENT '创建人',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` BIGINT UNSIGNED COMMENT '更新人',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_customer_code` (`tenant_id`, `customer_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='客户表';
```

#### 4.3.5 销售订单表（sales_order）

```sql
CREATE TABLE `sales_order` (
  `id` BIGINT UNSIGNED NOT NULL COMMENT '主键ID',
  `tenant_id` BIGINT UNSIGNED NOT NULL COMMENT '租户ID',
  `order_no` VARCHAR(64) NOT NULL COMMENT '销售订单号',
  `channel` VARCHAR(32) NOT NULL COMMENT '销售渠道',
  `customer_id` BIGINT UNSIGNED NOT NULL COMMENT '客户ID',
  `customer_name` VARCHAR(255) NOT NULL COMMENT '客户名称',
  `total_amount` DECIMAL(15,2) NOT NULL DEFAULT 0 COMMENT '订单总金额',
  `payable_amount` DECIMAL(15,2) NOT NULL DEFAULT 0 COMMENT '应付金额',
  `paid_amount` DECIMAL(15,2) DEFAULT 0 COMMENT '已付金额',
  `cost_amount` DECIMAL(15,2) DEFAULT 0 COMMENT '成本金额',
  `profit_amount` DECIMAL(15,2) DEFAULT 0 COMMENT '利润金额',
  `approval_status` TINYINT NOT NULL DEFAULT 1 COMMENT '审批状态',
  `order_status` TINYINT NOT NULL DEFAULT 1 COMMENT '订单状态',
  `pay_status` TINYINT NOT NULL DEFAULT 1 COMMENT '支付状态',
  `shipping_status` TINYINT NOT NULL DEFAULT 0 COMMENT '发货状态',
  `invoice_status` TINYINT NOT NULL DEFAULT 0 COMMENT '开票状态',
  `creator` BIGINT UNSIGNED COMMENT '创建人',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` BIGINT UNSIGNED COMMENT '更新人',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_order_no` (`tenant_id`, `order_no`),
  KEY `idx_customer_id` (`customer_id`),
  KEY `idx_channel` (`channel`),
  KEY `idx_order_status` (`order_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='销售订单表';
```

#### 4.3.6 仓库表（warehouse）

```sql
CREATE TABLE `warehouse` (
  `id` BIGINT UNSIGNED NOT NULL COMMENT '主键ID',
  `tenant_id` BIGINT UNSIGNED NOT NULL COMMENT '租户ID',
  `warehouse_code` VARCHAR(32) NOT NULL COMMENT '仓库编码',
  `warehouse_name` VARCHAR(128) NOT NULL COMMENT '仓库名称',
  `warehouse_type` TINYINT NOT NULL COMMENT '仓库类型',
  `warehouse_category` TINYINT NOT NULL COMMENT '仓储类型',
  `address` VARCHAR(255) COMMENT '详细地址',
  `is_default` TINYINT NOT NULL DEFAULT 0 COMMENT '是否默认仓库',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态',
  `creator` BIGINT UNSIGNED COMMENT '创建人',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` BIGINT UNSIGNED COMMENT '更新人',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_warehouse_code` (`tenant_id`, `warehouse_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='仓库表';
```

#### 4.3.7 库位表（warehouse_location）

```sql
CREATE TABLE `warehouse_location` (
  `id` BIGINT UNSIGNED NOT NULL COMMENT '主键ID',
  `tenant_id` BIGINT UNSIGNED NOT NULL COMMENT '租户ID',
  `warehouse_id` BIGINT UNSIGNED NOT NULL COMMENT '仓库ID',
  `zone_code` VARCHAR(32) NOT NULL COMMENT '库区编码',
  `zone_name` VARCHAR(64) NOT NULL COMMENT '库区名称',
  `location_code` VARCHAR(32) NOT NULL COMMENT '库位编码',
  `location_status` TINYINT NOT NULL DEFAULT 1 COMMENT '库位状态',
  `rfid_tag` VARCHAR(128) COMMENT 'RFID标签编码',
  `creator` BIGINT UNSIGNED COMMENT '创建人',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` BIGINT UNSIGNED COMMENT '更新人',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_location_code` (`tenant_id`, `warehouse_id`, `location_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='库位表';
```

#### 4.3.8 批次表（batch）

```sql
CREATE TABLE `batch` (
  `id` BIGINT UNSIGNED NOT NULL COMMENT '主键ID',
  `tenant_id` BIGINT UNSIGNED NOT NULL COMMENT '租户ID',
  `batch_no` VARCHAR(64) NOT NULL COMMENT '批次编号',
  `product_id` BIGINT UNSIGNED NOT NULL COMMENT '商品ID',
  `supplier_id` BIGINT UNSIGNED COMMENT '供应商ID',
  `production_date` DATE COMMENT '生产日期',
  `expire_date` DATE COMMENT '有效期至',
  `total_qty` DECIMAL(12,4) NOT NULL COMMENT '初始数量',
  `available_qty` DECIMAL(12,4) NOT NULL COMMENT '可用数量',
  `locked_qty` DECIMAL(12,4) NOT NULL DEFAULT 0 COMMENT '锁定数量',
  `cost_price` DECIMAL(12,4) NOT NULL COMMENT '成本单价',
  `batch_status` TINYINT NOT NULL DEFAULT 1 COMMENT '批次状态',
  `creator` BIGINT UNSIGNED COMMENT '创建人',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` BIGINT UNSIGNED COMMENT '更新人',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_batch_no` (`tenant_id`, `batch_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='批次表';
```

#### 4.3.9 库存台账表（inventory_ledger）

```sql
CREATE TABLE `inventory_ledger` (
  `id` BIGINT UNSIGNED NOT NULL COMMENT '主键ID',
  `tenant_id` BIGINT UNSIGNED NOT NULL COMMENT '租户ID',
  `warehouse_id` BIGINT UNSIGNED NOT NULL COMMENT '仓库ID',
  `product_id` BIGINT UNSIGNED NOT NULL COMMENT '商品ID',
  `batch_id` BIGINT UNSIGNED COMMENT '批次ID',
  `location_id` BIGINT UNSIGNED COMMENT '库位ID',
  `direction` TINYINT NOT NULL COMMENT '方向:1=入库,2=出库',
  `bill_type` VARCHAR(32) NOT NULL COMMENT '单据类型',
  `bill_id` BIGINT UNSIGNED NOT NULL COMMENT '单据ID',
  `change_qty` DECIMAL(12,4) NOT NULL COMMENT '变化数量',
  `before_qty` DECIMAL(12,4) NOT NULL COMMENT '变化前数量',
  `after_qty` DECIMAL(12,4) NOT NULL COMMENT '变化后数量',
  `change_time` DATETIME NOT NULL COMMENT '变化时间',
  `creator` BIGINT UNSIGNED COMMENT '创建人',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updater` BIGINT UNSIGNED COMMENT '更新人',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
  PRIMARY KEY (`id`),
  KEY `idx_warehouse_product` (`warehouse_id`, `product_id`),
  KEY `idx_change_time` (`change_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='库存台账表';
```

#### 4.3.10 库存汇总表（inventory_summary）

```sql
CREATE TABLE `inventory_summary` (
  `id` BIGINT UNSIGNED NOT NULL COMMENT '主键ID',
  `tenant_id` BIGINT UNSIGNED NOT NULL COMMENT '租户ID',
  `warehouse_id` BIGINT UNSIGNED NOT NULL COMMENT '仓库ID',
  `product_id` BIGINT UNSIGNED NOT NULL COMMENT '商品ID',
  `batch_id` BIGINT UNSIGNED COMMENT '批次ID',
  `location_id` BIGINT UNSIGNED COMMENT '库位ID',
  `stock_qty` DECIMAL(12,4) NOT NULL DEFAULT 0 COMMENT '库存数量',
  `available_qty` DECIMAL(12,4) NOT NULL DEFAULT 0 COMMENT '可用数量',
  `locked_qty` DECIMAL(12,4) NOT NULL DEFAULT 0 COMMENT '锁定数量',
  `cost_price` DECIMAL(12,4) DEFAULT 0 COMMENT '成本单价',
  `total_amount` DECIMAL(15,2) DEFAULT 0 COMMENT '库存金额',
  `version` INT NOT NULL DEFAULT 1 COMMENT '版本号(乐观锁)',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_warehouse_product_batch` (`tenant_id`, `warehouse_id`, `product_id`, `batch_id`, `location_id`),
  KEY `idx_available_qty` (`available_qty`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='库存汇总表';
```

---

## 五、缓存设计策略

### 5.1 缓存Key设计规范

| 模块 | Key Pattern | 示例 | TTL |
|------|-------------|------|-----|
| 商品信息 | `product:{tenantId}:{productId}` | `product:1:100001` | 1小时 |
| 客户信息 | `customer:{tenantId}:{customerId}` | `customer:1:200001` | 1小时 |
| 价格策略 | `price:policy:{tenantId}:{productId}:{level}` | `price:policy:1:100001:1` | 30分钟 |
| 实时库存 | `inventory:real:{tenantId}:{warehouseId}:{productId}` | `inventory:real:1:10:100001` | 1分钟 |
| 订单信息 | `order:{tenantId}:{orderId}` | `order:1:300001` | 1小时 |
| 用户Token | `token:{userId}` | `token:10001` | 2小时 |
| 分布式锁 | `lock:{resource}:{id}` | `lock:order:300001` | 30秒 |

### 5.2 缓存策略

**Read-Aside（旁路缓存）**：
- 读操作：先读缓存，缓存未命中则读数据库并回填缓存
- 写操作：先写数据库，再删除缓存

**缓存击穿解决方案**：
- 使用Redis SETNX实现分布式锁
- 锁超时时间设置为业务处理时间的2倍

---

## 六、API网关设计

### 6.1 网关路由配置

```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: product-service
          uri: lb://product-service
          predicates:
            - Path=/api/product/**
          filters:
            - StripPrefix=2
        
        - id: purchase-service
          uri: lb://purchase-service
          predicates:
            - Path=/api/purchase/**
          filters:
            - StripPrefix=2
            
        - id: sales-service
          uri: lb://sales-service
          predicates:
            - Path=/api/sales/**
          filters:
            - StripPrefix=2
            
        - id: warehouse-service
          uri: lb://warehouse-service
          predicates:
            - Path=/api/warehouse/**
          filters:
            - StripPrefix=2
            
        - id: finance-service
          uri: lb://finance-service
          predicates:
            - Path=/api/finance/**
          filters:
            - StripPrefix=2
```

### 6.2 全局过滤器链

1. **GatewayRateLimiterFilter** - 限流过滤器（基于Sentinel）
2. **GatewayAuthFilter** - 认证过滤器（JWT验证）
3. **GatewayLogFilter** - 日志过滤器
4. **GatewayHeaderFilter** - Header处理过滤器
5. **GatewayCorsFilter** - 跨域处理过滤器

---

## 七、前端技术架构

### 7.1 技术选型

| 技术 | 版本 | 说明 |
|------|------|------|
| Vue3 | 3.4+ | 前端框架 |
| TypeScript | 5.0+ | 类型系统 |
| Vite | 5.0+ | 构建工具 |
| Pinia | 2.1+ | 状态管理 |
| Vue Router | 4.x | 路由管理 |
| Element Plus | 2.5+ | UI组件库 |
| Axios | 1.6+ | HTTP客户端 |
| Apache ECharts | 5.4+ | 图表库 |

### 7.2 项目结构

```
src/
├── api/                 # API接口定义
│   ├── product/         # 商品模块接口
│   ├── purchase/        # 采购模块接口
│   ├── sales/           # 销售模块接口
│   ├── warehouse/       # 仓储模块接口
│   └── report/          # 报表模块接口
├── assets/              # 静态资源
│   ├── images/          # 图片资源
│   └── icons/           # 图标资源
├── components/          # 公共组件
│   ├── common/          # 通用组件
│   │   ├── SearchForm.vue       # 搜索表单组件
│   │   ├── PageTable.vue        # 分页表格组件
│   │   ├── UploadFile.vue       # 文件上传组件
│   │   └── ModalDialog.vue      # 弹窗组件
│   ├── business/        # 业务组件
│   │   ├── ProductCard.vue      # 商品卡片组件
│   │   ├── OrderDetail.vue      # 订单详情组件
│   │   └── InventoryChart.vue   # 库存图表组件
│   └── charts/          # ECharts图表组件
│       ├── BarChart.vue         # 柱状图组件
│       ├── LineChart.vue        # 折线图组件
│       ├── PieChart.vue         # 饼图组件
│       ├── RadarChart.vue       # 雷达图组件
│       ├── GaugeChart.vue       # 仪表盘组件
│       └── FunnelChart.vue      # 漏斗图组件
├── composables/         # 组合式函数
│   ├── useChart.ts      # 图表组合函数
│   ├── useTable.ts      # 表格组合函数
│   └── useForm.ts       # 表单组合函数
├── directives/          # 自定义指令
├── layouts/             # 布局组件
│   ├── AdminLayout.vue  # 后台布局
│   ├── Sidebar.vue      # 侧边栏
│   └── Header.vue       # 头部导航
├── router/              # 路由配置
├── stores/              # Pinia状态管理
│   ├── user.ts          # 用户状态
│   ├── product.ts       # 商品状态
│   ├── order.ts         # 订单状态
│   ├── inventory.ts     # 库存状态
│   └── report.ts        # 报表状态
├── styles/              # 全局样式
│   ├── variables.scss   # 样式变量
│   └── mixins.scss      # 样式混入
├── types/               # TypeScript类型定义
├── utils/               # 工具函数
│   ├── chart.ts         # 图表工具函数
│   ├── format.ts        # 格式化工具函数
│   └── validate.ts      # 验证工具函数
├── views/               # 页面组件
│   ├── product/         # 商品页面
│   ├── purchase/        # 采购页面
│   ├── sales/           # 销售页面
│   ├── warehouse/       # 仓储页面
│   └── report/          # 报表页面
├── App.vue              # 根组件
└── main.ts              # 入口文件
```

### 7.3 核心模块设计

#### 7.3.1 状态管理（Pinia）

```typescript
// stores/product.ts
import { defineStore } from 'pinia'
import { ref } from 'vue'
import type { Product, ProductQuery } from '@/types/product'
import { productApi } from '@/api/product'

export const useProductStore = defineStore('product', () => {
  const productList = ref<Product[]>([])
  const total = ref(0)
  const loading = ref(false)
  
  async function fetchProductList(query: ProductQuery) {
    loading.value = true
    try {
      const res = await productApi.list(query)
      productList.value = res.data.records
      total.value = res.data.total
    } finally {
      loading.value = false
    }
  }
  
  async function getProduct(id: number) {
    return await productApi.get(id)
  }
  
  async function createProduct(data: Product) {
    await productApi.create(data)
    await fetchProductList()
  }
  
  async function updateProduct(data: Product) {
    await productApi.update(data)
    await fetchProductList()
  }
  
  async function deleteProduct(id: number) {
    await productApi.delete(id)
    await fetchProductList()
  }
  
  return {
    productList,
    total,
    loading,
    fetchProductList,
    getProduct,
    createProduct,
    updateProduct,
    deleteProduct
  }
})
```

#### 7.3.2 API封装（Axios）

```typescript
// utils/request.ts
import axios from 'axios'
import type { AxiosInstance, AxiosRequestConfig, AxiosResponse } from 'axios'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/stores/user'

const service: AxiosInstance = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json'
  }
})

service.interceptors.request.use(
  (config) => {
    const userStore = useUserStore()
    if (userStore.token) {
      config.headers.Authorization = `Bearer ${userStore.token}`
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

service.interceptors.response.use(
  (response: AxiosResponse) => {
    const res = response.data
    if (res.code !== 200) {
      ElMessage.error(res.message || '请求失败')
      return Promise.reject(new Error(res.message || '请求失败'))
    }
    return res
  },
  (error) => {
    if (error.response?.status === 401) {
      const userStore = useUserStore()
      userStore.logout()
      window.location.href = '/login'
    }
    ElMessage.error(error.message || '网络错误')
    return Promise.reject(error)
  }
)

export default service
```

#### 7.3.3 ECharts图表组件设计

##### 7.3.3.1 通用图表组件基础封装

```typescript
// components/charts/BaseChart.vue
<template>
  <div ref="chartRef" :style="chartStyle"></div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted, watch, computed } from 'vue'
import * as echarts from 'echarts'

interface Props {
  option: echarts.EChartsOption
  width?: string
  height?: string
  autoresize?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  width: '100%',
  height: '400px',
  autoresize: true
})

const chartRef = ref<HTMLElement>()
let chartInstance: echarts.ECharts | null = null

const chartStyle = computed(() => ({
  width: props.width,
  height: props.height
}))

function initChart() {
  if (!chartRef.value) return
  chartInstance = echarts.init(chartRef.value)
  chartInstance.setOption(props.option)
}

function handleResize() {
  chartInstance?.resize()
}

onMounted(() => {
  initChart()
  if (props.autoresize) {
    window.addEventListener('resize', handleResize)
  }
})

onUnmounted(() => {
  if (props.autoresize) {
    window.removeEventListener('resize', handleResize)
  }
  chartInstance?.dispose()
})

watch(() => props.option, (newOption) => {
  chartInstance?.setOption(newOption, true)
}, { deep: true })
</script>
```

##### 7.3.3.2 柱状图组件（销售趋势分析）

```typescript
// components/charts/BarChart.vue
<template>
  <BaseChart :option="chartOption" :height="height" />
</template>

<script setup lang="ts">
import { computed } from 'vue'
import BaseChart from './BaseChart.vue'

interface Props {
  title?: string
  xData: string[]
  seriesData: { name: string; data: number[]; color?: string }[]
  height?: string
}

const props = withDefaults(defineProps<Props>(), {
  title: '',
  height: '350px'
})

const chartOption = computed(() => ({
  title: {
    text: props.title,
    left: 'center',
    textStyle: {
      fontSize: 16,
      fontWeight: 'bold',
      color: '#333'
    }
  },
  tooltip: {
    trigger: 'axis',
    axisPointer: {
      type: 'shadow'
    }
  },
  legend: {
    data: props.seriesData.map(s => s.name),
    bottom: 0
  },
  grid: {
    left: '3%',
    right: '4%',
    bottom: '15%',
    top: '15%',
    containLabel: true
  },
  xAxis: {
    type: 'category',
    data: props.xData,
    axisLine: {
      lineStyle: {
        color: '#ddd'
      }
    },
    axisLabel: {
      rotate: 30,
      color: '#666'
    }
  },
  yAxis: {
    type: 'value',
    axisLine: {
      show: false
    },
    axisTick: {
      show: false
    },
    splitLine: {
      lineStyle: {
        color: '#eee',
        type: 'dashed'
      }
    }
  },
  series: props.seriesData.map(item => ({
    name: item.name,
    type: 'bar',
    data: item.data,
    itemStyle: {
      color: item.color || getBarColor(item.name),
      borderRadius: [4, 4, 0, 0]
    },
    emphasis: {
      itemStyle: {
        shadowBlur: 10,
        shadowColor: 'rgba(0,0,0,0.3)'
      }
    }
  }))
}))

function getBarColor(name: string): string {
  const colors: Record<string, string> = {
    '销售额': '#5470c6',
    '订单数': '#91cc75',
    '利润': '#fac858',
    '成本': '#ee6666'
  }
  return colors[name] || '#73c0de'
}
</script>
```

##### 7.3.3.3 折线图组件（库存趋势监控）

```typescript
// components/charts/LineChart.vue
<template>
  <BaseChart :option="chartOption" :height="height" />
</template>

<script setup lang="ts">
import { computed } from 'vue'
import BaseChart from './BaseChart.vue'

interface Props {
  title?: string
  xData: string[]
  seriesData: { name: string; data: number[]; smooth?: boolean }[]
  height?: string
}

const props = withDefaults(defineProps<Props>(), {
  title: '',
  height: '350px'
})

const chartOption = computed(() => ({
  title: {
    text: props.title,
    left: 'center',
    textStyle: {
      fontSize: 16,
      fontWeight: 'bold',
      color: '#333'
    }
  },
  tooltip: {
    trigger: 'axis',
    backgroundColor: 'rgba(255,255,255,0.95)',
    borderColor: '#e0e0e0',
    borderWidth: 1,
    textStyle: {
      color: '#333'
    }
  },
  legend: {
    data: props.seriesData.map(s => s.name),
    bottom: 0
  },
  grid: {
    left: '3%',
    right: '4%',
    bottom: '15%',
    top: '15%',
    containLabel: true
  },
  xAxis: {
    type: 'category',
    boundaryGap: false,
    data: props.xData,
    axisLine: {
      lineStyle: {
        color: '#ddd'
      }
    },
    axisLabel: {
      color: '#666'
    }
  },
  yAxis: {
    type: 'value',
    axisLine: {
      show: false
    },
    axisTick: {
      show: false
    },
    splitLine: {
      lineStyle: {
        color: '#eee',
        type: 'dashed'
      }
    }
  },
  series: props.seriesData.map((item, index) => ({
    name: item.name,
    type: 'line',
    smooth: item.smooth !== undefined ? item.smooth : true,
    data: item.data,
    lineStyle: {
      width: 3
    },
    itemStyle: {
      color: getLineColor(index)
    },
    areaStyle: {
      color: {
        type: 'linear',
        x: 0,
        y: 0,
        x2: 0,
        y2: 1,
        colorStops: [
          { offset: 0, color: getAreaColor(index, 0.3) },
          { offset: 1, color: getAreaColor(index, 0.05) }
        ]
      }
    },
    symbol: 'circle',
    symbolSize: 8,
    emphasis: {
      focus: 'series',
      itemStyle: {
        borderWidth: 2,
        borderColor: '#fff',
        shadowBlur: 10,
        shadowColor: 'rgba(0,0,0,0.3)'
      }
    }
  }))
}))

function getLineColor(index: number): string {
  const colors = ['#5470c6', '#91cc75', '#fac858', '#ee6666', '#73c0de', '#3ba272']
  return colors[index % colors.length]
}

function getAreaColor(index: number, alpha: number): string {
  const colors = ['#5470c6', '#91cc75', '#fac858', '#ee6666', '#73c0de', '#3ba272']
  const color = colors[index % colors.length]
  return color.replace(')', `,${alpha})`).replace('rgb', 'rgba') || color
}
</script>
```

##### 7.3.3.4 饼图组件（销售占比分析）

```typescript
// components/charts/PieChart.vue
<template>
  <BaseChart :option="chartOption" :height="height" />
</template>

<script setup lang="ts">
import { computed } from 'vue'
import BaseChart from './BaseChart.vue'

interface Props {
  title?: string
  data: { name: string; value: number; itemStyle?: { color: string } }[]
  height?: string
  radius?: string[]
}

const props = withDefaults(defineProps<Props>(), {
  title: '',
  height: '350px',
  radius: () => ['45%', '70%']
})

const chartOption = computed(() => ({
  title: {
    text: props.title,
    left: 'center',
    textStyle: {
      fontSize: 16,
      fontWeight: 'bold',
      color: '#333'
    }
  },
  tooltip: {
    trigger: 'item',
    formatter: '{b}: {c} ({d}%)'
  },
  legend: {
    orient: 'vertical',
    right: '5%',
    top: 'center',
    textStyle: {
      color: '#666'
    }
  },
  series: [
    {
      name: props.title,
      type: 'pie',
      radius: props.radius,
      center: ['40%', '50%'],
      avoidLabelOverlap: false,
      itemStyle: {
        borderRadius: 8,
        borderColor: '#fff',
        borderWidth: 2
      },
      label: {
        show: true,
        formatter: '{b}\n{d}%'
      },
      emphasis: {
        label: {
          show: true,
          fontSize: 14,
          fontWeight: 'bold'
        },
        itemStyle: {
          shadowBlur: 10,
          shadowOffsetX: 0,
          shadowColor: 'rgba(0, 0, 0, 0.5)'
        }
      },
      labelLine: {
        show: true,
        length: 15,
        length2: 10
      },
      data: props.data.map((item, index) => ({
        ...item,
        itemStyle: item.itemStyle || { color: getPieColor(index) }
      }))
    }
  ]
}))

function getPieColor(index: number): string {
  const colors = ['#5470c6', '#91cc75', '#fac858', '#ee6666', '#73c0de', '#3ba272', '#fc8452', '#9a60b4']
  return colors[index % colors.length]
}
</script>
```

##### 7.3.3.5 仪表盘组件（库存健康度）

```typescript
// components/charts/GaugeChart.vue
<template>
  <BaseChart :option="chartOption" :height="height" />
</template>

<script setup lang="ts">
import { computed } from 'vue'
import BaseChart from './BaseChart.vue'

interface Props {
  title?: string
  value: number
  min?: number
  max?: number
  unit?: string
  height?: string
}

const props = withDefaults(defineProps<Props>(), {
  title: '',
  min: 0,
  max: 100,
  unit: '%',
  height: '300px'
})

const chartOption = computed(() => {
  const percent = ((props.value - props.min) / (props.max - props.min)) * 100
  let color = '#5470c6'
  if (percent >= 80) color = '#91cc75'
  else if (percent >= 50) color = '#fac858'
  else color = '#ee6666'

  return {
    title: {
      text: props.title,
      left: 'center',
      top: '5%',
      textStyle: {
        fontSize: 16,
        fontWeight: 'bold',
        color: '#333'
      }
    },
    series: [
      {
        type: 'gauge',
        radius: '90%',
        startAngle: 180,
        endAngle: 0,
        min: props.min,
        max: props.max,
        splitNumber: 10,
        itemStyle: {
          color: color,
          shadowColor: color,
          shadowBlur: 10,
          shadowOffsetX: 2,
          shadowOffsetY: 2
        },
        progress: {
          show: true,
          overlap: false,
          roundCap: true,
          clip: false,
          itemStyle: {
            color: {
              type: 'linear',
              x: 0,
              y: 0,
              x2: 1,
              y2: 0,
              colorStops: [
                { offset: 0, color: '#ee6666' },
                { offset: 0.5, color: '#fac858' },
                { offset: 1, color: '#91cc75' }
              ]
            }
          }
        },
        pointer: {
          show: false
        },
        axisLine: {
          lineStyle: {
            width: 15,
            color: [[1, '#e8e8e8']]
          }
        },
        axisTick: {
          show: false
        },
        splitLine: {
          show: false
        },
        axisLabel: {
          show: false
        },
        detail: {
          valueAnimation: true,
          offsetCenter: [0, 0],
          fontSize: 32,
          fontWeight: 'bold',
          color: '#333',
          formatter: `{value}${props.unit}`
        },
        data: [
          {
            value: props.value,
            name: ''
          }
        ]
      }
    ]
  }
})
</script>
```

##### 7.3.3.6 图表工具函数

```typescript
// utils/chart.ts
import type { EChartsOption } from 'echarts'

export interface ChartDataItem {
  name: string
  value: number
}

export interface SeriesConfig {
  name: string
  data: number[]
  color?: string
}

export function createBarOption(
  title: string,
  xData: string[],
  series: SeriesConfig[]
): EChartsOption {
  return {
    title: { text: title, left: 'center' },
    tooltip: { trigger: 'axis' },
    legend: { data: series.map(s => s.name), bottom: 0 },
    grid: { left: '3%', right: '4%', bottom: '15%', top: '15%', containLabel: true },
    xAxis: { type: 'category', data: xData },
    yAxis: { type: 'value' },
    series: series.map(s => ({
      name: s.name,
      type: 'bar',
      data: s.data,
      itemStyle: { color: s.color }
    }))
  }
}

export function createLineOption(
  title: string,
  xData: string[],
  series: SeriesConfig[]
): EChartsOption {
  return {
    title: { text: title, left: 'center' },
    tooltip: { trigger: 'axis' },
    legend: { data: series.map(s => s.name), bottom: 0 },
    grid: { left: '3%', right: '4%', bottom: '15%', top: '15%', containLabel: true },
    xAxis: { type: 'category', boundaryGap: false, data: xData },
    yAxis: { type: 'value' },
    series: series.map(s => ({
      name: s.name,
      type: 'line',
      smooth: true,
      data: s.data,
      lineStyle: { color: s.color, width: 3 },
      itemStyle: { color: s.color }
    }))
  }
}

export function createPieOption(title: string, data: ChartDataItem[]): EChartsOption {
  const colors = ['#5470c6', '#91cc75', '#fac858', '#ee6666', '#73c0de', '#3ba272']
  return {
    title: { text: title, left: 'center' },
    tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
    legend: { orient: 'vertical', right: '5%', top: 'center' },
    series: [{
      name: title,
      type: 'pie',
      radius: ['45%', '70%'],
      center: ['40%', '50%'],
      data: data.map((item, index) => ({
        ...item,
        itemStyle: { color: item['itemStyle']?.color || colors[index % colors.length] }
      }))
    }]
  }
}
```

---

## 八、后端组件设计

### 8.1 通用组件

#### 8.1.1 响应封装组件

```java
// com.example.common.response.Result.java
public class Result<T> {
    private Integer code;
    private String message;
    private T data;
    private Long timestamp;

    private Result(Integer code, String message, T data) {
        this.code = code;
        this.message = message;
        this.data = data;
        this.timestamp = System.currentTimeMillis();
    }

    public static <T> Result<T> success(T data) {
        return new Result<>(200, "success", data);
    }

    public static <T> Result<T> success(String message, T data) {
        return new Result<>(200, message, data);
    }

    public static <T> Result<T> error(Integer code, String message) {
        return new Result<>(code, message, null);
    }

    public static <T> Result<T> error(String message) {
        return new Result<>(500, message, null);
    }
    
    // Getters and Setters
}
```

#### 8.1.2 分页封装组件

```java
// com.example.common.response.PageResult.java
public class PageResult<T> {
    private List<T> records;
    private Long total;
    private Integer current;
    private Integer size;

    public PageResult(List<T> records, Long total, Integer current, Integer size) {
        this.records = records;
        this.total = total;
        this.current = current;
        this.size = size;
    }

    public static <T> PageResult<T> of(IPage<T> page) {
        return new PageResult<>(page.getRecords(), page.getTotal(), 
            (int) page.getCurrent(), (int) page.getSize());
    }
    
    // Getters and Setters
}
```

#### 8.1.3 全局异常处理组件

```java
// com.example.common.exception.GlobalExceptionHandler.java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ServiceException.class)
    public Result<Void> handleServiceException(ServiceException e) {
        log.error("业务异常: {}", e.getMessage());
        return Result.error(e.getCode(), e.getMessage());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public Result<Void> handleValidationException(MethodArgumentNotValidException e) {
        String message = e.getBindingResult().getFieldErrors().stream()
            .map(FieldError::getDefaultMessage)
            .collect(Collectors.joining(", "));
        return Result.error(400, message);
    }

    @ExceptionHandler(Exception.class)
    public Result<Void> handleException(Exception e) {
        log.error("系统异常", e);
        return Result.error("系统内部错误");
    }
}
```

### 8.2 业务组件

#### 8.2.1 库存操作组件

```java
// com.example.warehouse.component.InventoryOperationComponent.java
@Component
public class InventoryOperationComponent {

    @Autowired
    private InventoryMapper inventoryMapper;
    
    @Autowired
    private StringRedisTemplate redisTemplate;

    @Transactional(rollbackFor = Exception.class)
    public void increaseStock(Long warehouseId, Long productId, BigDecimal quantity) {
        String key = String.format("inventory:real:%d:%d:%d", 
            TenantContext.getTenantId(), warehouseId, productId);
        
        // 更新数据库
        inventoryMapper.increaseStock(warehouseId, productId, quantity);
        
        // 更新缓存（删除缓存，下次读取时重建）
        redisTemplate.delete(key);
    }

    @Transactional(rollbackFor = Exception.class)
    public boolean decreaseStock(Long warehouseId, Long productId, BigDecimal quantity) {
        String key = String.format("inventory:real:%d:%d:%d", 
            TenantContext.getTenantId(), warehouseId, productId);
        
        // 先检查库存
        BigDecimal currentStock = inventoryMapper.getStock(warehouseId, productId);
        if (currentStock.compareTo(quantity) < 0) {
            return false;
        }
        
        // 更新数据库
        inventoryMapper.decreaseStock(warehouseId, productId, quantity);
        
        // 更新缓存
        redisTemplate.delete(key);
        return true;
    }
}
```

#### 8.2.2 消息推送组件（简化版）

```java
// com.example.system.component.NotificationComponent.java
@Component
public class NotificationComponent {

    @Autowired
    private NotificationMapper notificationMapper;

    public void createNotification(Long userId, String title, String content) {
        Notification notification = Notification.builder()
            .userId(userId)
            .title(title)
            .content(content)
            .status(0) // 未读
            .createTime(LocalDateTime.now())
            .build();
        
        notificationMapper.insert(notification);
    }

    public void createOrderNotification(Long userId, Long orderId, String message) {
        createNotification(userId, "订单通知", 
            String.format("订单[%d]%s", orderId, message));
    }

    public void createInventoryAlert(Long userId, Long productId, BigDecimal stock) {
        createNotification(userId, "库存预警", 
            String.format("商品ID[%d]库存不足，当前库存: %s", productId, stock));
    }
}
```

#### 8.2.3 数据导出组件

```java
// com.example.common.component.DataExportComponent.java
@Component
public class DataExportComponent {

    public byte[] exportToExcel(List<?> dataList, Class<?> clazz) throws Exception {
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("数据导出");
        
        // 获取字段注解
        Field[] fields = clazz.getDeclaredFields();
        List<String> headers = Arrays.stream(fields)
            .map(f -> {
                ExcelColumn annotation = f.getAnnotation(ExcelColumn.class);
                return annotation != null ? annotation.value() : f.getName();
            })
            .collect(Collectors.toList());
        
        // 创建表头
        Row headerRow = sheet.createRow(0);
        for (int i = 0; i < headers.size(); i++) {
            headerRow.createCell(i).setCellValue(headers.get(i));
        }
        
        // 填充数据
        int rowNum = 1;
        for (Object data : dataList) {
            Row row = sheet.createRow(rowNum++);
            for (int i = 0; i < fields.length; i++) {
                fields[i].setAccessible(true);
                Object value = fields[i].get(data);
                row.createCell(i).setCellValue(value != null ? value.toString() : "");
            }
        }
        
        // 写入字节数组
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        workbook.write(outputStream);
        workbook.close();
        
        return outputStream.toByteArray();
    }
}
```

---

## 九、安全设计

### 8.1 认证与授权

- **认证方式**：JWT Token + Refresh Token
- **Token有效期**：Access Token 2小时，Refresh Token 7天
- **授权框架**：Spring Security + OAuth2

### 8.2 数据安全

- **传输加密**：HTTPS/TLS 1.3
- **敏感数据加密**：AES-256-GCM
- **密码加密**：BCrypt
- **数据脱敏**：演示环境和报表展示

### 8.3 权限控制

- **功能权限**：RBAC模型
- **数据权限**：行级权限（租户隔离）
- **字段权限**：敏感字段可见性控制

---

## 九、部署架构（精简版）

### 9.1 Docker Compose部署架构

```
┌─────────────────────────────────────────────────────────────────┐
│                     Docker Compose                             │
├─────────────────────────────────────────────────────────────────┤
│  ┌───────────┐   ┌───────────┐   ┌───────────┐                │
│  │   Nginx   │──▶│  Gateway  │──▶│  Auth     │                │
│  │ (反向代理) │   │ (API网关) │   │ (认证服务)│                │
│  └───────────┘   └───────────┘   └─────┬─────┘                │
│                                        │                       │
│  ┌───────────┐   ┌───────────┐   ┌─────┴─────┐                │
│  │  Product  │◀──│  Sales    │◀──│ Warehouse │                │
│  │  Service  │   │  Service  │   │  Service  │                │
│  └───────────┘   └───────────┘   └───────────┘                │
│        │               │               │                       │
│        └───────────────┴───────┬───────┘                       │
│                                ▼                               │
│                    ┌───────────────────┐                       │
│                    │     Nacos         │                       │
│                    │ (注册/配置中心)   │                       │
│                    └───────────────────┘                       │
│                                │                               │
│        ┌────────────────────────┼────────────────────────┐     │
│        ▼                        ▼                        ▼     │
│  ┌───────────┐         ┌───────────┐         ┌───────────┐   │
│  │   MySQL   │         │   Redis   │         │  Finance  │   │
│  │ (数据库)  │         │  (缓存)   │         │  Service  │   │
│  └───────────┘         └───────────┘         └───────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### 9.2 中间件部署（精简版）

| 中间件 | 部署模式 | 说明 |
|--------|---------|------|
| MySQL | 单实例 | 数据持久化（后期可扩展为主从） |
| Redis | 主从模式 | 缓存+Session共享 |
| Nacos | 单节点 | 注册中心+配置中心（后期可扩展为集群） | `http://192.168.1.20:8848/` |

### 9.3 Nacos配置管理

#### 9.3.1 Nacos配置参数

| 参数 | 值 | 说明 |
|------|-----|------|
| **服务地址** | `192.168.1.20:8848` | Nacos Server地址 |
| **命名空间** | `ai-dev` | 开发环境命名空间 |
| **Group** | `dev` | 配置分组 |
| **共享配置** | `common.yml` | 所有服务共享的基础配置 |

#### 9.3.2 Nacos配置结构

```
ai-dev (命名空间)
├── dev (Group)
│   ├── common.yml              # 共享配置（数据库、Redis、JWT等）
│   ├── invoicing-gateway.yml   # 网关服务配置
│   ├── auth-service.yml        # 认证服务配置
│   └── product-service.yml     # 商品服务配置
```

#### 9.3.3 共享配置 common.yml 内容

```yaml
spring:
  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://127.0.0.1:3306/invoicing?useUnicode=true&characterEncoding=utf-8&serverTimezone=Asia/Shanghai&useSSL=false
    username: ${DB_USERNAME:root}
    password: ${DB_PASSWORD:root}
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 30000
      idle-timeout: 600000
      max-lifetime: 1800000

  data:
    redis:
      host: ${REDIS_HOST:127.0.0.1}
      port: ${REDIS_PORT:6379}
      password: ${REDIS_PASSWORD:}
      database: 0
      timeout: 3000
      lettuce:
        pool:
          max-active: 20
          max-idle: 10
          min-idle: 5
          max-wait: -1ms
      cluster:
        max-redirects: 3

jwt:
  secret: invoicing-secret-key-for-jwt-token-must-be-at-least-256-bits
  access-token-expire: 7200
  refresh-token-expire: 604800

mybatis-plus:
  configuration:
    map-underscore-to-camel-case: true
    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl
  global-config:
    db-config:
      id-type: auto
      logic-delete-field: deleted
      logic-delete-value: 1
      logic-not-delete-value: 0
  mapper-locations: classpath*:/mapper/**/*.xml

logging:
  level:
    root: INFO
    com.invoicing: DEBUG
    org.springframework.cloud: INFO
    org.springframework.data.redis: DEBUG
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"
```

#### 9.3.4 本地配置文件说明

所有Nacos配置文件示例存放在项目根目录的 `config/` 文件夹下：

```
invoicing-backend/
└── config/
    ├── common.yml                  # 共享配置
    ├── invoicing-gateway.yml       # 网关服务配置
    ├── auth-service.yml            # 认证服务配置
    ├── product-service.yml         # 商品服务配置
    ├── purchase-service.yml        # 采购服务配置
    ├── sales-service.yml           # 销售服务配置
    └── inventory-service.yml       # 库存服务配置
```

各服务本地配置文件（`application.yml`）仅包含Nacos连接信息，其余配置均从Nacos读取：

```yaml
spring:
  application:
    name: <service-name>
  cloud:
    nacos:
      server-addr: 192.168.1.20:8848
      username: nacos
      password: nacos
      config:
        namespace: ai-dev
        group: dev
        file-extension: yml
        shared-configs:
          - data-id: common.yml
            group: dev
            refresh: true
        extension-configs:
          - data-id: <service-name>.yml
            group: dev
            refresh: true
      discovery:
        namespace: ai-dev
        group: dev
```

#### 9.3.5 数据库拆分说明

数据库已按业务领域拆分为以下独立数据库：

| 数据库名称 | 所属服务 | 端口 | 主要表 |
|-----------|---------|-----|-------|
| `invoicing_auth` | 认证服务 | 8081 | sys_user, sys_role |
| `invoicing_product` | 商品服务 | 8082 | product_base, product_category, supplier, warehouse, warehouse_location |
| `invoicing_purchase` | 采购服务 | 8083 | purchase_order, purchase_order_detail, purchase_receipt |
| `invoicing_sales` | 销售服务 | 8084 | sales_order, sales_order_detail, customer, sales_delivery |
| `invoicing_inventory` | 库存服务 | 8085 | batch, inventory_ledger, inventory_summary, inventory_flow |

各数据库的初始化脚本位于：`invoicing-backend/scripts/`

### 9.4 docker-compose.yml 示例

```yaml
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    container_name: invoicing-mysql
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: invoicing
    ports:
      - "3306:3306"
    volumes:
      - mysql-data:/var/lib/mysql
    restart: always

  redis:
    image: redis:7.2
    container_name: invoicing-redis
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    restart: always

  nginx:
    image: nginx:latest
    container_name: invoicing-nginx
    ports:
      - "80:80"
    volumes:
      - ./nginx/conf.d:/etc/nginx/conf.d
    depends_on:
      - gateway
    restart: always

volumes:
  mysql-data:
  redis-data:
```

> **说明**：Nacos服务使用外部部署的 `http://192.168.1.20:8848/`，无需在docker-compose中启动本地容器。

---

## 十、技术实现路径（精简版）

### 10.1 实施阶段划分

| 阶段 | 周期 | 主要内容 | 交付物 |
|------|------|---------|--------|
| **第一阶段** | 3周 | 基础架构搭建、服务框架初始化 | 微服务脚手架、Nacos配置中心、网关基础功能 |
| **第二阶段** | 5周 | 核心业务开发（商品、采购、销售） | 商品管理、采购管理、销售管理模块 |
| **第三阶段** | 3周 | 仓储管理开发 | 仓库管理、库位管理、库存管理、批次管理 |
| **第四阶段** | 3周 | 财务管理开发 | 应收应付、凭证管理、发票管理 |
| **第五阶段** | 2周 | 系统功能开发 | 用户管理、权限控制、消息通知 |
| **第六阶段** | 2周 | 前端开发 | 各模块前端页面、报表看板 |
| **第七阶段** | 1周 | 部署上线 | Docker Compose部署、基础监控配置 |

### 10.2 关键技术决策（精简版）

| 决策点 | 选择 | 理由 |
|--------|------|------|
| 服务框架 | Spring Boot + Spring Cloud | 社区成熟，生态完善，学习成本低 |
| ORM框架 | MyBatis-Plus | 简化CRUD，支持分页插件，社区活跃 |
| 注册配置中心 | Nacos | 一站式解决方案，配置热更新 |
| 服务限流 | Sentinel | 轻量级，与Spring Cloud集成良好 |
| 前端状态管理 | Pinia | Vue3官方推荐，比Vuex更轻量 |
| UI组件库 | Element Plus | Vue3版本，企业级组件库首选 |
| 异步处理 | 本地消息表+定时任务 | 降低复杂度，避免MQ运维成本 |
| 部署方式 | Docker Compose | 简化部署，适合中小型项目 |

---

## 十一、文档说明

**文档版本**: V1.0
**生成日期**: 2026年5月
**数据来源**: 需求文档 requirements.md
