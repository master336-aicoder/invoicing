<template>
  <div class="product-list">
    <div class="page-header">
      <h2 class="page-title">商品管理</h2>
      <div class="header-actions">
        <el-button type="primary" @click="openAddDialog">
          <el-icon><Plus /></el-icon>
          新增商品
        </el-button>
      </div>
    </div>

    <el-card>
      <div class="search-form">
        <el-form :inline="true" :model="searchForm">
          <el-form-item label="商品名称/编码">
            <el-input v-model="searchForm.keyword" placeholder="请输入关键词" clearable></el-input>
          </el-form-item>
          <el-form-item label="商品分类">
            <el-select v-model="searchForm.categoryId" placeholder="请选择分类" clearable>
              <el-option label="全部" value=""></el-option>
              <el-option v-for="cat in categoryOptions" :key="cat.id" :label="cat.name" :value="cat.id"></el-option>
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="handleSearch">搜索</el-button>
            <el-button @click="resetSearch">重置</el-button>
          </el-form-item>
        </el-form>
      </div>

      <el-table :data="tableData" border stripe :loading="loading">
        <el-table-column label="商品图片" width="100">
          <template #default="scope">
            <el-image
              v-if="scope.row.image"
              :src="scope.row.image"
              fit="cover"
              style="width: 60px; height: 60px"
              :preview-src-list="[scope.row.image]"
            ></el-image>
            <span v-else class="no-image">无图</span>
          </template>
        </el-table-column>
        <el-table-column prop="code" label="商品编码" width="120"></el-table-column>
        <el-table-column prop="name" label="商品名称" min-width="150"></el-table-column>
        <el-table-column prop="categoryName" label="商品分类" width="120"></el-table-column>
        <el-table-column prop="supplierName" label="供应商" width="120"></el-table-column>
        <el-table-column prop="unit" label="单位" width="80"></el-table-column>
        <el-table-column label="价格区间" width="150">
          <template #default="scope">
            <span v-if="scope.row.minPrice && scope.row.maxPrice">
              ¥{{ scope.row.minPrice.toFixed(2) }} - ¥{{ scope.row.maxPrice.toFixed(2) }}
            </span>
            <span v-else-if="scope.row.salePrice">¥{{ scope.row.salePrice.toFixed(2) }}</span>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column prop="skuCount" label="SKU数" width="80">
          <template #default="scope">
            <el-tag type="info">{{ scope.row.skuCount || 0 }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="80">
          <template #default="scope">
            <el-tag :type="scope.row.status === 1 ? 'success' : 'danger'">
              {{ scope.row.status === 1 ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="280">
          <template #default="scope">
            <el-button size="small" @click="viewProduct(scope.row)">查看</el-button>
            <el-button size="small" @click="openEditDialog(scope.row)">编辑</el-button>
            <el-button size="small" type="warning" @click="openSkuDialog(scope.row)">SKU</el-button>
            <el-button size="small" type="danger" @click="deleteProduct(scope.row.id)">删除</el-button>
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

    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="80%" center top="5vh">
      <template v-if="dialogMode === 'view'">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="商品编码">{{ formData.code || '-' }}</el-descriptions-item>
          <el-descriptions-item label="商品名称">{{ formData.name || '-' }}</el-descriptions-item>
          <el-descriptions-item label="商品分类">{{ formData.categoryName || '-' }}</el-descriptions-item>
          <el-descriptions-item label="供应商">{{ formData.supplierName || '-' }}</el-descriptions-item>
          <el-descriptions-item label="商品单位">{{ formData.unit || '-' }}</el-descriptions-item>
          <el-descriptions-item label="最小起订量">{{ formData.minOrderQty || '-' }}</el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="formData.status === 1 ? 'success' : 'info'">
              {{ formData.status === 1 ? '启用' : '停用' }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="商品头图" :span="2">
            <el-image 
              v-if="formData.image" 
              :src="formData.image" 
              fit="cover" 
              style="width: 200px; height: 200px; border-radius: 8px"
            ></el-image>
            <span v-else style="color: #909399">暂无图片</span>
          </el-descriptions-item>
          <el-descriptions-item label="商品详情" :span="2">
            <div class="editor-preview" v-html="descriptionHtml"></div>
          </el-descriptions-item>
          <el-descriptions-item label="备注" :span="2">{{ formData.remark || '-' }}</el-descriptions-item>
        </el-descriptions>
        <div v-if="skuList.length > 0" style="margin-top: 20px">
          <h4 style="margin-bottom: 12px; font-size: 16px">SKU列表</h4>
          <el-table :data="skuList" border stripe size="small">
            <el-table-column prop="skuName" label="SKU名称" min-width="150"></el-table-column>
            <el-table-column label="规格" min-width="200">
              <template #default="{ row }">
                <el-tag 
                  v-for="(attr, idx) in row.attributeValues" 
                  :key="idx"
                  style="margin-right: 4px; margin-bottom: 4px"
                >
                  {{ attr.dimensionName }}: {{ attr.value }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="costPrice" label="成本价" width="120">
              <template #default="{ row }">
                ¥{{ row.costPrice?.toFixed(2) || '-' }}
              </template>
            </el-table-column>
            <el-table-column prop="salePrice" label="售价" width="120">
              <template #default="{ row }">
                ¥{{ row.salePrice?.toFixed(2) || '-' }}
              </template>
            </el-table-column>
            <el-table-column prop="stock" label="库存" width="100"></el-table-column>
          </el-table>
        </div>
      </template>
      <template v-else>
        <el-form :model="formData" label-width="100px">
          <el-row :gutter="20">
            <el-col :span="12">
              <el-form-item label="商品名称" required>
                <el-input v-model="formData.name" placeholder="请输入商品名称"></el-input>
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="商品分类">
                <el-select v-model="formData.categoryId" placeholder="请选择分类">
                  <el-option v-for="cat in categoryOptions" :key="cat.id" :label="cat.name" :value="cat.id"></el-option>
                </el-select>
              </el-form-item>
            </el-col>
          </el-row>
          <el-row :gutter="20">
            <el-col :span="12">
              <el-form-item label="供应商">
                <el-select v-model="formData.supplierId" placeholder="请选择供应商" @change="handleSupplierChange">
                  <el-option v-for="supplier in supplierOptions" :key="supplier.id" :label="supplier.name" :value="supplier.id"></el-option>
                </el-select>
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="商品单位">
                <el-input v-model="formData.unit" placeholder="如：台、个、件"></el-input>
              </el-form-item>
            </el-col>
          </el-row>
          <el-row :gutter="20">
            <el-col :span="12">
              <el-form-item label="最小起订量">
                <el-input-number v-model="formData.minOrderQty" :min="1" placeholder="最小起订量"></el-input-number>
              </el-form-item>
            </el-col>
          </el-row>
          <el-form-item label="商品头图" class="product-image-item">
            <div class="image-input-wrapper">
              <div class="image-preview-box" @click="triggerImageUpload">
                <el-image 
                  v-if="formData.image" 
                  :src="formData.image" 
                  fit="cover" 
                  class="preview-image"
                ></el-image>
                <div v-else class="preview-placeholder">
                  <el-icon class="placeholder-icon"><Picture /></el-icon>
                  <span>点击上传图片</span>
                </div>
                <div class="preview-overlay">
                  <el-icon><Upload /></el-icon>
                </div>
              </div>
              <input 
                ref="imageInputRef" 
                type="file" 
                accept="image/*" 
                @change="handleImageUpload" 
                style="display: none"
              >
              <div class="image-input-section">
                <el-input 
                  v-model="formData.image" 
                  placeholder="请输入图片URL" 
                  size="large"
                  clearable
                >
                  <template #prefix>
                    <el-icon><Link /></el-icon>
                  </template>
                </el-input>
                <div class="input-hint">支持输入网络图片URL或点击预览区选择本地图片</div>
              </div>
            </div>
          </el-form-item>
          <el-form-item label="商品详情">
            <div class="rich-editor-wrapper">
              <div class="editor-toolbar">
                <button type="button" @click="execCommand('bold')" class="toolbar-btn" :class="{ active: isCommandActive('bold') }" title="粗体">
                  <span class="btn-bold">B</span>
                </button>
                <button type="button" @click="execCommand('italic')" class="toolbar-btn" :class="{ active: isCommandActive('italic') }" title="斜体">
                  <span class="btn-italic">I</span>
                </button>
                <button type="button" @click="execCommand('underline')" class="toolbar-btn" :class="{ active: isCommandActive('underline') }" title="下划线">
                  <span class="btn-underline">U</span>
                </button>
                <span class="toolbar-separator">|</span>
                <button type="button" @click="execCommand('formatBlock', 'h1')" class="toolbar-btn" title="标题1">
                  <span>H1</span>
                </button>
                <button type="button" @click="execCommand('formatBlock', 'h2')" class="toolbar-btn" title="标题2">
                  <span>H2</span>
                </button>
                <button type="button" @click="execCommand('formatBlock', 'p')" class="toolbar-btn" title="段落">
                  <span>P</span>
                </button>
                <span class="toolbar-separator">|</span>
                <button type="button" @click="execCommand('justifyLeft')" class="toolbar-btn" title="左对齐">
                  <span class="btn-align-left">◁</span>
                </button>
                <button type="button" @click="execCommand('justifyCenter')" class="toolbar-btn" title="居中">
                  <span class="btn-align-center">▷◁</span>
                </button>
                <button type="button" @click="execCommand('justifyRight')" class="toolbar-btn" title="右对齐">
                  <span class="btn-align-right">▷</span>
                </button>
                <span class="toolbar-separator">|</span>
                <button type="button" @click="execCommand('insertUnorderedList')" class="toolbar-btn" title="无序列表">
                  <span class="btn-list-ul">•</span>
                </button>
                <button type="button" @click="execCommand('insertOrderedList')" class="toolbar-btn" title="有序列表">
                  <span class="btn-list-ol">1.</span>
                </button>
                <span class="toolbar-separator">|</span>
                <button type="button" @click="togglePreviewMode" class="toolbar-btn" :class="{ active: previewMode }" title="预览">
                  <el-icon><View /></el-icon>
                </button>
              </div>
              <div class="editor-container">
                <div 
                  v-if="!previewMode"
                  ref="editorRef"
                  class="editor-content"
                  contenteditable="true"
                  v-html="formData.description"
                  @input="updateDescription"
                  @keyup="updateDescription"
                  @mouseup="checkCommandState"
                  @click="checkCommandState"
                  placeholder="请输入商品详情..."
                ></div>
                <div v-else class="editor-preview" v-html="formData.description"></div>
              </div>
            </div>
          </el-form-item>
          <el-form-item label="状态">
            <el-switch v-model="formData.status" :active-value="1" :inactive-value="0"></el-switch>
          </el-form-item>
          <el-form-item label="备注">
            <el-input v-model="formData.remark" type="textarea" :rows="2" placeholder="请输入备注"></el-input>
          </el-form-item>
        </el-form>
      </template>
      <template #footer>
        <el-button v-if="dialogMode === 'view'" @click="dialogVisible = false">关闭</el-button>
        <template v-else>
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="saveProduct">确定</el-button>
        </template>
      </template>
    </el-dialog>

    <el-dialog v-model="skuDialogVisible" :title="skuDialogTitle" width="1600px" class="sku-dialog" top="5vh">
      <div class="sku-management">
        <div class="sku-dimensions-section">
          <div class="section-header">
            <span class="section-title">规格维度</span>
            <el-button type="primary" size="small" @click="openAddDimensionDialog">
              <el-icon><Plus /></el-icon>
              添加维度
            </el-button>
          </div>
          <div class="dimension-tags" v-if="skuDimensions.length > 0">
            <el-collapse v-if="skuDimensions.length > 0">
              <el-collapse-item v-for="dim in skuDimensions" :key="dim.id" :title="dim.name + ' (' + dim.values.length + '个值)'" :name="dim.id">
                <div class="dimension-values-editor-inline">
                  <div v-for="(val, idx) in dim.values" :key="idx" class="value-item-inline">
                    <div class="value-number">
                      <span>{{ idx + 1 }}</span>
                    </div>
                    <el-input v-model="dim.values[idx]" placeholder="请输入值" size="large" clearable @blur="saveDimensionImmediately(dim)">
                      <template #suffix>
                        <el-icon class="value-input-icon" @click="removeDimensionValueInline(dim, idx)"><CircleClose /></el-icon>
                      </template>
                    </el-input>
                  </div>
                  <el-button type="primary" @click="addDimensionValueInline(dim)" class="add-value-btn-inline">
                    <el-icon><Plus /></el-icon>
                    添加一个值
                  </el-button>
                </div>
                <div class="dimension-actions">
                  <el-button size="small" text type="warning" @click="editDimension(dim)">编辑</el-button>
                  <el-button size="small" text type="danger" @click="deleteDimension(dim.id!)">删除维度</el-button>
                </div>
              </el-collapse-item>
            </el-collapse>
          </div>
          <el-empty v-else description="暂无规格维度，请添加" :image-size="60"></el-empty>
          <div class="generate-section" v-if="skuDimensions.length > 0">
            <el-button type="success" @click="generateSkuList">
              <el-icon><Plus /></el-icon>
              生成规格列表（笛卡尔积）
            </el-button>
            <span class="generate-hint">基于当前维度自动生成SKU列表</span>
          </div>
        </div>

        <div class="sku-list-section">
          <div class="section-header">
            <span class="section-title">SKU列表</span>
            <span class="sku-count">共 {{ skuList.length }} 个规格</span>
          </div>
          <el-table :data="skuList" border stripe :loading="skuLoading" max-height="500">
            <el-table-column label="规格组合" min-width="200">
              <template #default="scope">
                <div class="sku-attrs">
                  <el-tag v-for="(attr, idx) in scope.row.attributeValues" :key="idx" size="small" style="margin: 2px">
                    {{ attr.dimensionName }}: {{ attr.value }}
                  </el-tag>
                </div>
              </template>
            </el-table-column>
            <el-table-column label="成本价" width="120">
              <template #default="scope">
                <el-input-number
                  v-model="scope.row.costPrice"
                  :precision="2"
                  :min="0"
                  size="small"
                  controls-position="right"
                ></el-input-number>
              </template>
            </el-table-column>
            <el-table-column label="售价" width="120">
              <template #default="scope">
                <el-input-number
                  v-model="scope.row.salePrice"
                  :precision="2"
                  :min="0"
                  size="small"
                  controls-position="right"
                ></el-input-number>
              </template>
            </el-table-column>
            <el-table-column label="库存" width="100">
              <template #default="scope">
                <el-input-number
                  v-model="scope.row.stock"
                  :min="0"
                  size="small"
                  controls-position="right"
                ></el-input-number>
              </template>
            </el-table-column>
            <el-table-column label="条码" width="140">
              <template #default="scope">
                <el-input v-model="scope.row.barCode" size="small" placeholder="条码"></el-input>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="80">
              <template #default="scope">
                <el-button size="small" type="danger" @click="removeSkuItem(scope.$index)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
          <div class="sku-footer" v-if="skuList.length > 0">
            <div class="total-stock">
              <span>商品总库存：</span>
              <el-statistic :value="totalStock" title=""></el-statistic>
            </div>
            <div class="footer-actions">
              <el-button @click="skuDialogVisible = false">取消</el-button>
              <el-button type="primary" @click="saveAllSkus">保存所有规格</el-button>
            </div>
          </div>
        </div>
      </div>
    </el-dialog>

    <el-dialog v-model="dimensionDialogVisible" :title="dimensionDialogTitle" width="700px">
      <el-form :model="dimensionFormData" label-width="100px">
        <el-form-item label="维度名称" required>
          <el-input v-model="dimensionFormData.name" placeholder="如：颜色、尺寸、存储" size="large"></el-input>
        </el-form-item>
        <el-form-item label="维度值">
          <div class="dimension-values-editor">
            <div v-for="(val, idx) in dimensionFormData.values" :key="idx" class="value-item">
              <div class="value-number">
                <span>{{ idx + 1 }}</span>
              </div>
              <el-input v-model="dimensionFormData.values[idx]" placeholder="请输入值" clearable size="large">
                <template #suffix>
                  <el-icon class="value-input-icon" @click="removeDimensionFormValue(idx)"><CircleClose /></el-icon>
                </template>
              </el-input>
            </div>
            <el-button type="primary" @click="addDimensionFormValue" class="add-value-btn">
              <el-icon><Plus /></el-icon>
              添 加 一 个 值
            </el-button>
          </div>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dimensionDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="saveDimension">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, computed } from 'vue'
import { Plus, Delete, Picture, Link, Upload, View, CircleClose } from '@element-plus/icons-vue'
import { productApi, categoryApi, skuApi, skuDimensionApi } from '@/api/product'
import { supplierApi } from '@/api/supplier'
import type { Product, SkuItem, SkuDimension, SkuAttributeValue, Category } from '@/types/product'
import type { Supplier } from '@/types/supplier'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const tableData = ref<any[]>([])
const dialogVisible = ref(false)
const dialogTitle = ref('新增商品')
const dialogMode = ref<'add' | 'edit' | 'view'>('add')

const skuDialogVisible = ref(false)
const skuDialogTitle = ref('SKU管理')
const skuList = ref<SkuItem[]>([])
const skuLoading = ref(false)
const currentProductId = ref<number | null>(null)
const skuDimensions = ref<SkuDimension[]>([])

const dimensionDialogVisible = ref(false)
const dimensionDialogTitle = ref('添加维度')
const dimensionFormData = reactive({
  id: 0,
  productId: 0,
  name: '',
  values: [] as string[]
})

const totalStock = computed(() => {
  return skuList.value.reduce((sum, sku) => sum + (sku.stock || 0), 0)
})

const descriptionHtml = computed(() => {
  return formData.description || '<span style="color:#909399">暂无详情</span>'
})

const imageInputRef = ref<HTMLInputElement | null>(null)
const editorRef = ref<HTMLDivElement | null>(null)
const previewMode = ref(false)
const activeCommands = ref<Set<string>>(new Set())

const searchForm = reactive({
  keyword: '',
  categoryId: '' as number | ''
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
  categoryId: undefined as number | undefined,
  categoryName: '',
  categoryCode: '',
  supplierId: undefined as number | undefined,
  supplierName: '',
  unit: '',
  minOrderQty: 1,
  status: 1 as 0 | 1,
  image: '',
  description: '',
  remark: ''
})

const categoryOptions = ref<Category[]>([])
const supplierOptions = ref<Supplier[]>([])

const handleSearch = async () => {
  pagination.page = 1
  await loadData()
}

const resetSearch = () => {
  searchForm.keyword = ''
  searchForm.categoryId = ''
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
    const response = await productApi.list({
      page: pagination.page,
      pageSize: pagination.pageSize,
      keyword: searchForm.keyword || undefined,
      categoryId: searchForm.categoryId || undefined
    })
    if (response.code === 200) {
      const list = response.data.list || []
      for (const item of list) {
        const detailRes = await productApi.get(item.id)
        if (detailRes.code === 200 && detailRes.data.skus) {
          item.skuCount = detailRes.data.skus.length
          const prices = detailRes.data.skus.map((s: SkuItem) => s.salePrice).filter(Boolean)
          item.minPrice = prices.length ? Math.min(...prices) : undefined
          item.maxPrice = prices.length ? Math.max(...prices) : undefined
        } else {
          item.skuCount = 0
        }
      }
      tableData.value = list
      pagination.total = response.data.total || 0
    }
  } catch (error) {
    console.error('加载商品列表失败', error)
  } finally {
    loading.value = false
  }
}

const loadCategories = async () => {
  try {
    const response = await categoryApi.getAll()
    if (response.code === 200) {
      categoryOptions.value = response.data
    }
  } catch (error) {
    console.error('加载分类失败', error)
  }
}

const loadSuppliers = async () => {
  try {
    const response = await supplierApi.getAll()
    if (response.code === 200) {
      supplierOptions.value = response.data
    }
  } catch (error) {
    console.error('加载供应商失败', error)
  }
}

const openAddDialog = () => {
  dialogMode.value = 'add'
  previewMode.value = false
  dialogTitle.value = '新增商品'
  Object.assign(formData, {
    id: 0,
    code: '',
    name: '',
    categoryId: undefined,
    categoryName: '',
    categoryCode: '',
    supplierId: undefined,
    supplierName: '',
    unit: '',
    minOrderQty: 1,
    status: 1,
    image: '',
    description: '',
    remark: ''
  })
  dialogVisible.value = true
}

const openEditDialog = async (row: Product) => {
  dialogMode.value = 'edit'
  previewMode.value = false
  dialogTitle.value = '编辑商品'
  try {
    const response = await productApi.get(row.id)
    if (response.code === 200) {
      Object.assign(formData, {
        id: response.data.id,
        code: response.data.code || '',
        name: response.data.name || '',
        categoryId: response.data.categoryId,
        categoryName: response.data.categoryName || '',
        categoryCode: response.data.categoryCode || '',
        supplierId: response.data.supplierId,
        supplierName: response.data.supplierName || '',
        unit: response.data.unit || '',
        minOrderQty: response.data.minOrderQty || 1,
        status: response.data.status,
        image: response.data.image || '',
        description: response.data.description || '',
        remark: response.data.remark || ''
      })
    }
  } catch (error) {
    console.error('获取商品详情失败', error)
  }
  dialogVisible.value = true
}

const viewProduct = async (row: Product) => {
  dialogMode.value = 'view'
  previewMode.value = true
  dialogTitle.value = '商品详情'
  try {
    const response = await productApi.get(row.id)
    if (response.code === 200) {
      Object.assign(formData, {
        id: response.data.id,
        code: response.data.code || '',
        name: response.data.name || '',
        categoryId: response.data.categoryId,
        categoryName: response.data.categoryName || '',
        categoryCode: response.data.categoryCode || '',
        supplierId: response.data.supplierId,
        supplierName: response.data.supplierName || '',
        unit: response.data.unit || '',
        minOrderQty: response.data.minOrderQty || 1,
        status: response.data.status,
        image: response.data.image || '',
        description: response.data.description || '',
        remark: response.data.remark || ''
      })
      skuList.value = response.data.skus || []
    }
  } catch (error) {
    console.error('获取商品详情失败', error)
  }
  dialogVisible.value = true
}

const triggerImageUpload = () => {
  imageInputRef.value?.click()
}

const handleImageUpload = (event: Event) => {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]
  if (file) {
    const reader = new FileReader()
    reader.onload = (e) => {
      formData.image = e.target?.result as string
    }
    reader.readAsDataURL(file)
  }
}

const execCommand = (command: string, value?: string) => {
  document.execCommand(command, false, value || null)
  if (editorRef.value) {
    editorRef.value.focus()
  }
  checkCommandState()
}

const isCommandActive = (command: string) => {
  return activeCommands.value.has(command)
}

const checkCommandState = () => {
  const commands = ['bold', 'italic', 'underline']
  const newActive = new Set<string>()
  commands.forEach(cmd => {
    if (document.queryCommandState(cmd)) {
      newActive.add(cmd)
    }
  })
  activeCommands.value = newActive
}

const updateDescription = () => {
  if (editorRef.value) {
    formData.description = editorRef.value.innerHTML
  }
}

const togglePreviewMode = () => {
  previewMode.value = !previewMode.value
}

const handleSupplierChange = (supplierId: number) => {
  const supplier = supplierOptions.value.find(s => s.id === supplierId)
  if (supplier) {
    formData.supplierName = supplier.name
  }
}

const saveProduct = async () => {
  if (!formData.name) {
    ElMessage.warning('请输入商品名称')
    return
  }
  try {
    const data = {
      name: formData.name,
      categoryId: formData.categoryId,
      supplierId: formData.supplierId,
      supplierName: formData.supplierName,
      unit: formData.unit,
      minOrderQty: formData.minOrderQty,
      status: formData.status,
      image: formData.image,
      description: formData.description,
      remark: formData.remark
    }
    if (formData.id) {
      await productApi.update({ ...data, id: formData.id })
      ElMessage.success('更新成功')
    } else {
      await productApi.create(data)
      ElMessage.success('创建成功')
    }
    dialogVisible.value = false
    await loadData()
  } catch (error) {
    console.error('保存商品失败', error)
    ElMessage.error('保存失败')
  }
}

const deleteProduct = async (id: number) => {
  try {
    await ElMessageBox.confirm('确定要删除该商品吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await productApi.delete(id)
    ElMessage.success('删除成功')
    await loadData()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除商品失败', error)
      ElMessage.error('删除失败')
    }
  }
}

const openSkuDialog = async (row: Product) => {
  currentProductId.value = row.id
  skuDialogTitle.value = `SKU管理 - ${row.name}`
  skuDialogVisible.value = true
  skuList.value = []
  await Promise.all([loadSkus(row.id), loadDimensions(row.id)])
}

const loadSkus = async (productId: number) => {
  skuLoading.value = true
  try {
    const response = await skuApi.list(productId)
    if (response.code === 200) {
      skuList.value = response.data.list || []
    }
  } catch (error) {
    console.error('加载SKU列表失败', error)
  } finally {
    skuLoading.value = false
  }
}

const loadDimensions = async (productId: number) => {
  try {
    const response = await skuDimensionApi.list(productId)
    if (response.code === 200) {
      skuDimensions.value = response.data || []
    }
  } catch (error) {
    console.error('加载维度失败', error)
  }
}

const openAddDimensionDialog = () => {
  dimensionDialogTitle.value = '添加维度'
  Object.assign(dimensionFormData, {
    id: 0,
    productId: currentProductId.value || 0,
    name: '',
    values: ['']
  })
  dimensionDialogVisible.value = true
}

const editDimension = (dim: SkuDimension) => {
  dimensionDialogTitle.value = '编辑维度'
  Object.assign(dimensionFormData, {
    id: dim.id,
    productId: dim.productId,
    name: dim.name,
    values: [...dim.values]
  })
  dimensionDialogVisible.value = true
}

const saveDimension = async () => {
  if (!dimensionFormData.name) {
    ElMessage.warning('请输入维度名称')
    return
  }
  const validValues = dimensionFormData.values.filter(v => v.trim())
  if (validValues.length === 0) {
    ElMessage.warning('请至少添加一个维度值')
    return
  }
  try {
    const data = {
      productId: dimensionFormData.productId,
      name: dimensionFormData.name,
      values: validValues
    }
    if (dimensionFormData.id) {
      await skuDimensionApi.update({ ...data, id: dimensionFormData.id })
      ElMessage.success('更新成功')
    } else {
      await skuDimensionApi.create(data)
      ElMessage.success('创建成功')
    }
    dimensionDialogVisible.value = false
    if (currentProductId.value) {
      await loadDimensions(currentProductId.value)
    }
  } catch (error) {
    console.error('保存维度失败', error)
    ElMessage.error('保存失败')
  }
}

const deleteDimension = async (id: number) => {
  try {
    await ElMessageBox.confirm('确定要删除该维度吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await skuDimensionApi.delete(id)
    ElMessage.success('删除成功')
    if (currentProductId.value) {
      await loadDimensions(currentProductId.value)
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除维度失败', error)
      ElMessage.error('删除失败')
    }
  }
}

const addDimensionValue = (dim: SkuDimension) => {
  const newValue = prompt('请输入新的值')
  if (newValue && newValue.trim()) {
    dim.values.push(newValue.trim())
    skuDimensionApi.update({ id: dim.id!, productId: dim.productId, name: dim.name, values: dim.values })
  }
}

const removeDimensionValue = async (dim: SkuDimension, index: number) => {
  dim.values.splice(index, 1)
  await skuDimensionApi.update({ id: dim.id!, productId: dim.productId, name: dim.name, values: dim.values })
}

const addDimensionValueInline = (dim: SkuDimension) => {
  dim.values.push('')
}

const removeDimensionValueInline = async (dim: SkuDimension, index: number) => {
  dim.values.splice(index, 1)
  await skuDimensionApi.update({ id: dim.id!, productId: dim.productId, name: dim.name, values: dim.values })
}

const saveDimensionImmediately = async (dim: SkuDimension) => {
  await skuDimensionApi.update({ id: dim.id!, productId: dim.productId, name: dim.name, values: dim.values })
}

const addDimensionFormValue = () => {
  dimensionFormData.values.push('')
}

const removeDimensionFormValue = (index: number) => {
  dimensionFormData.values.splice(index, 1)
}

const generateSkuList = () => {
  if (skuDimensions.value.length === 0) {
    ElMessage.warning('请先添加规格维度')
    return
  }
  const dimensionsWithValues = skuDimensions.value.filter(d => d.values.length > 0)
  if (dimensionsWithValues.length === 0) {
    ElMessage.warning('所有维度都没有值，请先添加维度值')
    return
  }
  const cartesianProduct = computeCartesianProduct(dimensionsWithValues)
  const existingSkus = new Map(
    skuList.value.map(sku => [generateSkuKey(sku.attributeValues), sku])
  )
  const newSkus: SkuItem[] = cartesianProduct.map((combination, index) => {
    const key = generateSkuKey(combination)
    const existing = existingSkus.get(key)
    if (existing) {
      return existing
    }
    return {
      id: 0,
      productId: currentProductId.value || 0,
      skuCode: `SKU-${currentProductId.value}-${String(index + 1).padStart(4, '0')}`,
      skuName: combination.map(c => c.value).join('-'),
      attributeValues: combination,
      costPrice: 0,
      salePrice: 0,
      stock: 0,
      minStock: 0,
      status: 1 as 0 | 1,
      barCode: '',
      weight: 0,
      volume: 0
    }
  })
  skuList.value = newSkus
  ElMessage.success(`已生成 ${newSkus.length} 个规格`)
}

const computeCartesianProduct = (dimensions: SkuDimension[]): SkuAttributeValue[][] => {
  if (dimensions.length === 0) return []
  const result: SkuAttributeValue[][] = [[]]
  for (const dim of dimensions) {
    const newResult: SkuAttributeValue[][] = []
    for (const combo of result) {
      for (const value of dim.values) {
        newResult.push([...combo, { dimensionName: dim.name, value }])
      }
    }
    result.length = 0
    result.push(...newResult)
  }
  return result
}

const generateSkuKey = (attributeValues: SkuAttributeValue[]): string => {
  return attributeValues.map(a => `${a.dimensionName}:${a.value}`).sort().join('|')
}

const removeSkuItem = (index: number) => {
  skuList.value.splice(index, 1)
}

const saveAllSkus = async () => {
  if (skuList.value.length === 0) {
    ElMessage.warning('没有可保存的规格')
    return
  }
  try {
    if (currentProductId.value) {
      await skuApi.batchDeleteByProductId(currentProductId.value)
    }
    for (const sku of skuList.value) {
      delete sku.id
      await skuApi.create(sku)
    }
    ElMessage.success('保存成功')
    skuDialogVisible.value = false
  } catch (error) {
    console.error('保存SKU失败', error)
    ElMessage.error('保存失败')
  }
}

onMounted(() => {
  loadCategories()
  loadSuppliers()
  loadData()
})
</script>

<style lang="scss" scoped>
.product-list {
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
}

.no-image {
  color: #999;
  font-size: 12px;
}

.product-image-item {
  .image-input-wrapper {
    display: flex;
    gap: 20px;
    align-items: flex-start;
  }

  .image-preview-box {
    width: 140px;
    height: 140px;
    border: 2px dashed #dcdfe6;
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    overflow: hidden;
    flex-shrink: 0;
    cursor: pointer;
    transition: all 0.2s;
    position: relative;

    &:hover {
      border-color: #409eff;
      background: #ecf5ff;
    }

    .preview-image {
      width: 100%;
      height: 100%;
      border-radius: 4px;
    }

    .preview-placeholder {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 8px;
      color: #909399;

      .placeholder-icon {
        font-size: 32px;
      }

      span {
        font-size: 12px;
      }
    }

    .preview-overlay {
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: rgba(0, 0, 0, 0.5);
      display: flex;
      align-items: center;
      justify-content: center;
      opacity: 0;
      transition: opacity 0.2s;
      color: white;
      font-size: 28px;

      &:hover {
        opacity: 1;
      }
    }

    &:hover .preview-overlay {
      opacity: 1;
    }
  }

  .image-input-section {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 8px;

    .input-hint {
      font-size: 12px;
      color: #909399;
    }
  }
}

.rich-editor-wrapper {
  border: 1px solid #dcdfe6;
  border-radius: 8px;
  overflow: hidden;

  .editor-toolbar {
    display: flex;
    align-items: center;
    gap: 4px;
    padding: 10px;
    background: #f5f7fa;
    border-bottom: 1px solid #e4e7ed;

    .toolbar-btn {
      padding: 6px 10px;
      border: none;
      background: transparent;
      cursor: pointer;
      border-radius: 4px;
      transition: all 0.2s;
      font-size: 14px;
      font-weight: 600;
      color: #606266;

      &:hover {
        background: #e4e7ed;
        color: #409eff;
      }

      &.active {
        background: #409eff;
        color: white;
      }

      .btn-bold {
        font-weight: bold;
      }
      .btn-italic {
        font-style: italic;
      }
      .btn-underline {
        text-decoration: underline;
      }
    }

    .toolbar-separator {
      width: 1px;
      height: 20px;
      background: #dcdfe6;
      margin: 0 4px;
    }
  }

  .editor-container {
    min-height: 250px;
    max-height: 400px;
    overflow-y: auto;

    .editor-content {
      padding: 16px;
      min-height: 250px;
      outline: none;

      &:empty:before {
        content: attr(placeholder);
        color: #909399;
        pointer-events: none;
      }

      :deep(img) {
        max-width: 100%;
        height: auto;
      }

      :deep(ul) {
        padding-left: 20px;
      }

      :deep(ol) {
        padding-left: 20px;
      }
    }

    .editor-preview {
      padding: 16px;
      min-height: 250px;
      background: #f9fafc;

      :deep(img) {
        max-width: 100%;
        height: auto;
      }

      :deep(h1) {
        font-size: 24px;
        font-weight: bold;
        margin-bottom: 12px;
      }

      :deep(h2) {
        font-size: 20px;
        font-weight: bold;
        margin-bottom: 10px;
      }

      :deep(p) {
        margin-bottom: 8px;
      }

      :deep(ul) {
        padding-left: 20px;
        list-style-type: disc;
        margin-bottom: 8px;
      }

      :deep(ol) {
        padding-left: 20px;
        list-style-type: decimal;
        margin-bottom: 8px;
      }
    }
  }
}

.dimension-values-editor {
  display: flex;
  flex-direction: column;
  gap: 12px;

  .value-item {
    display: flex;
    align-items: center;
    gap: 10px;

    .value-number {
      width: 36px;
      height: 36px;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      border-radius: 8px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: bold;
      font-size: 14px;
      flex-shrink: 0;
    }

    .value-input-icon {
      cursor: pointer;
      color: #909399;
      transition: all 0.2s;

      &:hover {
        color: #f56c6c;
      }
    }
  }

  .add-value-btn {
    width: 100%;
    margin-top: 4px;
    padding: 12px;
    font-size: 14px;
    border-radius: 8px;
    border: 2px dashed #409eff;
    background: #ecf5ff;
    color: #409eff;

    &:hover {
      background: #409eff;
      color: white;
    }
  }
}

.dimension-values-editor-inline {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-bottom: 12px;

  .value-item-inline {
    display: flex;
    align-items: center;
    gap: 8px;

    .value-number {
      width: 32px;
      height: 32px;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      border-radius: 6px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: bold;
      font-size: 13px;
      flex-shrink: 0;
    }

    .value-input-icon {
      cursor: pointer;
      color: #909399;
      transition: all 0.2s;

      &:hover {
        color: #f56c6c;
      }
    }
  }

  .add-value-btn-inline {
    width: 100%;
    margin-top: 2px;
    padding: 10px;
    font-size: 13px;
    border-radius: 6px;
    border: 2px dashed #409eff;
    background: #ecf5ff;
    color: #409eff;

    &:hover {
      background: #409eff;
      color: white;
    }
  }
}

.sku-management {
  display: flex;
  gap: 24px;
  min-height: 600px;

  .sku-dimensions-section {
    width: 400px;
    flex-shrink: 0;
    border-right: 1px solid #eee;
    padding-right: 24px;

    .section-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 15px;

      .section-title {
        font-weight: 600;
        color: #303133;
      }
    }

    .dimension-tags {
      margin-bottom: 15px;
    }

    .dimension-content {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
      padding: 10px 0;
    }

    .dimension-actions {
      display: flex;
      gap: 10px;
      margin-top: 10px;
    }

    .generate-section {
      margin-top: 20px;
      padding-top: 15px;
      border-top: 1px dashed #ddd;

      .generate-hint {
        display: block;
        margin-top: 8px;
        font-size: 12px;
        color: #999;
      }
    }
  }

  .sku-list-section {
    flex: 1;
    min-width: 0;

    .section-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 15px;

      .section-title {
        font-weight: 600;
        color: #303133;
      }

      .sku-count {
        font-size: 12px;
        color: #909399;
      }
    }

    .sku-attrs {
      display: flex;
      flex-wrap: wrap;
      gap: 4px;
    }

    .sku-footer {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-top: 15px;
      padding-top: 15px;
      border-top: 1px solid #eee;

      .total-stock {
        display: flex;
        align-items: center;
        gap: 10px;
        font-weight: 600;
        color: #303133;
      }

      .footer-actions {
        display: flex;
        gap: 10px;
      }
    }
  }
}

.dimension-values-editor {
  width: 100%;

  .value-item {
    display: flex;
    align-items: center;
    gap: 10px;
    margin-bottom: 12px;

    .value-index {
      width: 32px;
      height: 32px;
      display: flex;
      align-items: center;
      justify-content: center;
      background: #f0f2f5;
      border-radius: 4px;
      font-weight: 600;
      color: #606266;
      flex-shrink: 0;
    }

    .el-input {
      flex: 1;
    }
  }

  .add-value-btn {
    width: 100%;
    margin-top: 8px;
  }
}

:deep(.el-collapse-item__header) {
  font-weight: 600;
}

:deep(.el-input-number) {
  width: 100%;
}

:deep(.sku-dialog) {
  .el-dialog__body {
    padding: 20px 24px;
  }
}
</style>
