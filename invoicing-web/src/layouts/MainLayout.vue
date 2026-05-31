<template>
  <div class="main-layout">
    <div class="layout-header">
      <div class="header-left">
        <el-icon class="collapse-btn" @click="toggleSidebar">
          <Fold v-if="!sidebarCollapsed" />
          <Expand v-else />
        </el-icon>
        <span class="logo-text">商用进销存系统</span>
      </div>
      <div class="header-right">
        <el-dropdown @command="handleCommand">
          <span class="user-info">
            <el-avatar :size="32" :src="userStore.userInfo?.avatar">
              {{ userStore.userInfo?.nickname?.charAt(0) || 'U' }}
            </el-avatar>
            <span class="username">{{ userStore.userInfo?.nickname || '用户' }}</span>
          </span>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item command="profile">个人中心</el-dropdown-item>
              <el-dropdown-item command="settings">系统设置</el-dropdown-item>
              <el-dropdown-item divided command="logout">退出登录</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </div>
    <div class="layout-body">
      <aside class="layout-sidebar" :class="{ collapsed: sidebarCollapsed }">
        <el-menu
          :default-active="activeMenu"
          :collapse="sidebarCollapsed"
          :router="true"
          background-color="#304156"
          text-color="#bfcbd9"
          active-text-color="#409eff"
        >
          <template v-for="route in menuRoutes" :key="route.path">
            <el-sub-menu v-if="route.children?.length" :index="route.path">
              <template #title>
                <el-icon><component :is="route.meta?.icon || 'Folder'" /></el-icon>
                <span>{{ route.meta?.title }}</span>
              </template>
              <el-menu-item
                v-for="child in route.children"
                :key="child.path"
                :index="resolvePath(route.path, child.path)"
              >
                {{ child.meta?.title }}
              </el-menu-item>
            </el-sub-menu>
            <el-menu-item v-else :index="route.path">
              <el-icon><component :is="route.meta?.icon || 'Folder'" /></el-icon>
              <span>{{ route.meta?.title }}</span>
            </el-menu-item>
          </template>
        </el-menu>
      </aside>
      <main class="layout-main">
        <router-view v-slot="{ Component }">
          <transition name="fade" mode="out-in">
            <component :is="Component" />
          </transition>
        </router-view>
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Fold, Expand } from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'
import { ElMessageBox } from 'element-plus'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const sidebarCollapsed = ref(false)
const activeMenu = computed(() => route.path)

const menuRoutes = computed(() => {
  const mainRoute = router.getRoutes().find(r => r.path === '/')
  return mainRoute?.children?.filter(r => r.meta?.title) || []
})

function resolvePath(parentPath: string, childPath: string) {
  return `/${parentPath}/${childPath}`
}

function toggleSidebar() {
  sidebarCollapsed.value = !sidebarCollapsed.value
}

function handleCommand(command: string) {
  if (command === 'logout') {
    ElMessageBox.confirm('确定要退出登录吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }).then(() => {
      userStore.logout()
      router.push('/login')
    })
  }
}
</script>

<style lang="scss" scoped>
.main-layout {
  width: 100%;
  height: 100vh;
  display: flex;
  flex-direction: column;
}

.layout-header {
  height: 60px;
  background: #fff;
  border-bottom: 1px solid #e6e6e6;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 20px;

  .header-left {
    display: flex;
    align-items: center;
    gap: 16px;

    .collapse-btn {
      font-size: 20px;
      cursor: pointer;
      color: #606266;

      &:hover {
        color: #409eff;
      }
    }

    .logo-text {
      font-size: 18px;
      font-weight: 600;
      color: #303133;
    }
  }

  .header-right {
    .user-info {
      display: flex;
      align-items: center;
      gap: 8px;
      cursor: pointer;

      .username {
        color: #303133;
      }
    }
  }
}

.layout-body {
  flex: 1;
  display: flex;
  overflow: hidden;
}

.layout-sidebar {
  width: 200px;
  background: #304156;
  transition: width 0.3s;
  overflow-x: hidden;
  overflow-y: auto;

  &.collapsed {
    width: 64px;
  }

  :deep(.el-menu) {
    border-right: none;
    height: 100%;
  }
}

.layout-main {
  flex: 1;
  overflow-y: auto;
  background: #f5f7fa;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
