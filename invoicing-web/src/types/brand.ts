export interface Brand {
  id: number
  tenantId?: number
  code: string
  name: string
  logo?: string
  description?: string
  status: 0 | 1
  sortOrder?: number
  remark?: string
  createTime?: string
  updateTime?: string
}

export interface BrandQuery {
  keyword?: string
  status?: number
}
