param(
    [string]$host = "192.168.1.6",
    [string]$port = "13306",
    [string]$user = "root",
    [string]$password = "root",
    [string]$database = "invoicing_auth"
)

Write-Host "Testing database connection to $host`:$port..."

try {
    $connectionString = "server=$host;port=$port;database=$database;uid=$user;pwd=$password"
    $connection = New-Object MySql.Data.MySqlClient.MySqlConnection($connectionString)
    $connection.Open()
    Write-Host "Successfully connected to database $database"
    
    $command = $connection.CreateCommand()
    $command.CommandText = "SELECT COUNT(*) FROM sys_user"
    $count = $command.ExecuteScalar()
    Write-Host "Found $count users in sys_user table"
    
    $command.CommandText = "SELECT username, password FROM sys_user LIMIT 2"
    $reader = $command.ExecuteReader()
    while ($reader.Read()) {
        Write-Host "User: $($reader['username']), Password (first 20 chars): $($reader['password'].Substring(0, [Math]::Min(20, $reader['password'].Length)))"
    }
    $reader.Close()
    
    $connection.Close()
} catch {
    Write-Host "Error: $_"
}
