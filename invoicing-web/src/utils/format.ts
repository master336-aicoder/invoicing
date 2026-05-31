import dayjs from 'dayjs'

export function formatDate(date: string | Date, format = 'YYYY-MM-DD') {
  return dayjs(date).format(format)
}

export function formatDateTime(date: string | Date, format = 'YYYY-MM-DD HH:mm:ss') {
  return dayjs(date).format(format)
}

export function formatMoney(amount: number | string, decimals = 2) {
  const num = typeof amount === 'string' ? parseFloat(amount) : amount
  if (isNaN(num)) return '0.00'
  return num.toFixed(decimals)
}

export function formatNumber(num: number | string, decimals = 0) {
  const n = typeof num === 'string' ? parseFloat(num) : num
  if (isNaN(n)) return '0'
  return n.toFixed(decimals)
}

export function formatPercent(value: number | string, decimals = 2) {
  const num = typeof value === 'string' ? parseFloat(value) : value
  if (isNaN(num)) return '0%'
  return `${(num * 100).toFixed(decimals)}%`
}

export function formatFileSize(bytes: number): string {
  if (bytes === 0) return '0 B'
  const k = 1024
  const sizes = ['B', 'KB', 'MB', 'GB', 'TB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return `${(bytes / Math.pow(k, i)).toFixed(2)} ${sizes[i]}`
}

export function formatDuration(seconds: number): string {
  const h = Math.floor(seconds / 3600)
  const m = Math.floor((seconds % 3600) / 60)
  const s = seconds % 60
  if (h > 0) {
    return `${h}小时${m}分钟`
  }
  if (m > 0) {
    return `${m}分钟${s}秒`
  }
  return `${s}秒`
}
