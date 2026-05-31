-- 商品服务数据库初始化脚本
-- 数据库：invoicing_product
-- 创建时间：2026-05-28

-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS invoicing_product DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE invoicing_product;

-- ============================================
-- 1. 商品分类表 (product_category)
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
-- 2. 商品基础表 (product_base)
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
-- 3. 供应商表 (supplier)
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
-- 4. 仓库表 (warehouse)
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
-- 5. 库位表 (warehouse_location)
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
-- 6. 初始化商品分类数据
-- ============================================
INSERT INTO product_category (tenant_id, category_code, category_name, parent_id, level, sort_order, status) VALUES
(1, 'ELECTRONICS', '电子产品', 0, 1, 1, 1),
(1, 'FOOD', '食品饮料', 0, 1, 2, 1),
(1, 'CLOTHING', '服装服饰', 0, 1, 3, 1),
(1, 'HOME', '家居用品', 0, 1, 4, 1),
(1, 'OFFICE', '办公用品', 0, 1, 5, 1);

-- ============================================
-- 7. 初始化仓库数据
-- ============================================
INSERT INTO warehouse (tenant_id, warehouse_code, warehouse_name, warehouse_type, province, city, district, address, manager, manager_phone, area, status) VALUES
(1, 'WH001', '主仓库', 1, '广东省', '深圳市', '南山区', '科技园路1号', '张三', '13800138001', 1000.00, 1),
(1, 'WH002', '副仓库', 1, '广东省', '东莞市', '长安镇', '工业路2号', '李四', '13800138002', 800.00, 1);

-- ============================================
-- 8. 初始化供应商数据
-- ============================================
INSERT INTO supplier (tenant_id, supplier_code, supplier_name, supplier_type, contact_name, contact_phone, address, credit_level, credit_amount, payment_days, status) VALUES
(1, 'SUP001', '深圳电子科技有限公司', 1, '王五', '13800138101', '深圳市福田区', 5, 100000.00, 30, 1),
(1, 'SUP002', '广州食品贸易公司', 2, '赵六', '13800138102', '广州市天河区', 4, 80000.00, 45, 1);

-- ============================================
-- 9. 初始化商品数据
-- ============================================
INSERT INTO product_base (tenant_id, product_code, product_name, bar_code, spec, unit, category_id, purchase_price, sale_price, min_price, max_price, brand, status) VALUES
(1, 'P001', '小米手机13', '6901234567890', '8GB+256GB', '台', 1, 2500.00, 2999.00, 2800.00, 3200.00, '小米', 1),
(1, 'P002', '华为平板M5', '6901234567891', '128GB', '台', 1, 1800.00, 2199.00, 2000.00, 2500.00, '华为', 1),
(1, 'P003', '可口可乐', '6901234567892', '330ml/罐', '箱', 2, 45.00, 60.00, 50.00, 70.00, '可口可乐', 1),
(1, 'P004', '农夫山泉', '6901234567893', '550ml/瓶', '箱', 2, 12.00, 18.00, 14.00, 22.00, '农夫山泉', 1),
(1, 'P005', 'A4复印纸', '6901234567894', '70g/500张', '箱', 5, 18.00, 25.00, 20.00, 30.00, '得力', 1);

COMMIT;
