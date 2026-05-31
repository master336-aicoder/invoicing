const http = require('http');

const users = {
    'admin': { id: 1, username: 'admin', password: 'admin123', nickname: '系统管理员', email: 'admin@test.com', phone: '13800138000', role: 'admin', roles: ['admin'], tenantId: 1 },
    'user': { id: 2, username: 'user', password: 'user123', nickname: '普通用户', email: 'user@test.com', phone: '13900139000', role: 'user', roles: ['user'], tenantId: 1 }
};

const categories = [
    { id: 1, code: 'C001', name: '手机通讯', parentId: 0, level: 1, sortOrder: 1, status: 1 },
    { id: 2, code: 'C002', name: '电脑办公', parentId: 0, level: 1, sortOrder: 2, status: 1 },
    { id: 3, code: 'C003', name: '数码配件', parentId: 0, level: 1, sortOrder: 3, status: 1 },
    { id: 4, code: 'C004', name: '智能设备', parentId: 0, level: 1, sortOrder: 4, status: 1 },
    { id: 5, code: 'C005', name: '影音娱乐', parentId: 0, level: 1, sortOrder: 5, status: 1 },
    { id: 6, code: 'C00101', name: '智能手机', parentId: 1, level: 2, sortOrder: 1, status: 1 },
    { id: 7, code: 'C00102', name: '功能机', parentId: 1, level: 2, sortOrder: 2, status: 1 },
    { id: 8, code: 'C00201', name: '笔记本电脑', parentId: 2, level: 2, sortOrder: 1, status: 1 },
    { id: 9, code: 'C00202', name: '台式机', parentId: 2, level: 2, sortOrder: 2, status: 1 },
    { id: 10, code: 'C00301', name: '耳机音箱', parentId: 3, level: 2, sortOrder: 1, status: 1 },
    { id: 11, code: 'C00302', name: '充电器线材', parentId: 3, level: 2, sortOrder: 2, status: 1 }
];

const products = [
    {
        id: 1,
        code: 'P001',
        name: 'iPhone 15 Pro',
        categoryId: 6,
        categoryCode: 'C00101',
        categoryName: '智能手机',
        supplierId: 1,
        supplierName: '苹果供应商A',
        unit: '台',
        status: 1,
        image: 'https://img-cdn.xiaohongshu.com/98af431f-2475-4b98-922b-2e84d3bd4d41!540!540!0!2!0!0!0',
        description: '<div class="product-detail"><h2>商品详情</h2><p>iPhone 15 Pro 采用钛金属设计，配备A17 Pro芯片，性能强劲。</p><ul><li>芯片：A17 Pro</li><li>内存：8GB</li><li>存储：256GB/512GB/1TB</li><li>屏幕：6.1英寸Super Retina XDR</li></ul></div>',
        remark: '',
        createTime: '2024-01-15T10:00:00Z',
        updateTime: '2024-01-15T10:00:00Z'
    },
    {
        id: 2,
        code: 'P002',
        name: 'MacBook Pro 14寸',
        categoryId: 8,
        categoryCode: 'C00201',
        categoryName: '笔记本电脑',
        supplierId: 1,
        supplierName: '苹果供应商A',
        unit: '台',
        status: 1,
        image: 'https://img-cdn.xiaohongshu.com/f999120a-853d-4b99-9b71-cd460944d58b!540!540!0!2!0!0!0',
        description: '<div class="product-detail"><h2>MacBook Pro 14寸</h2><p>搭载M3 Pro芯片，配备 Liquid Retina XDR 显示屏。</p><ul><li>芯片：M3 Pro</li><li>内存：18GB/36GB</li><li>存储：512GB/1TB/2TB</li><li>屏幕：14.2英寸Liquid Retina XDR</li></ul></div>',
        remark: '',
        createTime: '2024-01-10T10:00:00Z',
        updateTime: '2024-01-10T10:00:00Z'
    },
    {
        id: 3,
        code: 'P003',
        name: 'AirPods Pro 2',
        categoryId: 10,
        categoryCode: 'C00301',
        categoryName: '耳机音箱',
        supplierId: 2,
        supplierName: '苹果供应商B',
        unit: '个',
        status: 1,
        image: 'https://img-cdn.xiaohongshu.com/2299fa5e-6f17-43a5-a812-0113d069897d!540!540!0!2!0!0!0',
        description: '<div class="product-detail"><h2>AirPods Pro 2</h2><p>全新升级的主动降噪功能，自适应音频，个性化空间音频。</p></div>',
        remark: '',
        createTime: '2024-01-08T10:00:00Z',
        updateTime: '2024-01-08T10:00:00Z'
    },
    {
        id: 4,
        code: 'P004',
        name: 'iPad Air 5',
        categoryId: 8,
        categoryCode: 'C00201',
        categoryName: '笔记本电脑',
        supplierId: 2,
        supplierName: '苹果供应商B',
        unit: '台',
        status: 1,
        image: 'https://img-cdn.xiaohongshu.com/9bc57235-8e3f-423b-a791-3afdd6a54226!540!540!0!2!0!0!0',
        description: '<div class="product-detail"><h2>iPad Air 5</h2><p>M1芯片，10.9英寸Liquid Retina显示屏，支持Apple Pencil。</p></div>',
        remark: '',
        createTime: '2024-01-05T10:00:00Z',
        updateTime: '2024-01-05T10:00:00Z'
    },
    {
        id: 5,
        code: 'P005',
        name: 'Apple Watch Series 9',
        categoryId: 4,
        categoryCode: 'C004',
        categoryName: '智能设备',
        supplierId: 3,
        supplierName: '华为供应商',
        unit: '个',
        status: 1,
        image: 'https://img-cdn.xiaohongshu.com/91be62a8-940b-4b16-adbd-e8f098430161!540!540!0!2!0!0!0',
        description: '<div class="product-detail"><h2>Apple Watch Series 9</h2><p>S9 SiP芯片，全天候视网膜显示屏，体温感应。</p></div>',
        remark: '',
        createTime: '2024-01-03T10:00:00Z',
        updateTime: '2024-01-03T10:00:00Z'
    }
];

