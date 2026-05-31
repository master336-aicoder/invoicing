<script setup lang="ts">
import { onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import { usePermissionStore } from '@/stores/permission'

const userStore = useUserStore()
const permissionStore = usePermissionStore()

onMounted(async () => {
  if (userStore.token) {
    await permissionStore.fetchPermissions()
  }
})
</script>

<template>
  <router-view />
</template>

<style>
#app {
  width: 100%;
  height: 100%;
}
</style>
