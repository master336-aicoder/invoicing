-- 销售服务数据库初始化脚本
-- 数据库：invoicing_sales
-- 创建时间：2026-05-28

-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS invoicing_sales DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE invoicing_sales;

-- ============================================
-- 1. 客户表 (customer)
-- ============================================
DROP TABLE IF EXISTS customer;
CREATE TABLE customer (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    tenant_id BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '租户ID',
    customer_code VARCHAR(64) NOT NULL COMMENT '客户编码',
    customer_name VARCHAR(255) NOT NULL COMMENT '客户名称',
    customer_type TINYINT NOT NULL DEFAULT 1 COMMENT '客户类型:1=企业,2=个人',
    customer_level TINYINT NOT NULL DEFAULT 3 COMMENT '客户等级:1-5',
    contact_name VARCHAR(64) COMMENT '联系人',
    contact_phone VARCHAR(32) COMMENT '联系电话',
    contact_email VARCHAR(128) COMMENT '联系邮箱',
    address VARCHAR(512) COMMENT '地址',
    credit_level TINYINT COMMENT '信用等级',
    credit_amount DECIMAL(15,2) DEFAULT 0 COMMENT '信用额度',
    used_credit_amount DECIMAL(15,2) DEFAULT 0 COMMENT '已用信用额度',
    payment_days INT DEFAULT 0 COMMENT '账期(天)',
    freeze_status TINYINT NOT NULL DEFAULT 0 COMMENT '冻结状态:0=正常,1=冻结',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '状态:0=禁用,1=启用',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
    PRIMARY KEY (id),
    UNIQUE KEY uk_tenant_customer_code (tenant_id, customer_code),
    KEY idx_customer_name (customer_name),
    KEY idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='客户表';

-- ============================================
-- 2. 销售订单表 (sales_order)
-- ============================================
DROP TABLE IF EXISTS sales_order;
CREATE TABLE sales_order (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    tenant_id BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '租户ID',
    order_no VARCHAR(64) NOT NULL COMMENT '销售订单号',
    channel VARCHAR(32) NOT NULL DEFAULT 'OFFLINE' COMMENT '销售渠道',
    customer_id BIGINT UNSIGNED NOT NULL COMMENT '客户ID',
    customer_name VARCHAR(255) NOT NULL COMMENT '客户名称',
    contact_name VARCHAR(64) COMMENT '联系人',
    contact_phone VARCHAR(32) COMMENT '联系电话',
    shipping_address VARCHAR(512) COMMENT '收货地址',
    total_amount DECIMAL(15,2) NOT NULL DEFAULT 0 COMMENT '订单总金额',
    discount_amount DECIMAL(15,2) DEFAULT 0 COMMENT '折扣金额',
    payable_amount DECIMAL(15,2) NOT NULL DEFAULT 0 COMMENT '应付金额',
    paid_amount DECIMAL(15,2) DEFAULT 0 COMMENT '已付金额',
    cost_amount DECIMAL(15,2) DEFAULT 0 COMMENT '成本金额',
    profit_amount DECIMAL(15,2) DEFAULT 0 COMMENT '利润金额',
    order_date DATE NOT NULL COMMENT '订单日期',
    delivery_date DATE COMMENT '预计交货日期',
    approval_status TINYINT NOT NULL DEFAULT 1 COMMENT '审批状态:1=待审批,2=已通过,3=已驳回',
    order_status TINYINT NOT NULL DEFAULT 1 COMMENT '订单状态:1=待确认,2=已确认,3=已发货,4=已完成,5=已取消,6=已退货',
    pay_status TINYINT NOT NULL DEFAULT 1 COMMENT '支付状态:1=未支付,2=部分支付,3=已支付',
    shipping_status TINYINT NOT NULL DEFAULT 0 COMMENT '发货状态:0=未发货,1=已发货,2=部分发货',
    invoice_status TINYINT NOT NULL DEFAULT 0 COMMENT '开票状态:0=未开票,1=已开票',
    remark VARCHAR(512) COMMENT '备注',
    creator BIGINT UNSIGNED COMMENT '创建人',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
    PRIMARY KEY (id),
    UNIQUE KEY uk_tenant_order_no (tenant_id, order_no),
    KEY idx_customer_id (customer_id),
    KEY idx_order_status (order_status),
    KEY idx_channel (channel),
    KEY idx_order_date (order_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='销售订单表';

-- ============================================
-- 3. 销售订单明细表 (sales_order_detail)
-- ============================================
DROP TABLE IF EXISTS sales_order_detail;
CREATE TABLE sales_order_detail (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    tenant_id BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '租户ID',
    order_id BIGINT UNSIGNED NOT NULL COMMENT '订单ID',
    product_id BIGINT UNSIGNED NOT NULL COMMENT '商品ID',
    product_code VARCHAR(64) NOT NULL COMMENT '商品编码',
    product_name VARCHAR(255) NOT NULL COMMENT '商品名称',
    spec VARCHAR(128) COMMENT '规格',
    unit VARCHAR(32) COMMENT '单位',
    quantity INT NOT NULL DEFAULT 1 COMMENT '销售数量',
    shipped_quantity INT NOT NULL DEFAULT 0 COMMENT '已发货数量',
    unit_price DECIMAL(12,4) NOT NULL DEFAULT 0 COMMENT '单价',
    discount_rate DECIMAL(5,4) DEFAULT 1 COMMENT '折扣率',
    amount DECIMAL(15,2) NOT NULL DEFAULT 0 COMMENT '金额',
    cost_price DECIMAL(12,4) DEFAULT 0 COMMENT '成本价',
    tax_rate DECIMAL(5,4) DEFAULT 0 COMMENT '税率',
    tax_amount DECIMAL(12,2) DEFAULT 0 COMMENT '税额',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
    PRIMARY KEY (id),
    KEY idx_order_id (order_id),
    KEY idx_product_id (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='销售订单明细表';

-- ============================================
-- 4. 销售出库单表 (sales_delivery) - 待扩展
-- ============================================
DROP TABLE IF EXISTS sales_delivery;
CREATE TABLE sales_delivery (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    tenant_id BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '租户ID',
    delivery_no VARCHAR(64) NOT NULL COMMENT '出库单号',
    order_id BIGINT UNSIGNED COMMENT '关联销售订单ID',
    customer_id BIGINT UNSIGNED NOT NULL COMMENT '客户ID',
    warehouse_id BIGINT UNSIGNED NOT NULL COMMENT '仓库ID',
    total_quantity INT NOT NULL DEFAULT 0 COMMENT '总数量',
    total_amount DECIMAL(15,2) NOT NULL DEFAULT 0 COMMENT '总金额',
    delivery_date DATE NOT NULL COMMENT '出库日期',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '状态:1=待出库,2=已出库,3=已取消',
    remark VARCHAR(512) COMMENT '备注',
    creator BIGINT UNSIGNED COMMENT '创建人',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
    PRIMARY KEY (id),
    UNIQUE KEY uk_tenant_delivery_no (tenant_id, delivery_no),
    KEY idx_order_id (order_id),
    KEY idx_customer_id (customer_id),
    KEY idx_warehouse_id (warehouse_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='销售出库单表';

-- ============================================
-- 5. 初始化客户数据
-- ============================================
INSERT INTO customer (tenant_id, customer_code, customer_name, customer_type, customer_level, contact_name, contact_phone, address, credit_level, credit_amount, payment_days, status) VALUES
(1, 'CUST001', '深圳贸易有限公司', 1, 3, '孙七', '13800138201', '深圳市罗湖区', 4, 50000.00, 30, 1),
(1, 'CUST002', '张三(个人)', 2, 2, '张三', '13800138202', '深圳市宝安区', 3, 10000.00, 0, 1);

COMMIT;
