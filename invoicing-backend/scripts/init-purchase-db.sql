-- 采购服务数据库初始化脚本
-- 数据库：invoicing_purchase
-- 创建时间：2026-05-28

-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS invoicing_purchase DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE invoicing_purchase;

-- ============================================
-- 1. 采购订单表 (purchase_order)
-- ============================================
DROP TABLE IF EXISTS purchase_order;
CREATE TABLE purchase_order (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    tenant_id BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '租户ID',
    order_no VARCHAR(64) NOT NULL COMMENT '采购订单号',
    supplier_id BIGINT UNSIGNED NOT NULL COMMENT '供应商ID',
    supplier_name VARCHAR(255) NOT NULL COMMENT '供应商名称',
    contact_name VARCHAR(64) COMMENT '联系人',
    contact_phone VARCHAR(32) COMMENT '联系电话',
    total_amount DECIMAL(15,2) NOT NULL DEFAULT 0 COMMENT '订单总金额',
    discount_amount DECIMAL(15,2) DEFAULT 0 COMMENT '折扣金额',
    payable_amount DECIMAL(15,2) NOT NULL DEFAULT 0 COMMENT '应付金额',
    paid_amount DECIMAL(15,2) DEFAULT 0 COMMENT '已付金额',
    order_date DATE NOT NULL COMMENT '订货日期',
    delivery_date DATE COMMENT '预计交货日期',
    actual_delivery_date DATE COMMENT '实际交货日期',
    approval_status TINYINT NOT NULL DEFAULT 1 COMMENT '审批状态:1=待审批,2=已通过,3=已驳回',
    order_status TINYINT NOT NULL DEFAULT 1 COMMENT '订单状态:1=待确认,2=已确认,3=已发货,4=已完成,5=已取消',
    invoice_status TINYINT NOT NULL DEFAULT 0 COMMENT '开票状态:0=未开票,1=已开票',
    remark VARCHAR(512) COMMENT '备注',
    creator BIGINT UNSIGNED COMMENT '创建人',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
    PRIMARY KEY (id),
    UNIQUE KEY uk_tenant_order_no (tenant_id, order_no),
    KEY idx_supplier_id (supplier_id),
    KEY idx_order_status (order_status),
    KEY idx_approval_status (approval_status),
    KEY idx_order_date (order_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='采购订单表';

-- ============================================
-- 2. 采购订单明细表 (purchase_order_detail)
-- ============================================
DROP TABLE IF EXISTS purchase_order_detail;
CREATE TABLE purchase_order_detail (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    tenant_id BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '租户ID',
    order_id BIGINT UNSIGNED NOT NULL COMMENT '订单ID',
    product_id BIGINT UNSIGNED NOT NULL COMMENT '商品ID',
    product_code VARCHAR(64) NOT NULL COMMENT '商品编码',
    product_name VARCHAR(255) NOT NULL COMMENT '商品名称',
    spec VARCHAR(128) COMMENT '规格',
    unit VARCHAR(32) COMMENT '单位',
    quantity INT NOT NULL DEFAULT 1 COMMENT '订购数量',
    delivered_quantity INT NOT NULL DEFAULT 0 COMMENT '已发货数量',
    received_quantity INT NOT NULL DEFAULT 0 COMMENT '已收货数量',
    unit_price DECIMAL(12,4) NOT NULL DEFAULT 0 COMMENT '单价',
    discount_rate DECIMAL(5,4) DEFAULT 1 COMMENT '折扣率',
    amount DECIMAL(15,2) NOT NULL DEFAULT 0 COMMENT '金额',
    tax_rate DECIMAL(5,4) DEFAULT 0 COMMENT '税率',
    tax_amount DECIMAL(12,2) DEFAULT 0 COMMENT '税额',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
    PRIMARY KEY (id),
    KEY idx_order_id (order_id),
    KEY idx_product_id (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='采购订单明细表';

-- ============================================
-- 3. 采购入库单表 (purchase_receipt) - 待扩展
-- ============================================
DROP TABLE IF EXISTS purchase_receipt;
CREATE TABLE purchase_receipt (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    tenant_id BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '租户ID',
    receipt_no VARCHAR(64) NOT NULL COMMENT '入库单号',
    order_id BIGINT UNSIGNED COMMENT '关联采购订单ID',
    supplier_id BIGINT UNSIGNED NOT NULL COMMENT '供应商ID',
    warehouse_id BIGINT UNSIGNED NOT NULL COMMENT '仓库ID',
    total_quantity INT NOT NULL DEFAULT 0 COMMENT '总数量',
    total_amount DECIMAL(15,2) NOT NULL DEFAULT 0 COMMENT '总金额',
    receipt_date DATE NOT NULL COMMENT '入库日期',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '状态:1=待入库,2=已入库,3=已取消',
    remark VARCHAR(512) COMMENT '备注',
    creator BIGINT UNSIGNED COMMENT '创建人',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
    PRIMARY KEY (id),
    UNIQUE KEY uk_tenant_receipt_no (tenant_id, receipt_no),
    KEY idx_order_id (order_id),
    KEY idx_supplier_id (supplier_id),
    KEY idx_warehouse_id (warehouse_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='采购入库单表';

COMMIT;
