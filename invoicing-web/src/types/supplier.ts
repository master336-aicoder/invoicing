export interface Supplier {
  id: number
  tenantId?: number
  code: string
  name: string
  contactPerson?: string
  contactPhone?: string
  email?: string
  address?: string
  status: 0 | 1
  remark?: string
  createTime?: string
  updateTime?: string
}

export interface SupplierQuery {
  keyword?: string
  status?: number
}
