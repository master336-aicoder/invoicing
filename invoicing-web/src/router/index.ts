import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router'
import { useUserStore } from '@/stores/user'

const routes: RouteRecordRaw[] = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Login.vue'),
    meta: { title: '登录', requiresAuth: false }
  },
  {
    path: '/',
    component: () => import('@/layouts/MainLayout.vue'),
    redirect: '/dashboard',
    meta: { requiresAuth: true },
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('@/views/Dashboard.vue'),
        meta: { title: '首页', icon: 'Odometer' }
      },
      {
        path: 'product',
        name: 'Product',
        meta: { title: '商品管理', icon: 'Goods' },
        children: [
          {
            path: 'list',
            name: 'ProductList',
            component: () => import('@/views/product/ProductList.vue'),
            meta: { title: '商品列表' }
          },
          {
            path: 'category',
            name: 'ProductCategory',
            component: () => import('@/views/product/ProductCategory.vue'),
            meta: { title: '商品分类' }
          },
          {
            path: 'brand',
            name: 'Brand',
            component: () => import('@/views/product/Brand.vue'),
            meta: { title: '品牌管理' }
          }
        ]
      },
      {
        path: 'purchase',
        name: 'Purchase',
        meta: { title: '采购管理', icon: 'ShoppingCart' },
        children: [
          {
            path: 'order',
            name: 'PurchaseOrder',
            component: () => import('@/views/purchase/PurchaseOrder.vue'),
            meta: { title: '采购订单' }
          },
          {
            path: 'supplier',
            name: 'Supplier',
            component: () => import('@/views/purchase/Supplier.vue'),
            meta: { title: '供应商管理' }
          }
        ]
      },
      {
        path: 'sales',
        name: 'Sales',
        meta: { title: '销售管理', icon: 'Sell' },
        children: [
          {
            path: 'order',
            name: 'SalesOrder',
            component: () => import('@/views/sales/SalesOrder.vue'),
            meta: { title: '销售订单' }
          },
          {
            path: 'customer',
            name: 'Customer',
            component: () => import('@/views/sales/Customer.vue'),
            meta: { title: '客户管理' }
          }
        ]
      },
      {
        path: 'warehouse',
        name: 'Warehouse',
        meta: { title: '仓储管理', icon: 'Box' },
        children: [
          {
            path: 'inventory',
            name: 'Inventory',
            component: () => import('@/views/warehouse/Inventory.vue'),
            meta: { title: '库��管理' }
          },
          {
            path: 'stock',
            name: 'Stock',
            component: () => import('@/views/warehouse/Stock.vue'),
            meta: { title: '库存查询' }
          }
        ]
      },
      {
        path: 'report',
        name: 'Report',
        meta: { title: '报表中心', icon: 'DataAnalysis' },
        children: [
          {
            path: 'sales-report',
            name: 'SalesReport',
            component: () => import('@/views/report/SalesReport.vue'),
            meta: { title: '销售报表' }
          }
        ]
      }
    ]
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'NotFound',
    component: () => import('@/views/NotFound.vue'),
    meta: { title: '页面不存在' }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  document.title = `${to.meta.title || '进销存系统'} - 商用进销存系统`

  const userStore = useUserStore()
  const requiresAuth = to.meta.requiresAuth !== false

  if (requiresAuth && !userStore.token) {
    next({ name: 'Login', query: { redirect: to.fullPath } })
  } else if (to.name === 'Login' && userStore.token) {
    next({ name: 'Dashboard' })
  } else {
    next()
  }
})

export default router
