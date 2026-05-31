import { defineStore } from 'pinia'
import { ref } from 'vue'
import type { RouteRecordRaw } from 'vue-router'
import { userApi } from '@/api/user'

export const usePermissionStore = defineStore('permission', () => {
  const routes = ref<RouteRecordRaw[]>([])
  const permissions = ref<string[]>([])

  async function fetchPermissions() {
    const res = await userApi.getPermissions()
    permissions.value = res.data
    return res.data
  }

  function setRoutes(newRoutes: RouteRecordRaw[]) {
    routes.value = newRoutes
  }

  function hasPermission(permission: string): boolean {
    return permissions.value.includes(permission)
  }

  return {
    routes,
    permissions,
    fetchPermissions,
    setRoutes,
    hasPermission
  }
})