const productSkus = [
    { id: 1, productId: 1, skuCode: 'SKU-P001-001', skuName: '深空黑-256GB', attributeValues: [{ dimensionName: '颜色', value: '深空黑' }, { dimensionName: '存储', value: '256GB' }], costPrice: 6000.00, salePrice: 7999.00, stock: 50, minStock: 10, status: 1, barCode: '6901234567890', weight: 0.187, volume: 0.00015, createTime: '2024-01-15T10:00:00Z', updateTime: '2024-01-15T10:00:00Z' },
    { id: 2, productId: 1, skuCode: 'SKU-P001-002', skuName: '银色-256GB', attributeValues: [{ dimensionName: '颜色', value: '银色' }, { dimensionName: '存储', value: '256GB' }], costPrice: 6000.00, salePrice: 7999.00, stock: 30, minStock: 10, status: 1, barCode: '6901234567891', weight: 0.187, volume: 0.00015, createTime: '2024-01-15T10:00:00Z', updateTime: '2024-01-15T10:00:00Z' },
    { id: 3, productId: 1, skuCode: 'SKU-P001-003', skuName: '深空黑-512GB', attributeValues: [{ dimensionName: '颜色', value: '深空黑' }, { dimensionName: '存储', value: '512GB' }], costPrice: 7000.00, salePrice: 8999.00, stock: 20, minStock: 5, status: 1, barCode: '6901234567892', weight: 0.187, volume: 0.00015, createTime: '2024-01-15T10:00:00Z', updateTime: '2024-01-15T10:00:00Z' },
    { id: 4, productId: 2, skuCode: 'SKU-P002-001', skuName: 'M3 Pro-18GB-512GB', attributeValues: [{ dimensionName: '芯片', value: 'M3 Pro' }, { dimensionName: '内存', value: '18GB' }, { dimensionName: '存储', value: '512GB' }], costPrice: 10000.00, salePrice: 12999.00, stock: 25, minStock: 5, status: 1, barCode: '6902234567890', weight: 1.55, volume: 0.0005, createTime: '2024-01-10T10:00:00Z', updateTime: '2024-01-10T10:00:00Z' },
    { id: 5, productId: 2, skuCode: 'SKU-P002-002', skuName: 'M3 Pro-36GB-1TB', attributeValues: [{ dimensionName: '芯片', value: 'M3 Pro' }, { dimensionName: '内存', value: '36GB' }, { dimensionName: '存储', value: '1TB' }], costPrice: 13000.00, salePrice: 16999.00, stock: 15, minStock: 3, status: 1, barCode: '6902234567891', weight: 1.55, volume: 0.0005, createTime: '2024-01-10T10:00:00Z', updateTime: '2024-01-10T10:00:00Z' },
    { id: 6, productId: 3, skuCode: 'SKU-P003-001', skuName: '白色', attributeValues: [{ dimensionName: '颜色', value: '白色' }], costPrice: 1500.00, salePrice: 1999.00, stock: 100, minStock: 20, status: 1, barCode: '6903234567890', weight: 0.051, volume: 0.00005, createTime: '2024-01-08T10:00:00Z', updateTime: '2024-01-08T10:00:00Z' },
    { id: 7, productId: 3, skuCode: 'SKU-P003-002', skuName: '黑色', attributeValues: [{ dimensionName: '颜色', value: '黑色' }], costPrice: 1500.00, salePrice: 1999.00, stock: 100, minStock: 20, status: 1, barCode: '6903234567891', weight: 0.051, volume: 0.00005, createTime: '2024-01-08T10:00:00Z', updateTime: '2024-01-08T10:00:00Z' }
];

