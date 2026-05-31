# 提交所有Nacos配置的脚本
# 脚本用于批量将config目录下的配置文件提交到Nacos

# Nacos连接信息
$NacosServer = "http://192.168.1.20:8848"
$Namespace = "ai-dev"
$Group = "dev"

# 配置文件列表
$ConfigFiles = @(
    "common.yml",
    "invoicing-gateway.yml",
    "auth-service.yml",
    "product-service.yml",
    "purchase-service.yml",
    "sales-service.yml",
    "inventory-service.yml"
)

$ConfigDir = "e:\code\Invoicing\invoicing-backend\config"

Write-Host "开始提交配置到Nacos..." -ForegroundColor Green
Write-Host "Nacos服务器: $NacosServer"
Write-Host "命名空间: $Namespace"
Write-Host "组: $Group"
Write-Host "------------------------"

foreach ($File in $ConfigFiles) {
    $FilePath = Join-Path -Path $ConfigDir -ChildPath $File
    if (-not (Test-Path -Path $FilePath)) {
        Write-Host "配置文件不存在: $FilePath" -ForegroundColor Red
        continue
    }

    $Content = Get-Content -Path $FilePath -Raw
    $DataId = $File

    Write-Host "正在提交: $DataId"

    try {
        # 构建请求体
        $Body = @{
            dataId = $DataId
            group = $Group
            tenant = $Namespace
            content = $Content
            type = "yaml"
        }

        # 使用Invoke-RestMethod发送请求
        $Response = Invoke-RestMethod -Uri "$NacosServer/nacos/v1/cs/configs" -Method Post -Body $Body -ContentType "application/x-www-form-urlencoded"

        if ($Response -eq "true") {
            Write-Host "✓ 配置提交成功: $DataId" -ForegroundColor Green
        } else {
            Write-Host "✗ 配置提交失败: $DataId, 响应: $Response" -ForegroundColor Red
        }
    } catch {
        Write-Host "✗ 配置提交失败: $DataId, 错误: $_" -ForegroundColor Red
    }
}

Write-Host "------------------------"
Write-Host "配置提交完成!" -ForegroundColor Green
