# -*- coding: utf-8 -*-
import pymysql
import sys

DB_CONFIG = {
    'host': '192.168.1.6',
    'port': 13306,
    'user': 'root',
    'password': 'root',
    'charset': 'utf8mb4'
}

DATABASES = [
    'invoicing_auth',
    'invoicing_product',
    'invoicing_purchase',
    'invoicing_sales',
    'invoicing_inventory'
]

def create_databases():
    print("=" * 50)
    print("开始创建数据库...")
    print("=" * 50)

    conn = pymysql.connect(**DB_CONFIG)
    cursor = conn.cursor()

    for db_name in DATABASES:
        try:
            sql = "CREATE DATABASE IF NOT EXISTS %s DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
            cursor.execute(sql % db_name)
            print("[OK] 数据库 %s 创建成功" % db_name)
        except Exception as e:
            print("[FAIL] 数据库 %s 创建失败: %s" % (db_name, e))

    conn.commit()
    cursor.close()
    conn.close()
    print("=" * 50)
    print("数据库创建完成!")
    print("=" * 50)

def init_auth_db():
    print("\n初始化 invoicing_auth 数据库...")

    conn = pymysql.connect(host=DB_CONFIG['host'], port=DB_CONFIG['port'],
                          user=DB_CONFIG['user'], password=DB_CONFIG['password'],
                          charset=DB_CONFIG['charset'], database='invoicing_auth')
    cursor = conn.cursor()

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS sys_user (
        id BIGINT PRIMARY KEY AUTO_INCREMENT,
        username VARCHAR(50) NOT NULL UNIQUE,
        password VARCHAR(100) NOT NULL,
        real_name VARCHAR(50),
        email VARCHAR(100),
        phone VARCHAR(20),
        status TINYINT DEFAULT 1,
        create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """)

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS sys_role (
        id BIGINT PRIMARY KEY AUTO_INCREMENT,
        role_code VARCHAR(50) NOT NULL UNIQUE,
        role_name VARCHAR(50) NOT NULL,
        description VARCHAR(200),
        status TINYINT DEFAULT 1,
        create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """)

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS sys_user_role (
        id BIGINT PRIMARY KEY AUTO_INCREMENT,
        user_id BIGINT NOT NULL,
        role_id BIGINT NOT NULL,
        create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """)

    cursor.execute("DELETE FROM sys_user")
    cursor.execute("DELETE FROM sys_role")
    cursor.execute("DELETE FROM sys_user_role")

    cursor.execute("""
    INSERT INTO sys_user (username, password, real_name, email, phone, status)
    VALUES
        ('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt7bC4a', '系统管理员', 'admin@example.com', '13800138000', 1),
        ('user01', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt7bC4a', '张三', 'zhangsan@example.com', '13800138001', 1),
        ('user02', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt7bC4a', '李四', 'lisi@example.com', '13800138002', 1)
    """)

    cursor.execute("""
    INSERT INTO sys_role (role_code, role_name, description, status)
    VALUES
        ('ROLE_ADMIN', '系统管理员', '拥有系统所有权限', 1),
        ('ROLE_USER', '普通用户', '拥有普通用户权限', 1),
        ('ROLE_PURCHASE', '采购员', '拥有采购相关权限', 1),
        ('ROLE_SALES', '销售员', '拥有销售相关权限', 1),
        ('ROLE_WAREHOUSE', '仓库管理员', '拥有仓库管理权限', 1)
    """)

    cursor.execute("""
    INSERT INTO sys_user_role (user_id, role_id)
    VALUES (1, 1), (2, 2), (3, 3)
    """)

    conn.commit()
    cursor.close()
    conn.close()
    print("[OK] invoicing_auth 数据库初始化完成")

def init_product_db():
    print("\n初始化 invoicing_product 数据库...")

    conn = pymysql.connect(host=DB_CONFIG['host'], port=DB_CONFIG['port'],
                          user=DB_CONFIG['user'], password=DB_CONFIG['password'],
                          charset=DB_CONFIG['charset'], database='invoicing_product')
    cursor = conn.cursor()

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS product_base (
        id BIGINT PRIMARY KEY AUTO_INCREMENT,
        product_code VARCHAR(50) NOT NULL UNIQUE,
        product_name VARCHAR(100) NOT NULL,
        category_id BIGINT,
        unit VARCHAR(20),
        spec VARCHAR(100),
        purchase_price DECIMAL(10,2),
        sale_price DECIMAL(10,2),
        min_stock INT DEFAULT 0,
        max_stock INT DEFAULT 0,
        status TINYINT DEFAULT 1,
        create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """)

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS product_category (
        id BIGINT PRIMARY KEY AUTO_INCREMENT,
        category_code VARCHAR(50) NOT NULL UNIQUE,
        category_name VARCHAR(100) NOT NULL,
        parent_id BIGINT,
        sort_order INT DEFAULT 0,
        create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """)

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS supplier (
        id BIGINT PRIMARY KEY AUTO_INCREMENT,
        supplier_code VARCHAR(50) NOT NULL UNIQUE,
        supplier_name VARCHAR(100) NOT NULL,
        contact VARCHAR(50),
        phone VARCHAR(20),
        address VARCHAR(200),
        status TINYINT DEFAULT 1,
        create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """)

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS warehouse (
        id BIGINT PRIMARY KEY AUTO_INCREMENT,
        warehouse_code VARCHAR(50) NOT NULL UNIQUE,
        warehouse_name VARCHAR(100) NOT NULL,
        address VARCHAR(200),
        manager VARCHAR(50),
        status TINYINT DEFAULT 1,
        create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """)

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS warehouse_location (
        id BIGINT PRIMARY KEY AUTO_INCREMENT,
        warehouse_id BIGINT NOT NULL,
        location_code VARCHAR(50) NOT NULL,
        location_name VARCHAR(100),
        location_type VARCHAR(20),
        status TINYINT DEFAULT 1,
        create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """)

    cursor.execute("DELETE FROM product_base")
    cursor.execute("DELETE FROM product_category")
    cursor.execute("DELETE FROM supplier")
    cursor.execute("DELETE FROM warehouse")
    cursor.execute("DELETE FROM warehouse_location")

    cursor.execute("""
    INSERT INTO product_category (category_code, category_name, parent_id, sort_order)
    VALUES
        ('C001', '电子产品', NULL, 1),
        ('C002', '办公用品', NULL, 2),
        ('C003', '五金工具', NULL, 3),
        ('C004', '电脑配件', 1, 1),
        ('C005', '办公用纸', 2, 1)
    """)

    cursor.execute("""
    INSERT INTO supplier (supplier_code, supplier_name, contact, phone, address, status)
    VALUES
        ('S001', '深圳华强电子', '王经理', '13800138001', '深圳市福田区华强北路1号', 1),
        ('S002', '广州办公文具', '李经理', '13800138002', '广州市天河区中山大道1号', 1),
        ('S003', '上海五金工具', '张经理', '13800138003', '上海市浦东新区张江路1号', 1)
    """)

    cursor.execute("""
    INSERT INTO warehouse (warehouse_code, warehouse_name, address, manager, status)
    VALUES
        ('WH01', '深圳总仓', '深圳市宝安区石岩镇', '仓管员A', 1),
        ('WH02', '广州分仓', '广州市白云区江高镇', '仓管员B', 1)
    """)

    cursor.execute("""
    INSERT INTO warehouse_location (warehouse_id, location_code, location_name, location_type, status)
    VALUES
        (1, 'A01', 'A区01架', '货架', 1),
        (1, 'A02', 'A区02架', '货架', 1),
        (1, 'B01', 'B区01架', '货架', 1),
        (2, 'C01', 'C区01架', '货架', 1)
    """)

    cursor.execute("""
    INSERT INTO product_base (product_code, product_name, category_id, unit, spec, purchase_price, sale_price, min_stock, max_stock, status)
    VALUES
        ('P001', '联想ThinkPad笔记本', 4, '台', 'ThinkPad X1 Carbon', 8000.00, 9500.00, 5, 50, 1),
        ('P002', '戴尔显示器', 4, '台', 'DELL U2720Q 27寸', 2000.00, 2500.00, 10, 100, 1),
        ('P003', 'A4复印纸', 5, '箱', ' Double A 70g', 150.00, 200.00, 50, 500, 1),
        ('P004', '得力订书机', 2, '个', '得力3949', 15.00, 25.00, 20, 200, 1),
        ('P005', '螺丝刀套装', 3, '套', '世达05811', 80.00, 120.00, 10, 100, 1)
    """)

    conn.commit()
    cursor.close()
    conn.close()
    print("[OK] invoicing_product 数据库初始化完成")

def init_purchase_db():
    print("\n初始化 invoicing_purchase 数据库...")

    conn = pymysql.connect(host=DB_CONFIG['host'], port=DB_CONFIG['port'],
                          user=DB_CONFIG['user'], password=DB_CONFIG['password'],
                          charset=DB_CONFIG['charset'], database='invoicing_purchase')
    cursor = conn.cursor()

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS purchase_order (
        id BIGINT PRIMARY KEY AUTO_INCREMENT,
        order_no VARCHAR(50) NOT NULL UNIQUE,
        supplier_id BIGINT NOT NULL,
        total_amount DECIMAL(12,2) DEFAULT 0,
        order_status VARCHAR(20) DEFAULT 'DRAFT',
        order_date DATE,
        expected_date DATE,
        remark VARCHAR(500),
        creater VARCHAR(50),
        create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """)

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS purchase_order_detail (
        id BIGINT PRIMARY KEY AUTO_INCREMENT,
        order_id BIGINT NOT NULL,
        product_id BIGINT NOT NULL,
        product_code VARCHAR(50),
        product_name VARCHAR(100),
        unit VARCHAR(20),
        spec VARCHAR(100),
        quantity DECIMAL(10,2) NOT NULL,
        unit_price DECIMAL(10,2) NOT NULL,
        amount DECIMAL(12,2) NOT NULL,
        receipt_quantity DECIMAL(10,2) DEFAULT 0
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """)

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS purchase_receipt (
        id BIGINT PRIMARY KEY AUTO_INCREMENT,
        receipt_no VARCHAR(50) NOT NULL UNIQUE,
        order_id BIGINT,
        supplier_id BIGINT NOT NULL,
        total_amount DECIMAL(12,2) DEFAULT 0,
        receipt_status VARCHAR(20) DEFAULT 'CONFIRMED',
        receipt_date DATE,
        warehouse_id BIGINT,
        remark VARCHAR(500),
        creater VARCHAR(50),
        create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """)

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS purchase_receipt_detail (
        id BIGINT PRIMARY KEY AUTO_INCREMENT,
        receipt_id BIGINT NOT NULL,
        product_id BIGINT NOT NULL,
        product_code VARCHAR(50),
        product_name VARCHAR(100),
        unit VARCHAR(20),
        quantity DECIMAL(10,2) NOT NULL,
        unit_price DECIMAL(10,2) NOT NULL,
        amount DECIMAL(12,2) NOT NULL,
        warehouse_id BIGINT,
        location_id BIGINT
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """)

    cursor.execute("DELETE FROM purchase_order")
    cursor.execute("DELETE FROM purchase_order_detail")
    cursor.execute("DELETE FROM purchase_receipt")
    cursor.execute("DELETE FROM purchase_receipt_detail")

    cursor.execute("""
    INSERT INTO purchase_order (order_no, supplier_id, total_amount, order_status, order_date, expected_date, remark, creater)
    VALUES
        ('PO20260101001', 1, 16000.00, 'APPROVED', '2026-01-15', '2026-01-25', '笔记本采购', 'admin'),
        ('PO20260101002', 2, 1000.00, 'DRAFT', '2026-01-20', '2026-01-30', '办公用品采购', 'admin')
    """)

    cursor.execute("""
    INSERT INTO purchase_order_detail (order_id, product_id, product_code, product_name, unit, spec, quantity, unit_price, amount, receipt_quantity)
    VALUES
        (1, 1, 'P001', '联想ThinkPad笔记本', '台', 'ThinkPad X1 Carbon', 2, 8000.00, 16000.00, 0),
        (2, 3, 'P003', 'A4复印纸', '箱', 'Double A 70g', 5, 150.00, 750.00, 0),
        (2, 4, 'P004', '得力订书机', '个', '得力3949', 10, 15.00, 150.00, 0)
    """)

    conn.commit()
    cursor.close()
    conn.close()
    print("[OK] invoicing_purchase 数据库初始化完成")

def init_sales_db():
    print("\n初始化 invoicing_sales 数据库...")

    conn = pymysql.connect(host=DB_CONFIG['host'], port=DB_CONFIG['port'],
                          user=DB_CONFIG['user'], password=DB_CONFIG['password'],
                          charset=DB_CONFIG['charset'], database='invoicing_sales')
    cursor = conn.cursor()

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS customer (
        id BIGINT PRIMARY KEY AUTO_INCREMENT,
        customer_code VARCHAR(50) NOT NULL UNIQUE,
        customer_name VARCHAR(100) NOT NULL,
        contact VARCHAR(50),
        phone VARCHAR(20),
        address VARCHAR(200),
        customer_type VARCHAR(20),
        status TINYINT DEFAULT 1,
        create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """)

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS sales_order (
        id BIGINT PRIMARY KEY AUTO_INCREMENT,
        order_no VARCHAR(50) NOT NULL UNIQUE,
        customer_id BIGINT NOT NULL,
        total_amount DECIMAL(12,2) DEFAULT 0,
        order_status VARCHAR(20) DEFAULT 'DRAFT',
        order_date DATE,
        expected_date DATE,
        remark VARCHAR(500),
        creater VARCHAR(50),
        create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """)

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS sales_order_detail (
        id BIGINT PRIMARY KEY AUTO_INCREMENT,
        order_id BIGINT NOT NULL,
        product_id BIGINT NOT NULL,
        product_code VARCHAR(50),
        product_name VARCHAR(100),
        unit VARCHAR(20),
        quantity DECIMAL(10,2) NOT NULL,
        unit_price DECIMAL(10,2) NOT NULL,
        amount DECIMAL(12,2) NOT NULL,
        delivery_quantity DECIMAL(10,2) DEFAULT 0
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """)

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS sales_delivery (
        id BIGINT PRIMARY KEY AUTO_INCREMENT,
        delivery_no VARCHAR(50) NOT NULL UNIQUE,
        order_id BIGINT,
        customer_id BIGINT NOT NULL,
        total_amount DECIMAL(12,2) DEFAULT 0,
        delivery_status VARCHAR(20) DEFAULT 'CONFIRMED',
        delivery_date DATE,
        warehouse_id BIGINT,
        remark VARCHAR(500),
        creater VARCHAR(50),
        create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """)

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS sales_delivery_detail (
        id BIGINT PRIMARY KEY AUTO_INCREMENT,
        delivery_id BIGINT NOT NULL,
        product_id BIGINT NOT NULL,
        product_code VARCHAR(50),
        product_name VARCHAR(100),
        unit VARCHAR(20),
        quantity DECIMAL(10,2) NOT NULL,
        unit_price DECIMAL(10,2) NOT NULL,
        amount DECIMAL(12,2) NOT NULL,
        warehouse_id BIGINT,
        location_id BIGINT
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """)

    cursor.execute("DELETE FROM customer")
    cursor.execute("DELETE FROM sales_order")
    cursor.execute("DELETE FROM sales_order_detail")
    cursor.execute("DELETE FROM sales_delivery")
    cursor.execute("DELETE FROM sales_delivery_detail")

    cursor.execute("""
    INSERT INTO customer (customer_code, customer_name, contact, phone, address, customer_type, status)
    VALUES
        ('C001', '深圳腾讯科技', '采购部', '13800138011', '深圳市南山区科技园', 'VIP', 1),
        ('C002', '广州网易', '采购部', '13800138012', '广州市天河区珠江新城', 'VIP', 1),
        ('C003', '中小企业客户', '王总', '13800138013', '深圳市福田区', 'NORMAL', 1)
    """)

    cursor.execute("""
    INSERT INTO sales_order (order_no, customer_id, total_amount, order_status, order_date, expected_date, remark, creater)
    VALUES
        ('SO20260101001', 1, 19000.00, 'APPROVED', '2026-01-18', '2026-01-28', '笔记本和显示器销售', 'admin')
    """)

    cursor.execute("""
    INSERT INTO sales_order_detail (order_id, product_id, product_code, product_name, unit, quantity, unit_price, amount, delivery_quantity)
    VALUES
        (1, 1, 'P001', '联想ThinkPad笔记本', '台', 2, 9500.00, 19000.00, 0)
    """)

    conn.commit()
    cursor.close()
    conn.close()
    print("[OK] invoicing_sales 数据库初始化完成")

def init_inventory_db():
    print("\n初始化 invoicing_inventory 数据库...")

    conn = pymysql.connect(host=DB_CONFIG['host'], port=DB_CONFIG['port'],
                          user=DB_CONFIG['user'], password=DB_CONFIG['password'],
                          charset=DB_CONFIG['charset'], database='invoicing_inventory')
    cursor = conn.cursor()

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS batch (
        id BIGINT PRIMARY KEY AUTO_INCREMENT,
        batch_no VARCHAR(50) NOT NULL UNIQUE,
        product_id BIGINT NOT NULL,
        warehouse_id BIGINT NOT NULL,
        location_id BIGINT,
        quantity DECIMAL(10,2) DEFAULT 0,
        available_quantity DECIMAL(10,2) DEFAULT 0,
        frozen_quantity DECIMAL(10,2) DEFAULT 0,
        unit_cost DECIMAL(10,2),
        manufacture_date DATE,
        expire_date DATE,
        status TINYINT DEFAULT 1,
        create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """)

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS inventory_ledger (
        id BIGINT PRIMARY KEY AUTO_INCREMENT,
        product_id BIGINT NOT NULL,
        warehouse_id BIGINT NOT NULL,
        location_id BIGINT,
        batch_id BIGINT,
        business_type VARCHAR(20) NOT NULL,
        business_no VARCHAR(50),
        in_quantity DECIMAL(10,2) DEFAULT 0,
        out_quantity DECIMAL(10,2) DEFAULT 0,
        before_quantity DECIMAL(10,2) DEFAULT 0,
        after_quantity DECIMAL(10,2) DEFAULT 0,
        unit_cost DECIMAL(10,2),
        amount DECIMAL(12,2),
        creater VARCHAR(50),
        create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """)

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS inventory_summary (
        id BIGINT PRIMARY KEY AUTO_INCREMENT,
        product_id BIGINT NOT NULL,
        warehouse_id BIGINT NOT NULL,
        location_id BIGINT,
        total_quantity DECIMAL(10,2) DEFAULT 0,
        available_quantity DECIMAL(10,2) DEFAULT 0,
        frozen_quantity DECIMAL(10,2) DEFAULT 0,
        update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """)

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS inventory_flow (
        id BIGINT PRIMARY KEY AUTO_INCREMENT,
        product_id BIGINT NOT NULL,
        warehouse_id BIGINT NOT NULL,
        flow_type VARCHAR(20) NOT NULL,
        flow_no VARCHAR(50),
        quantity DECIMAL(10,2),
        before_quantity DECIMAL(10,2),
        after_quantity DECIMAL(10,2),
        remark VARCHAR(500),
        creater VARCHAR(50),
        create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """)

    cursor.execute("DELETE FROM batch")
    cursor.execute("DELETE FROM inventory_ledger")
    cursor.execute("DELETE FROM inventory_summary")
    cursor.execute("DELETE FROM inventory_flow")

    cursor.execute("""
    INSERT INTO batch (batch_no, product_id, warehouse_id, location_id, quantity, available_quantity, frozen_quantity, unit_cost, manufacture_date, expire_date, status)
    VALUES
        ('BATCH20260115001', 1, 1, 1, 10, 10, 0, 8000.00, '2026-01-10', '2028-01-10', 1),
        ('BATCH20260115002', 3, 1, 2, 100, 100, 0, 150.00, '2026-01-01', '2028-01-01', 1)
    """)

    cursor.execute("""
    INSERT INTO inventory_summary (product_id, warehouse_id, location_id, total_quantity, available_quantity, frozen_quantity)
    VALUES
        (1, 1, 1, 10, 10, 0),
        (3, 1, 2, 100, 100, 0)
    """)

    conn.commit()
    cursor.close()
    conn.close()
    print("[OK] invoicing_inventory 数据库初始化完成")

def main():
    print("\n" + "=" * 50)
    print("进销存系统数据库初始化脚本")
    print("=" * 50)

    create_databases()

    try:
        init_auth_db()
        init_product_db()
        init_purchase_db()
        init_sales_db()
        init_inventory_db()
    except Exception as e:
        print("\n[ERROR] 初始化数据库时出错: %s" % e)
        sys.exit(1)

    print("\n" + "=" * 50)
    print("所有数据库初始化完成!")
    print("=" * 50)

if __name__ == '__main__':
    main()
