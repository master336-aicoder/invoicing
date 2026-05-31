import request from '@/utils/request'
import type { Product, ProductQuery, SkuItem, SkuDimension, Category, CategoryQuery } from '@/types/product'
import type { Result, PageResult, PageQuery } from '@/types/response'

export const productApi = {
  list(params: ProductQuery & PageQuery) {
    return request.get<Result<PageResult<Product>>>('/product/products', { params })
  },

  get(id: number) {
    return request.get<Result<Product & { skus?: SkuItem[] }>>(`/product/products/${id}`)
  },

  create(data: Partial<Product>) {
    return request.post<Result<Product>>('/product/products', data)
  },

  update(data: Partial<Product>) {
    return request.put<Result<Product>>(`/product/products/${data.id}`, data)
  },

  delete(id: number) {
    return request.delete<Result<void>>(`/product/products/${id}`)
  },

  batchDelete(ids: number[]) {
    return request.delete<Result<void>>('/product/products/batch', { data: { ids } })
  },

  updateStatus(id: number, status: number) {
    return request.patch<Result<void>>(`/product/products/${id}/status`, { status })
  }
}

export const skuApi = {
  list(productId?: number) {
    return request.get<Result<{ list: SkuItem[]; total: number }>>('/product/skus', {
      params: productId ? { productId } : {}
    })
  },

  get(id: number) {
    return request.get<Result<SkuItem>>(`/product/skus/${id}`)
  },

  create(data: Partial<SkuItem>) {
    return request.post<Result<SkuItem>>('/product/skus', data)
  },

  update(data: Partial<SkuItem>) {
    return request.put<Result<SkuItem>>(`/product/skus/${data.id}`, data)
  },

  delete(id: number) {
    return request.delete<Result<void>>(`/product/skus/${id}`)
  },

  batchDelete(ids: number[]) {
    return request.delete<Result<void>>('/product/skus/batch', { data: { ids } })
  },

  batchDeleteByProductId(productId: number) {
    return request.delete<Result<{ deletedCount: number }>>('/product/skus/batch-delete', {
      params: { productId }
    })
  }
}

export const skuDimensionApi = {
  list(productId: number) {
    return request.get<Result<SkuDimension[]>>('/product/sku-dimensions', {
      params: { productId }
    })
  },

  create(data: Partial<SkuDimension>) {
    return request.post<Result<SkuDimension>>('/product/sku-dimensions', data)
  },

  update(data: Partial<SkuDimension>) {
    return request.put<Result<SkuDimension>>(`/product/sku-dimensions/${data.id}`, data)
  },

  delete(id: number) {
    return request.delete<Result<void>>(`/product/sku-dimensions/${id}`)
  }
}

export const categoryApi = {
  list(params: CategoryQuery & PageQuery) {
    return request.get<Result<PageResult<Category>>>('/product/categories', { params })
  },

  getAll() {
    return request.get<Result<Category[]>>('/product/categories/all')
  },

  get(id: number) {
    return request.get<Result<Category>>(`/product/categories/${id}`)
  },

  create(data: Partial<Category>) {
    return request.post<Result<Category>>('/product/categories', data)
  },

  update(data: Partial<Category>) {
    return request.put<Result<Category>>(`/product/categories/${data.id}`, data)
  },

  delete(id: number) {
    return request.delete<Result<void>>(`/product/categories/${id}`)
  }
}
