$ErrorActionPreference = "Stop"
$result = & mysql -h 192.168.1.6 -P 13306 -u root -proot -e "USE invoicing; SHOW TABLES;" 2>&1
Write-Host $result