export interface Product {
  id: number
  tenantId?: number
  code: string
  name: string
  categoryId?: number
  categoryName?: string
  categoryCode?: string
  supplierId?: number
  supplierName?: string
  unit?: string
  minOrderQty?: number
  status: 0 | 1
  image?: string
  description?: string
  remark?: string
  createTime?: string
  updateTime?: string
  skus?: SkuItem[]
}

export interface SkuDimension {
  id?: number
  productId: number
  name: string
  values: string[]
}

export interface SkuAttributeValue {
  dimensionName: string
  value: string
}

export interface SkuItem {
  id: number
  productId: number
  skuCode: string
  skuName: string
  attributeValues: SkuAttributeValue[]
  costPrice: number
  salePrice: number
  stock: number
  minStock?: number
  maxStock?: number
  status: 0 | 1
  image?: string
  barCode?: string
  weight?: number
  volume?: number
  createTime?: string
  updateTime?: string
}

export interface ProductQuery {
  keyword?: string
  categoryId?: number
  category?: string
  status?: number
  startDate?: string
  endDate?: string
}

export interface Category {
  id: number
  tenantId: number
  code: string
  name: string
  parentId: number
  level: number
  sortOrder: number
  status: number
  remark?: string
  creator?: number
  createTime?: string
  updater?: number
  updateTime?: string
  deleted?: number
}

export interface CategoryQuery {
  keyword?: string
  status?: number
}
