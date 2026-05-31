# 数据库初始化脚本
# 执行所有微服务数据库的创建和初始化

$MySQLHost = "192.168.1.6"
$MySQLPort = "13306"
$MySQLUser = "root"
$MySQLPass = "root"

$ScriptsDir = "e:\code\Invoicing\invoicing-backend\scripts"

$SqlFiles = @(
    "init-auth-db.sql",
    "init-product-db.sql",
    "init-purchase-db.sql",
    "init-sales-db.sql",
    "init-inventory-db.sql"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "开始执行数据库初始化脚本" -ForegroundColor Cyan
Write-Host "MySQL: $MySQLHost`:$MySQLPort" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

foreach ($File in $SqlFiles) {
    $FilePath = Join-Path -Path $ScriptsDir -ChildPath $File
    if (-not (Test-Path -Path $FilePath)) {
        Write-Host "[跳过] 文件不存在: $FilePath" -ForegroundColor Yellow
        continue
    }

    Write-Host "`n[执行中] $File ..." -ForegroundColor Yellow

    try {
        # 读取SQL文件内容并执行
        $SQLContent = Get-Content -Path $FilePath -Raw -Encoding UTF8

        # 使用mysql命令执行
        $Result = & mysql -h $MySQLHost -P $MySQLPort -u $MySQLUser -p$MySQLPass -e "$SQLContent" 2>&1

        if ($LASTEXITCODE -eq 0) {
            Write-Host "[成功] $File 执行完成" -ForegroundColor Green
        } else {
            Write-Host "[失败] $File 执行失败，退出码: $LASTEXITCODE" -ForegroundColor Red
            Write-Host "错误信息: $Result" -ForegroundColor Red
        }
    } catch {
        Write-Host "[异常] $File 执行异常: $_" -ForegroundColor Red
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "数据库初始化完成！" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 验证数据库是否创建成功
Write-Host "`n验证数据库创建情况..." -ForegroundColor Cyan
$VerifySQL = "SHOW DATABASES LIKE 'invoicing_%';"
$Result = & mysql -h $MySQLHost -P $MySQLPort -u $MySQLUser -p$MySQLPass -e $VerifySQL 2>&1
Write-Host $Result -ForegroundColor White
