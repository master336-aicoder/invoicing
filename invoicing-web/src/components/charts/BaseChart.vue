<template>
  <div ref="chartRef" :style="{ width, height }"></div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted, watch, computed } from 'vue'
import * as echarts from 'echarts'

interface Props {
  option: echarts.EChartsOption
  width?: string
  height?: string
  autoresize?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  width: '100%',
  height: '400px',
  autoresize: true
})

const chartRef = ref<HTMLElement>()
let chartInstance: echarts.ECharts | null = null

const chartStyle = computed(() => ({
  width: props.width,
  height: props.height
}))

function initChart() {
  if (!chartRef.value) return
  chartInstance = echarts.init(chartRef.value)
  chartInstance.setOption(props.option)
}

function handleResize() {
  chartInstance?.resize()
}

onMounted(() => {
  initChart()
  if (props.autoresize) {
    window.addEventListener('resize', handleResize)
  }
})

onUnmounted(() => {
  if (props.autoresize) {
    window.removeEventListener('resize', handleResize)
  }
  chartInstance?.dispose()
})

watch(() => props.option, (newOption) => {
  chartInstance?.setOption(newOption, true)
}, { deep: true })

defineExpose({
  getChartInstance: () => chartInstance
})
</script>