const skuDimensions = [
    { id: 1, productId: 1, name: '颜色', values: ['深空黑', '银色', '金色'] },
    { id: 2, productId: 1, name: '存储', values: ['128GB', '256GB', '512GB', '1TB'] },
    { id: 3, productId: 2, name: '芯片', values: ['M3 Pro', 'M3 Max'] },
    { id: 4, productId: 2, name: '内存', values: ['18GB', '36GB'] },
    { id: 5, productId: 2, name: '存储', values: ['512GB', '1TB', '2TB'] },
    { id: 6, productId: 3, name: '颜色', values: ['白色', '黑色'] }
];

const suppliers = [
    { id: 1, code: 'S001', name: '苹果供应商A', contactPerson: '张经理', contactPhone: '13800138001', email: 'supplier_a@apple.com', address: '深圳市南山区科技园A座', status: 1, remark: '主要供应商', createTime: '2024-01-01T00:00:00Z', updateTime: '2024-01-01T00:00:00Z' },
    { id: 2, code: 'S002', name: '苹果供应商B', contactPerson: '李经理', contactPhone: '13800138002', email: 'supplier_b@apple.com', address: '广州市天河区软件园B栋', status: 1, remark: '次要供应商', createTime: '2024-01-02T00:00:00Z', updateTime: '2024-01-02T00:00:00Z' },
    { id: 3, code: 'S003', name: '华为供应商', contactPerson: '王经理', contactPhone: '13800138003', email: 'supplier_c@huawei.com', address: '东莞市松山湖产业园区', status: 1, remark: '备用供应商', createTime: '2024-01-03T00:00:00Z', updateTime: '2024-01-03T00:00:00Z' },
    { id: 4, code: 'S004', name: '小米供应商', contactPerson: '赵经理', contactPhone: '13800138004', email: 'supplier_d@xiaomi.com', address: '北京市海淀区中关村', status: 0, remark: '暂停合作', createTime: '2024-01-04T00:00:00Z', updateTime: '2024-01-10T00:00:00Z' }
];

let nextSupplierId = 100;

const brands = [
    { id: 1, code: 'B001', name: 'Apple', logo: 'https://img-cdn.xiaohongshu.com/4d14c1c3-8b5a-4e3f-8c7d-2a1b3c4d5e6f!540!540!0!2!0!0!0', description: '全球知名科技品牌', sortOrder: 1, status: 1, remark: '', createTime: '2024-01-01T00:00:00Z', updateTime: '2024-01-01T00:00:00Z' },
    { id: 2, code: 'B002', name: 'Huawei', logo: 'https://img-cdn.xiaohongshu.com/5e15d2d4-9c6b-5f4g-9d8e-3b2c4d5e6f7g!540!540!0!2!0!0!0', description: '中国领先的科技品牌', sortOrder: 2, status: 1, remark: '', createTime: '2024-01-02T00:00:00Z', updateTime: '2024-01-02T00:00:00Z' },
    { id: 3, code: 'B003', name: 'Xiaomi', logo: 'https://img-cdn.xiaohongshu.com/6f26e3e5-0d7c-6h5h-0e9f-4c3d5e6f7g8h!540!540!0!2!0!0!0', description: '性价比高的科技品牌', sortOrder: 3, status: 1, remark: '', createTime: '2024-01-03T00:00:00Z', updateTime: '2024-01-03T00:00:00Z' },
    { id: 4, code: 'B004', name: 'Samsung', logo: 'https://img-cdn.xiaohongshu.com/7g37f4f6-1e8d-7i6i-1f0g-5d4e6f7g8h9i!540!540!0!2!0!0!0', description: '韩国知名电子品牌', sortOrder: 4, status: 0, remark: '暂停合作', createTime: '2024-01-04T00:00:00Z', updateTime: '2024-01-10T00:00:00Z' }
];

