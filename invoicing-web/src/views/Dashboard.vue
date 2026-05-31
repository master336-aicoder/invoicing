<template>
  <div class="dashboard">
    <div class="page-header">
      <h2 class="page-title">首页</h2>
    </div>

    <el-row :gutter="20" class="stat-cards">
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-icon" style="background: #409eff">
            <el-icon :size="32"><Goods /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ stats.totalProducts || 0 }}</div>
            <div class="stat-label">商品数量</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-icon" style="background: #67c23a">
            <el-icon :size="32"><ShoppingCart /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ stats.pendingOrders || 0 }}</div>
            <div class="stat-label">待处理订单</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-icon" style="background: #e6a23c">
            <el-icon :size="32"><Sell /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">¥{{ (stats.todaySales || 0).toLocaleString() }}</div>
            <div class="stat-label">今日销售</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-icon" style="background: #f56c6c">
            <el-icon :size="32"><Box /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ stats.lowStockProducts || 0 }}</div>
            <div class="stat-label">库存预警</div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" class="chart-row">
      <el-col :span="12">
        <el-card>
          <template #header>
            <span>销售趋势</span>
          </template>
          <LineChart
            title=""
            :x-data="salesTrend.xData"
            :series-data="salesTrend.seriesData"
            height="300px"
          />
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card>
          <template #header>
            <span>销售分类占比</span>
          </template>
          <PieChart
            title=""
            :data="salesCategory.data"
            height="300px"
          />
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" class="chart-row">
      <el-col :span="24">
        <el-card>
          <template #header>
            <span>月度销售业绩</span>
          </template>
          <BarChart
            title=""
            :x-data="monthlySales.xData"
            :series-data="monthlySales.seriesData"
            height="300px"
          />
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { Goods, ShoppingCart, Sell, Box } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import LineChart from '@/components/charts/LineChart.vue'
import PieChart from '@/components/charts/PieChart.vue'
import BarChart from '@/components/charts/BarChart.vue'
import request from '@/utils/request'

const stats = ref({
  totalProducts: 0,
  pendingOrders: 0,
  todaySales: 0,
  todayOrders: 0,
  lowStockProducts: 0,
  totalSales: 0,
  totalPurchases: 0
})

const salesTrend = reactive({
  xData: ['1月', '2月', '3月', '4月', '5月', '6月'],
  seriesData: [
    { name: '销售额', data: [120000, 135000, 150000, 165000, 180000, 200000], smooth: true },
    { name: '利润', data: [25000, 28000, 32000, 35000, 40000, 45000], smooth: true }
  ]
})

const salesCategory = reactive({
  data: [
    { name: '电子产品', value: 45000 },
    { name: '办公用品', value: 32000 },
    { name: '五金工具', value: 28000 },
    { name: '食品饮料', value: 21000 },
    { name: '其他', value: 15000 }
  ]
})

const monthlySales = reactive({
  xData: ['1月', '2月', '3月', '4月', '5月', '6月'],
  seriesData: [
    { name: '销售额', data: [120000, 135000, 150000, 165000, 180000, 200000] },
    { name: '订单数', data: [1200, 1350, 1500, 1650, 1800, 2000] }
  ]
})

async function fetchDashboardStats() {
  try {
    const res = await request.get('/dashboard/stats')
    if (res.code === 200) {
      stats.value = res.data
    }
  } catch (error) {
    console.error('Failed to fetch dashboard stats:', error)
  }
}

async function fetchSalesSummary() {
  try {
    const res = await request.get('/report/sales-summary')
    if (res.code === 200) {
      if (res.data.daily) {
        salesTrend.xData = res.data.daily.map((d: any) => d.date)
        salesTrend.seriesData = [
          { name: '销售额', data: res.data.daily.map((d: any) => d.amount), smooth: true }
        ]
      }
      if (res.data.categories) {
        salesCategory.data = res.data.categories.map((c: any) => ({
          name: c.category,
          value: c.amount
        }))
      }
      if (res.data.monthly) {
        monthlySales.xData = res.data.monthly.map((m: any) => m.month)
        monthlySales.seriesData = [
          { name: '销售额', data: res.data.monthly.map((m: any) => m.amount) }
        ]
      }
    }
  } catch (error) {
    console.error('Failed to fetch sales summary:', error)
  }
}

onMounted(() => {
  fetchDashboardStats()
  fetchSalesSummary()
})
</script>

<style lang="scss" scoped>
.dashboard {
  padding: 20px;
}

.stat-cards {
  margin-bottom: 20px;
}

.stat-card {
  display: flex;
  align-items: center;
  padding: 20px;

  .stat-icon {
    width: 60px;
    height: 60px;
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #fff;
    margin-right: 16px;
  }

  .stat-info {
    .stat-value {
      font-size: 28px;
      font-weight: 600;
      color: #303133;
    }

    .stat-label {
      font-size: 14px;
      color: #909399;
      margin-top: 4px;
    }
  }
}

.chart-row {
  margin-bottom: 20px;
}

.page-header {
  margin-bottom: 20px;

  .page-title {
    font-size: 22px;
    font-weight: 600;
    color: #303133;
    margin: 0;
  }
}
</style>
