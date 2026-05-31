import request from '@/utils/request'
import type { UserInfo, LoginParams } from '@/types/user'
import type { Result } from '@/types/response'

export const userApi = {
  login(params: LoginParams) {
    return request.post<Result<{ accessToken: string; refreshToken: string; expiresIn: number }>>('/auth/login', params)
  },

  getUserInfo() {
    return request.get<Result<UserInfo>>('/auth/user/info')
  },

  getPermissions() {
    return request.get<Result<string[]>>('/auth/permissions')
  },

  logout() {
    return request.post('/auth/logout')
  }
}
