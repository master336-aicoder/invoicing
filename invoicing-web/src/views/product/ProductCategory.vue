<template>
  <div class="category-list">
    <div class="page-header">
      <h2 class="page-title">商品分类管理</h2>
      <div class="header-actions">
        <el-button type="primary" @click="openAddDialog">
          <el-icon><Plus /></el-icon>
          新增分类
        </el-button>
      </div>
    </div>

    <el-card>
      <div class="search-form">
        <el-form :inline="true" :model="searchForm">
          <el-form-item label="分类名称/编码">
            <el-input v-model="searchForm.keyword" placeholder="请输入关键词" clearable></el-input>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="handleSearch">搜索</el-button>
            <el-button @click="resetSearch">重置</el-button>
          </el-form-item>
        </el-form>
      </div>

      <el-table
        :data="tableData"
        row-key="id"
        :tree-props="{ children: 'children', hasChildren: 'hasChildren' }"
        border
        stripe
        :loading="loading"
      >
        <el-table-column prop="code" label="分类编码" min-width="180"></el-table-column>
        <el-table-column prop="name" label="分类名称" min-width="250"></el-table-column>
        <el-table-column prop="level" label="层级" width="100">
          <template #default="scope">
            <el-tag type="info">第{{ scope.row.level }}级</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="sortOrder" label="排序" width="80"></el-table-column>
        <el-table-column prop="status" label="状态" width="80">
          <template #default="scope">
            <el-tag :type="scope.row.status === 1 ? 'success' : 'danger'">
              {{ scope.row.status === 1 ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="240" fixed="right">
          <template #default="scope">
            <el-tooltip content="查看" placement="top">
              <el-button link size="small" @click="viewCategory(scope.row)">
                <el-icon><View /></el-icon>
              </el-button>
            </el-tooltip>
            <el-tooltip content="添加子分类" placement="top">
              <el-button link size="small" @click="openAddSubDialog(scope.row)">
                <el-icon><FolderAdd /></el-icon>
              </el-button>
            </el-tooltip>
            <el-tooltip content="编辑" placement="top">
              <el-button link size="small" @click="openEditDialog(scope.row)">
                <el-icon><Edit /></el-icon>
              </el-button>
            </el-tooltip>
            <el-tooltip content="删除" placement="top">
              <el-button link size="small" type="danger" @click="deleteCategory(scope.row.id)">
                <el-icon><Delete /></el-icon>
              </el-button>
            </el-tooltip>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="500px">
      <el-form :model="formData" label-width="100px">
        <el-form-item label="分类名称" required>
          <el-input v-model="formData.name" placeholder="请输入分类名称"></el-input>
        </el-form-item>
        <el-form-item label="上级分类">
          <el-tree-select
            v-model="formData.parentId"
            :data="parentTreeOptions"
            :props="{ label: 'name', value: 'id' }"
            clearable
            check-strictly
            placeholder="请选择上级分类（不选为顶级）"
          />
        </el-form-item>
        <el-form-item label="排序号">
          <el-input-number v-model="formData.sortOrder" :min="0" placeholder="请输入排序号"></el-input-number>
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
        <el-button type="primary" @click="saveCategory">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { Plus, View, Edit, Delete, FolderAdd } from '@element-plus/icons-vue'
import { categoryApi } from '@/api/product'
import type { Category } from '@/types/product'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const tableData = ref<any[]>([])
const dialogVisible = ref(false)
const dialogTitle = ref('新增分类')

const searchForm = reactive({
  keyword: ''
})

const formData = reactive({
  id: 0,
  code: '',
  name: '',
  parentId: 0,
  level: 1,
  sortOrder: 1,
  status: 1,
  remark: ''
})

const allCategories = ref<Category[]>([])

function buildTree(categories: Category[]): any[] {
  const map = new Map()
  const roots: any[] = []
  
  categories.forEach(cat => {
    map.set(cat.id, { ...cat, children: [] })
  })
  
  categories.forEach(cat => {
    const node = map.get(cat.id)
    if (cat.parentId === 0) {
      roots.push(node)
    } else {
      const parent = map.get(cat.parentId)
      if (parent) {
        parent.children.push(node)
      }
    }
  })
  
  return roots
}

const parentTreeOptions = computed(() => {
  return buildTree(allCategories.value.filter(c => c.status === 1 && c.level < 3))
})

const handleSearch = async () => {
  await loadData()
}

const resetSearch = () => {
  searchForm.keyword = ''
  loadData()
}

const loadData = async () => {
  loading.value = true
  try {
    const response = await categoryApi.getAll()
    if (response.code === 200) {
      allCategories.value = response.data
      let filtered = response.data
      if (searchForm.keyword) {
        filtered = filtered.filter(c => 
          c.code.toLowerCase().includes(searchForm.keyword.toLowerCase()) || 
          c.name.toLowerCase().includes(searchForm.keyword.toLowerCase())
        )
      }
      tableData.value = buildTree(filtered)
    }
  } catch (error) {
    console.error('加载分类列表失败', error)
  } finally {
    loading.value = false
  }
}

const loadAllCategories = async () => {
  try {
    const response = await categoryApi.getAll()
    if (response.code === 200) {
      allCategories.value = response.data
    }
  } catch (error) {
    console.error('加载所有分类失败', error)
  }
}

const openAddDialog = () => {
  dialogTitle.value = '新增分类'
  Object.assign(formData, {
    id: 0,
    code: 'C' + Date.now().toString().slice(-6),
    name: '',
    parentId: 0,
    level: 1,
    sortOrder: 1,
    status: 1,
    remark: ''
  })
  dialogVisible.value = true
}

const openAddSubDialog = (row: Category) => {
  dialogTitle.value = '新增子分类'
  Object.assign(formData, {
    id: 0,
    code: 'C' + Date.now().toString().slice(-6),
    name: '',
    parentId: row.id,
    level: row.level + 1,
    sortOrder: 1,
    status: 1,
    remark: ''
  })
  dialogVisible.value = true
}

const openEditDialog = (row: Category) => {
  dialogTitle.value = '编辑分类'
  Object.assign(formData, {
    id: row.id,
    code: row.code,
    name: row.name,
    parentId: row.parentId || 0,
    level: row.level,
    sortOrder: row.sortOrder || 1,
    status: row.status,
    remark: row.remark || ''
  })
  dialogVisible.value = true
}

const viewCategory = (row: Category) => {
  openEditDialog(row)
}

const saveCategory = async () => {
  if (!formData.name) {
    ElMessage.warning('请输入分类名称')
    return
  }
  try {
    let parentLevel = 0
    if (formData.parentId > 0) {
      const parent = allCategories.value.find(c => c.id === formData.parentId)
      parentLevel = parent ? parent.level : 0
    }
    const data = {
      code: formData.code,
      name: formData.name,
      parentId: formData.parentId,
      level: parentLevel + 1,
      sortOrder: formData.sortOrder,
      status: formData.status,
      remark: formData.remark
    }
    if (formData.id) {
      await categoryApi.update({ ...data, id: formData.id })
    } else {
      await categoryApi.create(data)
    }
    dialogVisible.value = false
    await loadData()
    ElMessage.success(formData.id ? '更新成功' : '创建成功')
  } catch (error) {
    console.error('保存分类失败', error)
    ElMessage.error('保存失败')
  }
}

const deleteCategory = async (id: number) => {
  const hasChildren = allCategories.value.some(c => c.parentId === id)
  if (hasChildren) {
    ElMessage.warning('该分类下有子分类，无法删除')
    return
  }
  
  try {
    await ElMessageBox.confirm('确定要删除该分类吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await categoryApi.delete(id)
    await loadData()
    ElMessage.success('删除成功')
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除分类失败', error)
      ElMessage.error('删除失败')
    }
  }
}

onMounted(() => {
  loadData()
})
</script>

<style lang="scss" scoped>
.category-list {
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

:deep(.el-table .el-table__expand-icon) {
  transition: transform 0.2s;
  .el-icon {
    font-size: 14px;
  }
}
</style>
