<template>
  <div class="supplier-list">
    <div class="page-header">
      <h2 class="page-title">供应商管理</h2>
      <div class="header-actions">
        <el-button type="primary" @click="openAddDialog">
          <el-icon><Plus /></el-icon>
          新增供应商
        </el-button>
      </div>
    </div>

    <el-card>
      <div class="search-form">
        <el-form :inline="true" :model="searchForm">
          <el-form-item label="供应商名称/编码">
            <el-input v-model="searchForm.keyword" placeholder="请输入关键词" clearable></el-input>
          </el-form-item>
          <el-form-item label="状态">
            <el-select v-model="searchForm.status" placeholder="请选择" clearable>
              <el-option label="启用" :value="1"></el-option>
              <el-option label="禁用" :value="0"></el-option>
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="handleSearch">搜索</el-button>
            <el-button @click="resetSearch">重置</el-button>
          </el-form-item>
        </el-form>
      </div>

      <el-table :data="tableData" border stripe :loading="loading">
        <el-table-column prop="code" label="供应商编码" width="120"></el-table-column>
        <el-table-column prop="name" label="供应商名称" min-width="150"></el-table-column>
        <el-table-column prop="contactPerson" label="联系人" width="100"></el-table-column>
        <el-table-column prop="contactPhone" label="联系电话" width="130"></el-table-column>
        <el-table-column prop="email" label="邮箱" min-width="150"></el-table-column>
        <el-table-column prop="address" label="地址" min-width="180"></el-table-column>
        <el-table-column prop="status" label="状态" width="80">
          <template #default="scope">
            <el-tag :type="scope.row.status === 1 ? 'success' : 'danger'">
              {{ scope.row.status === 1 ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180">
          <template #default="scope">
            <el-button size="small" @click="viewSupplier(scope.row)">查看</el-button>
            <el-button size="small" @click="openEditDialog(scope.row)">编辑</el-button>
            <el-button size="small" type="danger" @click="deleteSupplier(scope.row.id)">删除</el-button>
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
      ></el-pagination>
    </el-card>

    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="600px">
      <el-form :model="formData" label-width="100px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="供应商编码" required>
              <el-input v-model="formData.code" placeholder="请输入供应商编码"></el-input>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="供应商名称" required>
              <el-input v-model="formData.name" placeholder="请输入供应商名称"></el-input>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="联系人">
              <el-input v-model="formData.contactPerson" placeholder="请输入联系人"></el-input>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="联系电话">
              <el-input v-model="formData.contactPhone" placeholder="请输入联系电话"></el-input>
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="邮箱">
          <el-input v-model="formData.email" placeholder="请输入邮箱"></el-input>
        </el-form-item>
        <el-form-item label="地址">
          <el-input v-model="formData.address" type="textarea" :rows="2" placeholder="请输入地址"></el-input>
        </el-form-item>
        <el-form-item label="状态">
          <el-switch v-model="formData.status" :active-value="1" :inactive-value="0"></el-switch>
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="formData.remark" type="textarea" :rows="3" placeholder="请输入备注"></el-input>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="saveSupplier">确定</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="viewDialogVisible" title="供应商详情" width="600px">
      <el-descriptions :column="2" border>
        <el-descriptions-item label="供应商编码">{{ viewData.code || '-' }}</el-descriptions-item>
        <el-descriptions-item label="供应商名称">{{ viewData.name || '-' }}</el-descriptions-item>
        <el-descriptions-item label="联系人">{{ viewData.contactPerson || '-' }}</el-descriptions-item>
        <el-descriptions-item label="联系电话">{{ viewData.contactPhone || '-' }}</el-descriptions-item>
        <el-descriptions-item label="邮箱">{{ viewData.email || '-' }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="viewData.status === 1 ? 'success' : 'danger'">
            {{ viewData.status === 1 ? '启用' : '禁用' }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="地址" :span="2">{{ viewData.address || '-' }}</el-descriptions-item>
        <el-descriptions-item label="备注" :span="2">{{ viewData.remark || '-' }}</el-descriptions-item>
      </el-descriptions>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { Plus } from '@element-plus/icons-vue'
import { supplierApi } from '@/api/supplier'
import type { Supplier } from '@/types/supplier'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const tableData = ref<Supplier[]>([])
const dialogVisible = ref(false)
const dialogTitle = ref('新增供应商')
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
  contactPerson: '',
  contactPhone: '',
  email: '',
  address: '',
  status: 1 as 0 | 1,
  remark: ''
})

const viewData = reactive({
  id: 0,
  code: '',
  name: '',
  contactPerson: '',
  contactPhone: '',
  email: '',
  address: '',
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
    const response = await supplierApi.list({
      page: pagination.page,
      pageSize: pagination.pageSize,
      keyword: searchForm.keyword || undefined,
      status: searchForm.status
    })
    tableData.value = response.data.list || []
    pagination.total = response.data.total || 0
  } catch (error) {
    console.error('加载供应商列表失败', error)
  } finally {
    loading.value = false
  }
}

const openAddDialog = () => {
  dialogTitle.value = '新增供应商'
  Object.assign(formData, {
    id: 0,
    code: '',
    name: '',
    contactPerson: '',
    contactPhone: '',
    email: '',
    address: '',
    status: 1,
    remark: ''
  })
  dialogVisible.value = true
}

const openEditDialog = (row: Supplier) => {
  dialogTitle.value = '编辑供应商'
  Object.assign(formData, {
    id: row.id,
    code: row.code,
    name: row.name,
    contactPerson: row.contactPerson || '',
    contactPhone: row.contactPhone || '',
    email: row.email || '',
    address: row.address || '',
    status: row.status,
    remark: row.remark || ''
  })
  dialogVisible.value = true
}

const viewSupplier = (row: Supplier) => {
  Object.assign(viewData, {
    id: row.id,
    code: row.code,
    name: row.name,
    contactPerson: row.contactPerson || '',
    contactPhone: row.contactPhone || '',
    email: row.email || '',
    address: row.address || '',
    status: row.status,
    remark: row.remark || ''
  })
  viewDialogVisible.value = true
}

const saveSupplier = async () => {
  if (!formData.code || !formData.name) {
    ElMessage.warning('请填写必填项')
    return
  }
  try {
    const data = {
      code: formData.code,
      name: formData.name,
      contactPerson: formData.contactPerson,
      contactPhone: formData.contactPhone,
      email: formData.email,
      address: formData.address,
      status: formData.status,
      remark: formData.remark
    }
    if (formData.id) {
      await supplierApi.update({ ...data, id: formData.id })
    } else {
      await supplierApi.create(data)
    }
    dialogVisible.value = false
    await loadData()
    ElMessage.success(formData.id ? '更新成功' : '创建成功')
  } catch (error) {
    console.error('保存供应商失败', error)
    ElMessage.error('保存失败')
  }
}

const deleteSupplier = async (id: number) => {
  try {
    await ElMessageBox.confirm('确定要删除该供应商吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await supplierApi.delete(id)
    await loadData()
    ElMessage.success('删除成功')
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除供应商失败', error)
      ElMessage.error('删除失败')
    }
  }
}

onMounted(() => {
  loadData()
})
</script>

<style lang="scss" scoped>
.supplier-list {
  padding: 20px;
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
</style>
