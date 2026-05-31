-- 商用进销存系统数据库初始化脚本
-- 数据库：invoicing
-- 创建时间：2026-05-28

-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS invoicing DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE invoicing;

-- ============================================
-- 1. 系统用户表 (sys_user)
-- ============================================
DROP TABLE IF EXISTS sys_user;
CREATE TABLE sys_user (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    tenant_id BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '租户ID',
    username VARCHAR(64) NOT NULL COMMENT '用户名',
    password VARCHAR(255) NOT NULL COMMENT '密码',
    nickname VARCHAR(64) COMMENT '昵称',
    email VARCHAR(128) COMMENT '邮箱',
    phone VARCHAR(32) COMMENT '手机号',
    avatar VARCHAR(512) COMMENT '头像URL',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '状态:0=禁用,1=启用',
    last_login_time DATETIME COMMENT '最后登录时间',
    last_login_ip VARCHAR(64) COMMENT '最后登录IP',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
    PRIMARY KEY (id),
    UNIQUE KEY uk_username (username),
    KEY idx_tenant_id (tenant_id),
    KEY idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统用户表';

-- ============================================
-- 2. 商品分类表 (product_category)
-- ============================================
DROP TABLE IF EXISTS product_category;
CREATE TABLE product_category (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    tenant_id BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '租户ID',
    category_code VARCHAR(64) NOT NULL COMMENT '分类编码',
    category_name VARCHAR(128) NOT NULL COMMENT '分类名称',
    parent_id BIGINT UNSIGNED DEFAULT 0 COMMENT '父分类ID',
    level INT NOT NULL DEFAULT 1 COMMENT '分类层级',
    sort_order INT NOT NULL DEFAULT 0 COMMENT '排序号',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '状态:0=禁用,1=启用',
    description VARCHAR(512) COMMENT '备注',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
    PRIMARY KEY (id),
    UNIQUE KEY uk_tenant_category_code (tenant_id, category_code),
    KEY idx_parent_id (parent_id),
    KEY idx_level (level)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品分类表';

-- ============================================
-- 3. 商品基础表 (product_base)
-- ============================================
DROP TABLE IF EXISTS product_base;
CREATE TABLE product_base (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    tenant_id BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '租户ID',
    product_code VARCHAR(64) NOT NULL COMMENT '商品编码',
    product_name VARCHAR(255) NOT NULL COMMENT '商品名称',
    bar_code VARCHAR(64) COMMENT '条形码',
    spec VARCHAR(128) COMMENT '规格',
    unit VARCHAR(32) DEFAULT '件' COMMENT '单位',
    category_id BIGINT UNSIGNED COMMENT '商品分类ID',
    purchase_price DECIMAL(12,4) DEFAULT 0 COMMENT '采购价',
    sale_price DECIMAL(12,4) DEFAULT 0 COMMENT '销售价',
    min_price DECIMAL(12,4) COMMENT '最低售价',
    max_price DECIMAL(12,4) COMMENT '最高售价',
    brand VARCHAR(128) COMMENT '品牌',
    origin VARCHAR(128) COMMENT '产地',
    stock_quantity INT NOT NULL DEFAULT 0 COMMENT '库存数量',
    min_stock INT DEFAULT 10 COMMENT '最小库存',
    max_stock INT DEFAULT 1000 COMMENT '最大库存',
    description TEXT COMMENT '商品描述',
    image_url VARCHAR(512) COMMENT '商品图片',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '状态:0=禁用,1=启用',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
    PRIMARY KEY (id),
    UNIQUE KEY uk_tenant_product_code (tenant_id, product_code),
    KEY idx_category_id (category_id),
    KEY idx_product_name (product_name),
    KEY idx_bar_code (bar_code),
    KEY idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品基础表';

-- ============================================
-- 4. 供应商表 (supplier)
-- ============================================
DROP TABLE IF EXISTS supplier;
CREATE TABLE supplier (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    tenant_id BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '租户ID',
    supplier_code VARCHAR(64) NOT NULL COMMENT '供应商编码',
    supplier_name VARCHAR(255) NOT NULL COMMENT '供应商名称',
    supplier_type TINYINT NOT NULL DEFAULT 1 COMMENT '供应商类型:1=生产型,2=贸易型,3=个人',
    contact_name VARCHAR(64) COMMENT '联系人',
    contact_phone VARCHAR(32) COMMENT '联系电话',
    contact_email VARCHAR(128) COMMENT '联系邮箱',
    address VARCHAR(512) COMMENT '地址',
    credit_level TINYINT COMMENT '信用等级:1-5',
    credit_amount DECIMAL(15,2) DEFAULT 0 COMMENT '信用额度',
    payment_days INT DEFAULT 0 COMMENT '账期(天)',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '状态:0=禁用,1=启用',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
    PRIMARY KEY (id),
    UNIQUE KEY uk_tenant_supplier_code (tenant_id, supplier_code),
    KEY idx_supplier_name (supplier_name),
    KEY idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='供应商表';

-- ============================================
-- 5. 客户表 (customer)
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
-- 6. 仓库表 (warehouse)
-- ============================================
DROP TABLE IF EXISTS warehouse;
CREATE TABLE warehouse (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    tenant_id BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '租户ID',
    warehouse_code VARCHAR(64) NOT NULL COMMENT '仓库编码',
    warehouse_name VARCHAR(128) NOT NULL COMMENT '仓库名称',
    warehouse_type TINYINT NOT NULL DEFAULT 1 COMMENT '仓库类型:1=自有,2=租赁,3=虚拟',
    province VARCHAR(64) COMMENT '省份',
    city VARCHAR(64) COMMENT '城市',
    district VARCHAR(64) COMMENT '区县',
    address VARCHAR(512) COMMENT '详细地址',
    manager VARCHAR(64) COMMENT '负责人',
    manager_phone VARCHAR(32) COMMENT '联系电话',
    area DECIMAL(10,2) COMMENT '面积(平方米)',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '状态:0=禁用,1=启用',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
    PRIMARY KEY (id),
    UNIQUE KEY uk_tenant_warehouse_code (tenant_id, warehouse_code),
    KEY idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='仓库表';

-- ============================================
-- 7. 库位表 (warehouse_location)
-- ============================================
DROP TABLE IF EXISTS warehouse_location;
CREATE TABLE warehouse_location (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    tenant_id BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '租户ID',
    warehouse_id BIGINT UNSIGNED NOT NULL COMMENT '仓库ID',
    location_code VARCHAR(64) NOT NULL COMMENT '库位编码',
    location_name VARCHAR(128) NOT NULL COMMENT '库位名称',
    location_type TINYINT NOT NULL DEFAULT 1 COMMENT '库位类型:1=货架,2=地面,3=临时',
    zone VARCHAR(64) COMMENT '库区',
    aisle VARCHAR(32) COMMENT '通道',
    shelf VARCHAR(32) COMMENT '货架号',
    layer INT COMMENT '层级',
    position INT COMMENT '位置',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '状态:0=禁用,1=启用',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
    PRIMARY KEY (id),
    UNIQUE KEY uk_tenant_location_code (tenant_id, warehouse_id, location_code),
    KEY idx_warehouse_id (warehouse_id),
    KEY idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='库位表';

-- ============================================
-- 8. 库存表 (inventory)
-- ============================================
DROP TABLE IF EXISTS inventory;
CREATE TABLE inventory (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    tenant_id BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '租户ID',
    warehouse_id BIGINT UNSIGNED NOT NULL COMMENT '仓库ID',
    location_id BIGINT UNSIGNED COMMENT '库位ID',
    product_id BIGINT UNSIGNED NOT NULL COMMENT '商品ID',
    product_code VARCHAR(64) NOT NULL COMMENT '商品编码',
    product_name VARCHAR(255) NOT NULL COMMENT '商品名称',
    batch_no VARCHAR(64) COMMENT '批次号',
    quantity INT NOT NULL DEFAULT 0 COMMENT '库存数量',
    available_quantity INT NOT NULL DEFAULT 0 COMMENT '可用数量',
    locked_quantity INT NOT NULL DEFAULT 0 COMMENT '锁定数量',
    cost_price DECIMAL(12,4) DEFAULT 0 COMMENT '成本价',
    production_date DATE COMMENT '生产日期',
    expiry_date DATE COMMENT '有效期',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
    PRIMARY KEY (id),
    UNIQUE KEY uk_tenant_product_batch (tenant_id, warehouse_id, location_id, product_id, batch_no),
    KEY idx_warehouse_id (warehouse_id),
    KEY idx_product_id (product_id),
    KEY idx_batch_no (batch_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='库存表';

-- ============================================
-- 9. 采购订单表 (purchase_order)
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
-- 10. 采购订单明细表 (purchase_order_detail)
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
-- 11. 销售订单表 (sales_order)
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
-- 12. 销售订单明细表 (sales_order_detail)
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
-- 13. 库存流水表 (inventory_flow)
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
    batch_no VARCHAR(64) COMMENT '批次号',
    quantity_before INT NOT NULL DEFAULT 0 COMMENT '变动前数量',
    quantity_change INT NOT NULL COMMENT '变动数量(正=入库,负=出库)',
    quantity_after INT NOT NULL DEFAULT 0 COMMENT '变动后数量',
    cost_price DECIMAL(12,4) COMMENT '成本价',
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

-- ============================================
-- 14. 初始化测试用户数据
-- ============================================
INSERT INTO sys_user (tenant_id, username, password, nickname, email, phone, status) VALUES
(1, 'admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5E2', '系统管理员', 'admin@invoicing.com', '13800138000', 1),
(1, 'test', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5E2', '测试用户', 'test@invoicing.com', '13900139000', 1);

-- 密码说明: $2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5E2 是 "123456" 的BCrypt加密

-- ============================================
-- 15. 初始化商品分类数据
-- ============================================
INSERT INTO product_category (tenant_id, category_code, category_name, parent_id, level, sort_order, status) VALUES
(1, 'ELECTRONICS', '电子产品', 0, 1, 1, 1),
(1, 'FOOD', '食品饮料', 0, 1, 2, 1),
(1, 'CLOTHING', '服装服饰', 0, 1, 3, 1),
(1, 'HOME', '家居用品', 0, 1, 4, 1),
(1, 'OFFICE', '办公用品', 0, 1, 5, 1);

-- ============================================
-- 16. 初始化仓库数据
-- ============================================
INSERT INTO warehouse (tenant_id, warehouse_code, warehouse_name, warehouse_type, province, city, district, address, manager, manager_phone, area, status) VALUES
(1, 'WH001', '主仓库', 1, '广东省', '深圳市', '南山区', '科技园路1号', '张三', '13800138001', 1000.00, 1),
(1, 'WH002', '副仓库', 1, '广东省', '东莞市', '长安镇', '工业路2号', '李四', '13800138002', 800.00, 1);

-- ============================================
-- 17. 初始化供应商数据
-- ============================================
INSERT INTO supplier (tenant_id, supplier_code, supplier_name, supplier_type, contact_name, contact_phone, address, credit_level, credit_amount, payment_days, status) VALUES
(1, 'SUP001', '深圳电子科技有限公司', 1, '王五', '13800138101', '深圳市福田区', 5, 100000.00, 30, 1),
(1, 'SUP002', '广州食品贸易公司', 2, '赵六', '13800138102', '广州市天河区', 4, 80000.00, 45, 1);

-- ============================================
-- 18. 初始化客户数据
-- ============================================
INSERT INTO customer (tenant_id, customer_code, customer_name, customer_type, customer_level, contact_name, contact_phone, address, credit_level, credit_amount, payment_days, status) VALUES
(1, 'CUST001', '深圳贸易有限公司', 1, 3, '孙七', '13800138201', '深圳市罗湖区', 4, 50000.00, 30, 1),
(1, 'CUST002', '张三(个人)', 2, 2, '张三', '13800138202', '深圳市宝安区', 3, 10000.00, 0, 1);

-- ============================================
-- 19. 初始化商品数据
-- ============================================
INSERT INTO product_base (tenant_id, product_code, product_name, bar_code, spec, unit, category_id, purchase_price, sale_price, min_price, max_price, brand, stock_quantity, min_stock, max_stock, status) VALUES
(1, 'P001', '小米手机13', '6901234567890', '8GB+256GB', '台', 1, 2500.00, 2999.00, 2800.00, 3200.00, '小米', 100, 20, 500, 1),
(1, 'P002', '华为平板M5', '6901234567891', '128GB', '台', 1, 1800.00, 2199.00, 2000.00, 2500.00, '华为', 80, 15, 300, 1),
(1, 'P003', '可口可乐', '6901234567892', '330ml/罐', '箱', 2, 45.00, 60.00, 50.00, 70.00, '可口可乐', 500, 100, 2000, 1),
(1, 'P004', '农夫山泉', '6901234567893', '550ml/瓶', '箱', 2, 12.00, 18.00, 14.00, 22.00, '农夫山泉', 1000, 200, 5000, 1),
(1, 'P005', 'A4复印纸', '6901234567894', '70g/500张', '箱', 5, 18.00, 25.00, 20.00, 30.00, '得力', 200, 50, 1000, 1);

COMMIT;
