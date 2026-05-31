<template>
  <BaseChart :option="chartOption" :height="height" />
</template>

<script setup lang="ts">
import { computed } from 'vue'
import BaseChart from './BaseChart.vue'

interface SeriesItem {
  name: string
  data: number[]
  color?: string
}

interface Props {
  title?: string
  xData: string[]
  seriesData: SeriesItem[]
  height?: string
}

const props = withDefaults(defineProps<Props>(), {
  title: '',
  height: '350px'
})

const chartOption = computed(() => ({
  title: {
    text: props.title,
    left: 'center',
    textStyle: {
      fontSize: 16,
      fontWeight: 'bold',
      color: '#303133'
    }
  },
  tooltip: {
    trigger: 'axis',
    axisPointer: {
      type: 'shadow'
    }
  },
  legend: {
    data: props.seriesData.map(s => s.name),
    bottom: 0
  },
  grid: {
    left: '3%',
    right: '4%',
    bottom: '15%',
    top: '15%',
    containLabel: true
  },
  xAxis: {
    type: 'category',
    data: props.xData,
    axisLine: {
      lineStyle: {
        color: '#dcdfe6'
      }
    },
    axisLabel: {
      rotate: 30,
      color: '#606266'
    }
  },
  yAxis: {
    type: 'value',
    axisLine: {
      show: false
    },
    axisTick: {
      show: false
    },
    splitLine: {
      lineStyle: {
        color: '#f0f0f0',
        type: 'dashed'
      }
    }
  },
  series: props.seriesData.map(item => ({
    name: item.name,
    type: 'bar',
    data: item.data,
    itemStyle: {
      color: item.color || getBarColor(item.name),
      borderRadius: [4, 4, 0, 0]
    },
    emphasis: {
      itemStyle: {
        shadowBlur: 10,
        shadowColor: 'rgba(0,0,0,0.3)'
      }
    }
  }))
}))

function getBarColor(name: string): string {
  const colors: Record<string, string> = {
    '销售额': '#409eff',
    '订单数': '#67c23a',
    '利润': '#e6a23c',
    '成本': '#f56c6c'
  }
  return colors[name] || '#909399'
}
</script>
