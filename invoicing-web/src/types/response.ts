export interface Result<T = any> {
  code: number
  message: string
  data: T
  timestamp?: number
}

export interface PageResult<T = any> {
  list: T[]
  total: number
  page: number
  pageSize: number
}

export interface PageQuery {
  page?: number
  pageSize?: number
  [key: string]: any
}
