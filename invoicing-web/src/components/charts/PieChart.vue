<template>
  <BaseChart :option="chartOption" :height="height" />
</template>

<script setup lang="ts">
import { computed } from 'vue'
import BaseChart from './BaseChart.vue'

interface DataItem {
  name: string
  value: number
  itemStyle?: { color: string }
}

interface Props {
  title?: string
  data: DataItem[]
  height?: string
  radius?: string[]
}

const props = withDefaults(defineProps<Props>(), {
  title: '',
  height: '350px',
  radius: () => ['45%', '70%']
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
    trigger: 'item',
    formatter: '{b}: {c} ({d}%)'
  },
  legend: {
    orient: 'vertical',
    right: '5%',
    top: 'center',
    textStyle: {
      color: '#606266'
    }
  },
  series: [
    {
      name: props.title,
      type: 'pie',
      radius: props.radius,
      center: ['40%', '50%'],
      avoidLabelOverlap: false,
      itemStyle: {
        borderRadius: 8,
        borderColor: '#fff',
        borderWidth: 2
      },
      label: {
        show: true,
        formatter: '{b}\n{d}%'
      },
      emphasis: {
        label: {
          show: true,
          fontSize: 14,
          fontWeight: 'bold'
        },
        itemStyle: {
          shadowBlur: 10,
          shadowOffsetX: 0,
          shadowColor: 'rgba(0, 0, 0, 0.5)'
        }
      },
      labelLine: {
        show: true,
        length: 15,
        length2: 10
      },
      data: props.data.map((item, index) => ({
        ...item,
        itemStyle: item.itemStyle || { color: getPieColor(index) }
      }))
    }
  ]
}))

function getPieColor(index: number): string {
  const colors = ['#409eff', '#67c23a', '#e6a23c', '#f56c6c', '#909399', '#c71585', '#ff8c00', '#9932cc']
  return colors[index % colors.length]
}
</script>
