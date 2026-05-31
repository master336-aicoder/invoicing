import request from '@/utils/request'
import type { Supplier, SupplierQuery } from '@/types/supplier'
import type { Result, PageResult, PageQuery } from '@/types/response'

export const supplierApi = {
  list(params: SupplierQuery & PageQuery) {
    return request.get<Result<PageResult<Supplier>>>('/supplier/suppliers', { params })
  },

  getAll() {
    return request.get<Result<Supplier[]>>('/supplier/suppliers/all')
  },

  get(id: number) {
    return request.get<Result<Supplier>>(`/supplier/suppliers/${id}`)
  },

  create(data: Partial<Supplier>) {
    return request.post<Result<Supplier>>('/supplier/suppliers', data)
  },

  update(data: Partial<Supplier>) {
    return request.put<Result<Supplier>>(`/supplier/suppliers/${data.id}`, data)
  },

  delete(id: number) {
    return request.delete<Result<void>>(`/supplier/suppliers/${id}`)
  },

  batchDelete(ids: number[]) {
    return request.delete<Result<void>>('/supplier/suppliers/batch', { data: { ids } })
  }
}
