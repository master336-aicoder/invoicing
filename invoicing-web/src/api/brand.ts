import request from '@/utils/request'
import type { Brand, BrandQuery } from '@/types/brand'
import type { Result, PageResult, PageQuery } from '@/types/response'

export const brandApi = {
  list(params: BrandQuery & PageQuery) {
    return request.get<Result<PageResult<Brand>>>('/product/brands', { params })
  },

  getAll() {
    return request.get<Result<Brand[]>>('/product/brands/all')
  },

  get(id: number) {
    return request.get<Result<Brand>>(`/product/brands/${id}`)
  },

  create(data: Partial<Brand>) {
    return request.post<Result<Brand>>('/product/brands', data)
  },

  update(data: Partial<Brand>) {
    return request.put<Result<Brand>>(`/product/brands/${data.id}`, data)
  },

  delete(id: number) {
    return request.delete<Result<void>>(`/product/brands/${id}`)
  },

  batchDelete(ids: number[]) {
    return request.delete<Result<void>>('/product/brands/batch', { data: { ids } })
  }
}
