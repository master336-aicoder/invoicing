<template>
  <div class="brand-list">
    <div class="page-header">
      <h2 class="page-title">品牌管理</h2>
      <div class="header-actions">
        <el-button type="primary" @click="openAddDialog">
          <el-icon><Plus /></el-icon>
          新增品牌
        </el-button>
      </div>
    </div>

    <el-card>
      <div class="search-form">
        <el-form :inline="true" :model="searchForm">
          <el-form-item label="品牌名称/编码">
            <el-input v-model="searchForm.keyword" placeholder="请输入关键词" clearable />
          </el-form-item>
          <el-form-item label="状态">
            <el-select v-model="searchForm.status" placeholder="请选择" clearable>
              <el-option label="启用" :value="1" />
              <el-option label="禁用" :value="0" />
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="handleSearch">搜索</el-button>
            <el-button @click="resetSearch">重置</el-button>
          </el-form-item>
        </el-form>
      </div>

      <el-table :data="tableData" border stripe :loading="loading">
        <el-table-column prop="code" label="品牌编码" width="120" />
        <el-table-column prop="name" label="品牌名称" min-width="150" />
        <el-table-column prop="logo" label="品牌Logo" width="120">
          <template #default="{ row }">
            <el-image v-if="row.logo" :src="row.logo" fit="cover" style="width: 60px; height: 60px; border-radius: 4px" />
            <span v-else style="color: #909399">-</span>
          </template>
        </el-table-column>
        <el-table-column prop="sortOrder" label="排序" width="80" />
        <el-table-column prop="status" label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'danger'">
              {{ row.status === 1 ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="remark" label="备注" min-width="150" show-overflow-tooltip />
        <el-table-column label="操作" width="240" fixed="right">
          <template #default="{ row }">
            <el-tooltip content="查看" placement="top">
              <el-button link size="small" @click="viewBrand(row)">
                <el-icon><View /></el-icon>
              </el-button>
            </el-tooltip>
            <el-tooltip content="编辑" placement="top">
              <el-button link size="small" @click="openEditDialog(row)">
                <el-icon><Edit /></el-icon>
              </el-button>
            </el-tooltip>
            <el-tooltip content="删除" placement="top">
              <el-button link size="small" type="danger" @click="deleteBrand(row.id)">
                <el-icon><Delete /></el-icon>
              </el-button>
            </el-tooltip>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        v-model:current-page="pagination.page"
        v-model:page-size="pagination.pageSize"
        :total="pagination.total"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
      />
    </el-card>

    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="600px">
      <el-form :model="formData" label-width="100px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="品牌编码" required>
              <el-input v-model="formData.code" placeholder="请输入品牌编码" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="品牌名称" required>
              <el-input v-model="formData.name" placeholder="请输入品牌名称" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="品牌Logo">
          <el-input v-model="formData.logo" placeholder="请输入Logo图片URL" />
        </el-form-item>
        <el-form-item label="品牌描述">
          <el-input v-model="formData.description" type="textarea" :rows="3" placeholder="请输入品牌描述" />
        </el-form-item>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="排序">
              <el-input-number v-model="formData.sortOrder" :min="0" placeholder="排序" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="状态">
              <el-switch v-model="formData.status" :active-value="1" :inactive-value="0" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="备注">
          <el-input v-model="formData.remark" type="textarea" :rows="3" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="saveBrand">确定</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="viewDialogVisible" title="品牌详情" width="600px">
      <el-descriptions :column="2" border>
        <el-descriptions-item label="品牌编码">{{ viewData.code || '-' }}</el-descriptions-item>
        <el-descriptions-item label="品牌名称">{{ viewData.name || '-' }}</el-descriptions-item>
        <el-descriptions-item label="品牌Logo" :span="2">
          <el-image v-if="viewData.logo" :src="viewData.logo" fit="cover" style="width: 100px; height: 100px; border-radius: 4px" />
          <span v-else style="color: #909399">-</span>
        </el-descriptions-item>
        <el-descriptions-item label="排序">{{ viewData.sortOrder || '-' }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="viewData.status === 1 ? 'success' : 'danger'">
            {{ viewData.status === 1 ? '启用' : '禁用' }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="品牌描述" :span="2">{{ viewData.description || '-' }}</el-descriptions-item>
        <el-descriptions-item label="备注" :span="2">{{ viewData.remark || '-' }}</el-descriptions-item>
      </el-descriptions>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { Plus, View, Edit, Delete } from '@element-plus/icons-vue'
import { brandApi } from '@/api/brand'
import type { Brand } from '@/types/brand'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const tableData = ref<Brand[]>([])
const dialogVisible = ref(false)
const dialogTitle = ref('新增品牌')
const viewDialogVisible = ref(false)

const searchForm = reactive({
  keyword: '',
  status: undefined as number | undefined
})

const pagination = reactive({
  page: 1,
  pageSize: 10,
  total: 0
})

const formData = reactive({
  id: 0,
  code: '',
  name: '',
  logo: '',
  description: '',
  sortOrder: 0,
  status: 1 as 0 | 1,
  remark: ''
})

const viewData = reactive({
  id: 0,
  code: '',
  name: '',
  logo: '',
  description: '',
  sortOrder: 0,
  status: 1 as 0 | 1,
  remark: ''
})

const handleSearch = async () => {
  pagination.page = 1
  await loadData()
}

const resetSearch = () => {
  searchForm.keyword = ''
  searchForm.status = undefined
  pagination.page = 1
  loadData()
}

const handleSizeChange = () => {
  pagination.page = 1
  loadData()
}

const handleCurrentChange = () => {
  loadData()
}

const loadData = async () => {
  loading.value = true
  try {
    const response = await brandApi.list({
      page: pagination.page,
      pageSize: pagination.pageSize,
      keyword: searchForm.keyword || undefined,
      status: searchForm.status
    })
    tableData.value = response.data.list || []
    pagination.total = response.data.total || 0
  } catch (error) {
    console.error('加载品牌列表失败', error)
  } finally {
    loading.value = false
  }
}

const openAddDialog = () => {
  dialogTitle.value = '新增品牌'
  Object.assign(formData, {
    id: 0,
    code: '',
    name: '',
    logo: '',
    description: '',
    sortOrder: 0,
    status: 1,
    remark: ''
  })
  dialogVisible.value = true
}

const openEditDialog = (row: Brand) => {
  dialogTitle.value = '编辑品牌'
  Object.assign(formData, {
    id: row.id,
    code: row.code,
    name: row.name,
    logo: row.logo || '',
    description: row.description || '',
    sortOrder: row.sortOrder || 0,
    status: row.status,
    remark: row.remark || ''
  })
  dialogVisible.value = true
}

const viewBrand = (row: Brand) => {
  Object.assign(viewData, {
    id: row.id,
    code: row.code,
    name: row.name,
    logo: row.logo || '',
    description: row.description || '',
    sortOrder: row.sortOrder || 0,
    status: row.status,
    remark: row.remark || ''
  })
  viewDialogVisible.value = true
}

const saveBrand = async () => {
  if (!formData.code || !formData.name) {
    ElMessage.warning('请填写必填项')
    return
  }
  try {
    const data = {
      code: formData.code,
      name: formData.name,
      logo: formData.logo,
      description: formData.description,
      sortOrder: formData.sortOrder,
      status: formData.status,
      remark: formData.remark
    }
    if (formData.id) {
      await brandApi.update({ ...data, id: formData.id })
      ElMessage.success('更新成功')
    } else {
      await brandApi.create(data)
      ElMessage.success('创建成功')
    }
    dialogVisible.value = false
    await loadData()
  } catch (error) {
    console.error('保存品牌失败', error)
    ElMessage.error('保存失败')
  }
}

const deleteBrand = async (id: number) => {
  try {
    await ElMessageBox.confirm('确定要删除该品牌吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await brandApi.delete(id)
    await loadData()
    ElMessage.success('删除成功')
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除品牌失败', error)
      ElMessage.error('删除失败')
    }
  }
}

onMounted(() => {
  loadData()
})
</script>

<style lang="scss" scoped>
.brand-list {
  padding: 20px;
  width: 100%;
  box-sizing: border-box;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;

  .page-title {
    font-size: 18px;
    font-weight: 600;
    color: #303133;
    margin: 0;
  }

  .header-actions {
    display: flex;
    gap: 10px;
  }
}

.search-form {
  margin-bottom: 20px;
}

:deep(.el-card) {
  width: 100%;
  box-sizing: border-box;
}

:deep(.el-table) {
  width: 100%;
}
</style>
