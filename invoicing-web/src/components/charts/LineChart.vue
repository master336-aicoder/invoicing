<template>
  <BaseChart :option="chartOption" :height="height" />
</template>

<script setup lang="ts">
import { computed } from 'vue'
import BaseChart from './BaseChart.vue'

interface SeriesItem {
  name: string
  data: number[]
  smooth?: boolean
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
    backgroundColor: 'rgba(255,255,255,0.95)',
    borderColor: '#dcdfe6',
    borderWidth: 1,
    textStyle: {
      color: '#303133'
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
    boundaryGap: false,
    data: props.xData,
    axisLine: {
      lineStyle: {
        color: '#dcdfe6'
      }
    },
    axisLabel: {
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
  series: props.seriesData.map((item, index) => ({
    name: item.name,
    type: 'line',
    smooth: item.smooth !== undefined ? item.smooth : true,
    data: item.data,
    lineStyle: {
      width: 3
    },
    itemStyle: {
      color: getLineColor(index)
    },
    areaStyle: {
      color: {
        type: 'linear',
        x: 0,
        y: 0,
        x2: 0,
        y2: 1,
        colorStops: [
          { offset: 0, color: getAreaColor(index, 0.3) },
          { offset: 1, color: getAreaColor(index, 0.05) }
        ]
      }
    },
    symbol: 'circle',
    symbolSize: 8,
    emphasis: {
      focus: 'series',
      itemStyle: {
        borderWidth: 2,
        borderColor: '#fff',
        shadowBlur: 10,
        shadowColor: 'rgba(0,0,0,0.3)'
      }
    }
  }))
}))

function getLineColor(index: number): string {
  const colors = ['#409eff', '#67c23a', '#e6a23c', '#f56c6c', '#909399', '#c71585']
  return colors[index % colors.length]
}

function getAreaColor(index: number, alpha: number): string {
  const colors = ['#409eff', '#67c23a', '#e6a23c', '#f56c6c', '#909399', '#c71585']
  return colors[index % colors.length]
}
</script>