let nextBrandId = 100;

const purchases = [
    { id: 1, orderNo: 'PO202401001', supplierName: '苹果供应商A', totalAmount: 120000.00, status: 'completed', createTime: '2024-01-15 10:30:00', items: [] },
    { id: 2, orderNo: 'PO202401002', supplierName: '苹果供应商B', totalAmount: 85000.00, status: 'pending', createTime: '2024-01-20 14:20:00', items: [] },
    { id: 3, orderNo: 'PO202401003', supplierName: '苹果供应商A', totalAmount: 156000.00, status: 'completed', createTime: '2024-01-25 09:15:00', items: [] }
];

const sales = [
    { id: 1, orderNo: 'SO202401001', customerName: '客户张三', totalAmount: 23997.00, status: 'completed', createTime: '2024-01-16 11:20:00', items: [] },
    { id: 2, orderNo: 'SO202401002', customerName: '客户李四', totalAmount: 15998.00, status: 'pending', createTime: '2024-01-21 15:30:00', items: [] },
    { id: 3, orderNo: 'SO202401003', customerName: '客户王五', totalAmount: 38997.00, status: 'completed', createTime: '2024-01-26 16:45:00', items: [] }
];

const inventoryLogs = [
    { id: 1, type: 'purchase', orderNo: 'PO202401001', productCode: 'P001', productName: 'iPhone 15', quantity: 20, createTime: '2024-01-15 10:30:00' },
    { id: 2, type: 'sale', orderNo: 'SO202401001', productCode: 'P001', productName: 'iPhone 15', quantity: -3, createTime: '2024-01-16 11:20:00' },
    { id: 3, type: 'adjust', orderNo: 'AD202401001', productCode: 'P002', productName: 'MacBook Pro', quantity: -2, createTime: '2024-01-18 09:00:00' }
];

const dashboardStats = {
    totalProducts: 580,
    totalSales: 156000.00,
    totalPurchases: 361000.00,
    pendingOrders: 5,
    lowStockProducts: 3,
    todaySales: 38997.00,
    todayOrders: 12
};

let nextCategoryId = 100;
let nextProductId = 100;
let nextSkuId = 100;
let nextSkuDimensionId = 100;

function parseBody(req) {
    return new Promise((resolve, reject) => {
        let body = '';
        req.on('data', chunk => body += chunk.toString());
        req.on('end', () => {
            try {
                resolve(body ? JSON.parse(body) : {});
            } catch (e) {
                reject(e);
            }
        });
        req.on('error', reject);
    });
}

