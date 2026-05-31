-- 库存服务数据库初始化脚本
-- 数据库：invoicing_inventory
-- 创建时间：2026-05-28

-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS invoicing_inventory DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE invoicing_inventory;

-- ============================================
-- 1. 批次表 (batch)
-- ============================================
DROP TABLE IF EXISTS batch;
CREATE TABLE batch (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    tenant_id BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '租户ID',
    batch_no VARCHAR(64) NOT NULL COMMENT '批次编号',
    product_id BIGINT UNSIGNED NOT NULL COMMENT '商品ID',
    supplier_id BIGINT UNSIGNED COMMENT '供应商ID',
    production_date DATE COMMENT '生产日期',
    expire_date DATE COMMENT '有效期至',
    total_qty DECIMAL(12,4) NOT NULL COMMENT '初始数量',
    available_qty DECIMAL(12,4) NOT NULL COMMENT '可用数量',
    locked_qty DECIMAL(12,4) NOT NULL DEFAULT 0 COMMENT '锁定数量',
    cost_price DECIMAL(12,4) NOT NULL COMMENT '成本单价',
    batch_status TINYINT NOT NULL DEFAULT 1 COMMENT '批次状态',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
    PRIMARY KEY (id),
    UNIQUE KEY uk_tenant_batch_no (tenant_id, batch_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='批次表';

-- ============================================
-- 2. 库存台账表 (inventory_ledger)
-- ============================================
DROP TABLE IF EXISTS inventory_ledger;
CREATE TABLE inventory_ledger (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    tenant_id BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '租户ID',
    warehouse_id BIGINT UNSIGNED NOT NULL COMMENT '仓库ID',
    product_id BIGINT UNSIGNED NOT NULL COMMENT '商品ID',
    batch_no VARCHAR(64) COMMENT '批次编号',
    location_code VARCHAR(32) COMMENT '库位编码',
    qty DECIMAL(12,4) NOT NULL DEFAULT 0 COMMENT '可用数量',
    locked_qty DECIMAL(12,4) NOT NULL DEFAULT 0 COMMENT '锁定数量',
    cost_price DECIMAL(12,4) NOT NULL DEFAULT 0 COMMENT '成本单价',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_tenant_wh_product (tenant_id, warehouse_id, product_id, batch_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='库存台账表';

-- ============================================
-- 3. 库存汇总表 (inventory_summary)
-- ============================================
DROP TABLE IF EXISTS inventory_summary;
CREATE TABLE inventory_summary (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    tenant_id BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '租户ID',
    warehouse_id BIGINT UNSIGNED NOT NULL COMMENT '仓库ID',
    product_id BIGINT UNSIGNED NOT NULL COMMENT '商品ID',
    total_qty DECIMAL(12,4) NOT NULL DEFAULT 0 COMMENT '总库存数量',
    available_qty DECIMAL(12,4) NOT NULL DEFAULT 0 COMMENT '可用数量',
    locked_qty DECIMAL(12,4) NOT NULL DEFAULT 0 COMMENT '锁定数量',
    total_value DECIMAL(15,2) NOT NULL DEFAULT 0 COMMENT '库存总价值',
    avg_cost DECIMAL(12,4) COMMENT '平均成本',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_tenant_wh_product (tenant_id, warehouse_id, product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='库存汇总表';

-- ============================================
-- 4. 库存流水表 (inventory_flow)
-- ============================================
DROP TABLE IF EXISTS inventory_flow;
CREATE TABLE inventory_flow (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    tenant_id BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '租户ID',
    flow_no VARCHAR(64) NOT NULL COMMENT '流水号',
    flow_type TINYINT NOT NULL COMMENT '流水类型:1=采购入库,2=销售出库,3=退货入库,4=调拨出库,5=调拨入库,6=盘点调整,7=其它',
    business_type VARCHAR(32) NOT NULL COMMENT '业务类型:PO=采购,SO=销售,TF=调拨,CK=盘点',
    business_no VARCHAR(64) COMMENT '业务单号',
    warehouse_id BIGINT UNSIGNED NOT NULL COMMENT '仓库ID',
    location_id BIGINT UNSIGNED COMMENT '库位ID',
    product_id BIGINT UNSIGNED NOT NULL COMMENT '商品ID',
    product_code VARCHAR(64) NOT NULL COMMENT '商品编码',
    batch_no VARCHAR(64) COMMENT '批次编号',
    quantity_before INT NOT NULL DEFAULT 0 COMMENT '变动前数量',
    quantity_change INT NOT NULL COMMENT '变动数量(正=入库,负=出库)',
    quantity_after INT NOT NULL DEFAULT 0 COMMENT '变动后数量',
    cost_price DECIMAL(12,4) COMMENT '成本单价',
    remark VARCHAR(512) COMMENT '备注',
    operator BIGINT UNSIGNED COMMENT '操作人',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_tenant_flow_no (tenant_id, flow_no),
    KEY idx_warehouse_id (warehouse_id),
    KEY idx_product_id (product_id),
    KEY idx_business_no (business_no),
    KEY idx_flow_type (flow_type),
    KEY idx_create_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='库存流水表';

COMMIT;
