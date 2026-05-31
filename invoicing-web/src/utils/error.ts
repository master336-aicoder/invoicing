import { ElMessage } from 'element-plus'

export function globalErrorHandler(err: unknown, instance: unknown, info: string) {
  console.error('Global error:', err)
  console.error('Component:', instance)
  console.error('Info:', info)

  if (err instanceof Error) {
    ElMessage.error(err.message || '发生了一个错误')
  } else {
    ElMessage.error('发生了一个未知错误')
  }
}

export function formatError(err: unknown): string {
  if (err instanceof Error) {
    return err.message
  }
  return String(err)
}