function sendJSON(res, statusCode, data) {
    res.writeHead(statusCode, { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' });
    res.end(JSON.stringify({
        code: statusCode === 200 ? 200 : statusCode,
        message: statusCode === 200 ? 'success' : 'error',
        data: data,
        timestamp: Date.now()
    }));
}

const server = http.createServer(async (req, res) => {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, PATCH, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

    if (req.method === 'OPTIONS') {
        res.writeHead(200);
        res.end();
        return;
    }

    try {
        const url = new URL(req.url, `http://${req.headers.host}`);
        const path = url.pathname;

        if (path === '/api/auth/login' && req.method === 'POST') {
            const body = await parseBody(req);
            const user = users[body.username];
            if (user && user.password === body.password) {
                const { password, ...userInfo } = user;
                sendJSON(res, 200, {
                    accessToken: 'jwt-token-' + Date.now(),
                    refreshToken: 'refresh-token-' + Date.now(),
                    expiresIn: 7200,
                    userInfo: userInfo
                });
            } else {
                sendJSON(res, 401, null);
            }
        } else if (path === '/api/auth/user/info' && req.method === 'GET') {
            sendJSON(res, 200, users['admin']);
        } else if (path === '/api/auth/permissions' && req.method === 'GET') {
            sendJSON(res, 200, ['*:*:*']);
        } else if (path === '/api/dashboard/stats' && req.method === 'GET') {
            sendJSON(res, 200, dashboardStats);
        }
        else if (path === '/api/product/categories' && req.method === 'GET') {
            const page = parseInt(url.searchParams.get('page')) || 1;
            const pageSize = parseInt(url.searchParams.get('pageSize')) || 10;
            const keyword = url.searchParams.get('keyword') || '';

            let filtered = [...categories];
            if (keyword) {
                filtered = filtered.filter(c => c.name.includes(keyword) || c.code.includes(keyword));
            }

            const start = (page - 1) * pageSize;
            const end = start + pageSize;
            sendJSON(res, 200, {
                list: filtered.slice(start, end),
                total: filtered.length,
                page: page,
                pageSize: pageSize
            });
        } else if (path === '/api/product/categories/all' && req.method === 'GET') {
            const activeCategories = categories.filter(c => c.status === 1);
            sendJSON(res, 200, activeCategories);
        } else if (path === '/api/product/categories' && req.method === 'POST') {
            const body = await parseBody(req);
            const newCategory = {
                id: nextCategoryId++,
                code: 'C' + String(nextCategoryId).padStart(5, '0'),
                ...body,
                status: 1,
                deleted: 0,
                createTime: new Date().toISOString(),
                updateTime: new Date().toISOString()
            };
            categories.push(newCategory);
            sendJSON(res, 200, newCategory);
        } else if (path && path.startsWith('/api/product/categories/') && path.split('/').pop() !== 'all' && req.method === 'GET') {
            const id = parseInt(path.split('/').pop());
            const category = categories.find(c => c.id === id && c.deleted === 0);
            sendJSON(res, 200, category || null);
        } else if (path && path.startsWith('/api/product/categories/') && req.method === 'PUT') {
            const id = parseInt(path.split('/').pop());
            const body = await parseBody(req);
            const index = categories.findIndex(c => c.id === id);
            if (index !== -1) {
                categories[index] = { ...categories[index], ...body, updateTime: new Date().toISOString() };
                sendJSON(res, 200, categories[index]);
            } else {
                sendJSON(res, 404, null);
            }
        } else if (path && path.startsWith('/api/product/categories/') && req.method === 'DELETE') {
            const id = parseInt(path.split('/').pop());
            const index = categories.findIndex(c => c.id === id);
            if (index !== -1) {
                categories[index].deleted = 1;
                sendJSON(res, 200, true);
            } else {
                sendJSON(res, 404, null);
            }
        }
        else if (path === '/api/product/products' && req.method === 'GET') {
            const page = parseInt(url.searchParams.get('page')) || 1;
            const pageSize = parseInt(url.searchParams.get('pageSize')) || 10;
            const keyword = url.searchParams.get('keyword') || '';
            const categoryId = url.searchParams.get('categoryId') || '';

            let filtered = [...products];
            if (keyword) {
                filtered = filtered.filter(p => p.name.includes(keyword) || p.code.includes(keyword));
            }
            if (categoryId) {
                filtered = filtered.filter(p => p.categoryId === parseInt(categoryId));
            }

            const start = (page - 1) * pageSize;
            const end = start + pageSize;
            sendJSON(res, 200, {
                list: filtered.slice(start, end),
                total: filtered.length,
                page: page,
                pageSize: pageSize
            });
        } else if (path === '/api/product/products' && req.method === 'POST') {
            const body = await parseBody(req);
            // 获取分类信息
            let categoryName = '';
            let categoryCode = '';
            if (body.categoryId) {
                const category = categories.find(c => c.id === body.categoryId);
                if (category) {
                    categoryName = category.name;
                    categoryCode = category.code;
                }
            }
            // 获取供应商信息
            let supplierNameVal = '';
            if (body.supplierId) {
                const supplier = suppliers.find(s => s.id === body.supplierId);
                if (supplier) {
                    supplierNameVal = supplier.name;
                }
            }
            const newProduct = {
                id: nextProductId++,
                code: 'P' + String(nextProductId).padStart(3, '0'),
                ...body,
                categoryName: body.categoryName || categoryName,
                categoryCode: body.categoryCode || categoryCode,
                supplierName: body.supplierName || supplierNameVal,
                status: 1,
                createTime: new Date().toISOString(),
                updateTime: new Date().toISOString()
            };
            products.push(newProduct);
            sendJSON(res, 200, newProduct);
        } else if (path && path.startsWith('/api/product/products/') && path.split('/').length === 5 && req.method === 'GET') {
            const id = parseInt(path.split('/').pop());
            const product = products.find(p => p.id === id);
            if (product) {
                const skus = productSkus.filter(s => s.productId === id);
                sendJSON(res, 200, { ...product, skus });
            } else {
                sendJSON(res, 200, product || null);
            }
        } else if (path && path.startsWith('/api/product/products/') && req.method === 'PUT') {
            const id = parseInt(path.split('/').pop());
            const body = await parseBody(req);
            const index = products.findIndex(p => p.id === id);
            if (index !== -1) {
                // 获取分类信息
                let categoryName = products[index].categoryName;
                let categoryCode = products[index].categoryCode;
                if (body.categoryId && body.categoryId !== products[index].categoryId) {
                    const category = categories.find(c => c.id === body.categoryId);
                    if (category) {
                        categoryName = category.name;
                        categoryCode = category.code;
                    }
                }
                // 获取供应商信息
                let supplierNameVal = products[index].supplierName;
                if (body.supplierId && body.supplierId !== products[index].supplierId) {
                    const supplier = suppliers.find(s => s.id === body.supplierId);
                    if (supplier) {
                        supplierNameVal = supplier.name;
                    }
                }
                products[index] = { 
                    ...products[index], 
                    ...body, 
                    categoryName: body.categoryName || categoryName,
                    categoryCode: body.categoryCode || categoryCode,
                    supplierName: body.supplierName || supplierNameVal,
                    updateTime: new Date().toISOString() 
                };
                sendJSON(res, 200, products[index]);
            } else {
                sendJSON(res, 404, null);
            }
        } else if (path && path.startsWith('/api/product/products/') && req.method === 'DELETE') {
            const id = parseInt(path.split('/').pop());
            const index = products.findIndex(p => p.id === id);
            if (index !== -1) {
                products.splice(index, 1);
                sendJSON(res, 200, true);
            } else {
                sendJSON(res, 404, null);
            }
        }
        else if (path === '/api/product/skus' && req.method === 'GET') {
            const productId = url.searchParams.get('productId');
            let filtered = [...productSkus];
            if (productId) {
                filtered = filtered.filter(s => s.productId === parseInt(productId));
            }
            sendJSON(res, 200, { list: filtered, total: filtered.length });
        } else if (path === '/api/product/skus' && req.method === 'POST') {
            const body = await parseBody(req);
            const newSku = {
                id: nextSkuId++,
                code: 'SKU-' + String(nextSkuId).padStart(6, '0'),
                ...body,
                status: 1,
                createTime: new Date().toISOString(),
                updateTime: new Date().toISOString()
            };
            productSkus.push(newSku);
            sendJSON(res, 200, newSku);
        } else if (path && path.startsWith('/api/product/skus/') && req.method === 'PUT') {
            const id = parseInt(path.split('/').pop());
            const body = await parseBody(req);
            const index = productSkus.findIndex(s => s.id === id);
            if (index !== -1) {
                productSkus[index] = { ...productSkus[index], ...body, updateTime: new Date().toISOString() };
                sendJSON(res, 200, productSkus[index]);
            } else {
                sendJSON(res, 404, null);
            }
        } else if (path && path.startsWith('/api/product/skus/') && req.method === 'DELETE') {
            const id = parseInt(path.split('/').pop());
            const index = productSkus.findIndex(s => s.id === id);
            if (index !== -1) {
                productSkus.splice(index, 1);
                sendJSON(res, 200, true);
            } else {
                sendJSON(res, 404, null);
            }
        } else if (path === '/api/product/skus/batch-delete' && req.method === 'DELETE') {
            const productId = parseInt(url.searchParams.get('productId'));
            if (productId) {
                const oldLength = productSkus.length;
                for (let i = productSkus.length - 1; i >= 0; i--) {
                    if (productSkus[i].productId === productId) {
                        productSkus.splice(i, 1);
                    }
                }
                sendJSON(res, 200, { deletedCount: oldLength - productSkus.length });
            } else {
                sendJSON(res, 400, { message: 'productId is required' });
            }
        } else if (path === '/api/product/sku-dimensions' && req.method === 'GET') {
            const productId = url.searchParams.get('productId');
            let filtered = [...skuDimensions];
            if (productId) {
                filtered = filtered.filter(d => d.productId === parseInt(productId));
            }
            sendJSON(res, 200, filtered);
        } else if (path === '/api/product/sku-dimensions' && req.method === 'POST') {
            const body = await parseBody(req);
            const newDimension = {
                id: nextSkuDimensionId++,
                productId: body.productId,
                name: body.name,
                values: body.values || [],
                createTime: new Date().toISOString(),
                updateTime: new Date().toISOString()
            };
            skuDimensions.push(newDimension);
            sendJSON(res, 200, newDimension);
        } else if (path && path.startsWith('/api/product/sku-dimensions/') && req.method === 'PUT') {
            const id = parseInt(path.split('/').pop());
            const body = await parseBody(req);
            const index = skuDimensions.findIndex(d => d.id === id);
            if (index !== -1) {
                skuDimensions[index] = { ...skuDimensions[index], ...body, updateTime: new Date().toISOString() };
                sendJSON(res, 200, skuDimensions[index]);
            } else {
                sendJSON(res, 404, null);
            }
        } else if (path && path.startsWith('/api/product/sku-dimensions/') && req.method === 'DELETE') {
            const id = parseInt(path.split('/').pop());
            const index = skuDimensions.findIndex(d => d.id === id);
            if (index !== -1) {
                skuDimensions.splice(index, 1);
                sendJSON(res, 200, true);
            } else {
                sendJSON(res, 404, null);
            }
        } else if (path === '/api/purchase/list' && req.method === 'GET') {
            sendJSON(res, 200, { list: purchases, total: purchases.length });
        } else if (path === '/api/purchase/add' && req.method === 'POST') {
            const body = await parseBody(req);
            const newPurchase = { id: nextProductId++, ...body, createTime: new Date().toISOString() };
            purchases.push(newPurchase);
            sendJSON(res, 200, newPurchase);
        } else if (path === '/api/sales/list' && req.method === 'GET') {
            sendJSON(res, 200, { list: sales, total: sales.length });
        } else if (path === '/api/sales/add' && req.method === 'POST') {
            const body = await parseBody(req);
            const newSale = { id: nextProductId++, ...body, createTime: new Date().toISOString() };
            sales.push(newSale);
            sendJSON(res, 200, newSale);
        } else if (path === '/api/inventory/logs' && req.method === 'GET') {
            sendJSON(res, 200, { list: inventoryLogs, total: inventoryLogs.length });
        } else if (path === '/api/inventory/low-stock' && req.method === 'GET') {
            const lowStock = productSkus.filter(s => s.stock < s.minStock);
            sendJSON(res, 200, { list: lowStock, total: lowStock.length });
        } else if (path === '/api/supplier/suppliers' && req.method === 'GET') {
            const page = parseInt(url.searchParams.get('page')) || 1;
            const pageSize = parseInt(url.searchParams.get('pageSize')) || 10;
            const keyword = url.searchParams.get('keyword') || '';
            const status = url.searchParams.get('status') ? parseInt(url.searchParams.get('status')) : undefined;
            
            let filtered = suppliers.filter(s => {
                let match = true;
                if (keyword) {
                    match = match && (s.code.toLowerCase().includes(keyword.toLowerCase()) || s.name.toLowerCase().includes(keyword.toLowerCase()));
                }
                if (status !== undefined) {
                    match = match && s.status === status;
                }
                return match;
            });
            
            const start = (page - 1) * pageSize;
            const list = filtered.slice(start, start + pageSize);
            sendJSON(res, 200, { list: list, total: filtered.length });
        } else if (path === '/api/supplier/suppliers/all' && req.method === 'GET') {
            sendJSON(res, 200, suppliers.filter(s => s.status === 1));
        } else if (path.match(/^\/api\/supplier\/suppliers\/\d+$/) && req.method === 'GET') {
            const id = parseInt(path.split('/').pop());
            const supplier = suppliers.find(s => s.id === id);
            if (supplier) {
                sendJSON(res, 200, supplier);
            } else {
                sendJSON(res, 404, { message: 'Supplier not found' });
            }
        } else if (path === '/api/supplier/suppliers' && req.method === 'POST') {
            const body = await parseBody(req);
            const newSupplier = {
                id: nextSupplierId++,
                code: body.code,
                name: body.name,
                contactPerson: body.contactPerson || '',
                contactPhone: body.contactPhone || '',
                email: body.email || '',
                address: body.address || '',
                status: body.status !== undefined ? body.status : 1,
                remark: body.remark || '',
                createTime: new Date().toISOString(),
                updateTime: new Date().toISOString()
            };
            suppliers.push(newSupplier);
            sendJSON(res, 200, newSupplier);
        } else if (path.match(/^\/api\/supplier\/suppliers\/\d+$/) && req.method === 'PUT') {
            const id = parseInt(path.split('/').pop());
            const body = await parseBody(req);
            const index = suppliers.findIndex(s => s.id === id);
            if (index !== -1) {
                suppliers[index] = {
                    ...suppliers[index],
                    ...body,
                    updateTime: new Date().toISOString()
                };
                sendJSON(res, 200, suppliers[index]);
            } else {
                sendJSON(res, 404, { message: 'Supplier not found' });
            }
        } else if (path.match(/^\/api\/supplier\/suppliers\/\d+$/) && req.method === 'DELETE') {
            const id = parseInt(path.split('/').pop());
            const index = suppliers.findIndex(s => s.id === id);
            if (index !== -1) {
                suppliers.splice(index, 1);
                sendJSON(res, 200, null);
            } else {
                sendJSON(res, 404, { message: 'Supplier not found' });
            }
        } else if (path === '/api/product/brands' && req.method === 'GET') {
            const page = parseInt(url.searchParams.get('page')) || 1;
            const pageSize = parseInt(url.searchParams.get('pageSize')) || 10;
            const keyword = url.searchParams.get('keyword') || '';
            const status = url.searchParams.get('status') ? parseInt(url.searchParams.get('status')) : undefined;
            
            let filtered = brands.filter(b => {
                let match = true;
                if (keyword) {
                    match = match && (b.code.toLowerCase().includes(keyword.toLowerCase()) || b.name.toLowerCase().includes(keyword.toLowerCase()));
                }
                if (status !== undefined) {
                    match = match && b.status === status;
                }
                return match;
            });
            
            const start = (page - 1) * pageSize;
            const list = filtered.slice(start, start + pageSize);
            sendJSON(res, 200, { list: list, total: filtered.length });
        } else if (path === '/api/product/brands/all' && req.method === 'GET') {
            sendJSON(res, 200, brands.filter(b => b.status === 1));
        } else if (path.match(/^\/api\/product\/brands\/\d+$/) && req.method === 'GET') {
            const id = parseInt(path.split('/').pop());
            const brand = brands.find(b => b.id === id);
            if (brand) {
                sendJSON(res, 200, brand);
            } else {
                sendJSON(res, 404, { message: 'Brand not found' });
            }
        } else if (path === '/api/product/brands' && req.method === 'POST') {
            const body = await parseBody(req);
            const newBrand = {
                id: nextBrandId++,
                code: body.code,
                name: body.name,
                logo: body.logo || '',
                description: body.description || '',
                sortOrder: body.sortOrder !== undefined ? body.sortOrder : 0,
                status: body.status !== undefined ? body.status : 1,
                remark: body.remark || '',
                createTime: new Date().toISOString(),
                updateTime: new Date().toISOString()
            };
            brands.push(newBrand);
            sendJSON(res, 200, newBrand);
        } else if (path.match(/^\/api\/product\/brands\/\d+$/) && req.method === 'PUT') {
            const id = parseInt(path.split('/').pop());
            const body = await parseBody(req);
            const index = brands.findIndex(b => b.id === id);
            if (index !== -1) {
                brands[index] = {
                    ...brands[index],
                    ...body,
                    updateTime: new Date().toISOString()
                };
                sendJSON(res, 200, brands[index]);
            } else {
                sendJSON(res, 404, { message: 'Brand not found' });
            }
        } else if (path.match(/^\/api\/product\/brands\/\d+$/) && req.method === 'DELETE') {
            const id = parseInt(path.split('/').pop());
            const index = brands.findIndex(b => b.id === id);
            if (index !== -1) {
                brands.splice(index, 1);
                sendJSON(res, 200, null);
            } else {
                sendJSON(res, 404, { message: 'Brand not found' });
            }
        } else if (path === '/api/report/sales-summary' && req.method === 'GET') {
            sendJSON(res, 200, {
                daily: [{ date: '2024-01-28', amount: 38997 }, { date: '2024-01-27', amount: 45678 }, { date: '2024-01-26', amount: 38997 }],
                monthly: [{ month: '2024-01', amount: 156000 }, { month: '2023-12', amount: 189000 }],
                categories: [{ category: '手机', amount: 80000 }, { category: '电脑', amount: 50000 }, { category: '耳机', amount: 26000 }]
            });
        } else {
            sendJSON(res, 404, { message: 'API not found: ' + path });
        }
    } catch (e) {
        sendJSON(res, 500, { message: e.message });
    }
});

server.listen(8081, () => {
    console.log('Mock server running on http://localhost:8081');
});
