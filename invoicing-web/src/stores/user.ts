import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { LoginParams, UserInfo } from '@/types/user'
import { userApi } from '@/api/user'

export const useUserStore = defineStore('user', () => {
  const token = ref<string>(localStorage.getItem('token') || '')
  const userInfo = ref<UserInfo | null>(null)

  const isLoggedIn = computed(() => !!token.value)

  async function login(params: LoginParams) {
    const res = await userApi.login(params)
    token.value = res.data.accessToken
    localStorage.setItem('token', res.data.accessToken)
    await fetchUserInfo()
    return res
  }

  async function fetchUserInfo() {
    if (!token.value) return
    try {
      const res = await userApi.getUserInfo()
      userInfo.value = res.data
    } catch {
      logout()
    }
  }

  function logout() {
    token.value = ''
    userInfo.value = null
    localStorage.removeItem('token')
  }

  return {
    token,
    userInfo,
    isLoggedIn,
    login,
    fetchUserInfo,
    logout
  }
})
