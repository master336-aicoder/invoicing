$env:JAVA_HOME="D:\program\java\jdk-21"
$env:PATH="D:\program\java\jdk-21\bin;" + $env:PATH

Write-Host "Java Home: $env:JAVA_HOME"
Write-Host "Java Version:"
& "D:\program\java\jdk-21\bin\java.exe" -version

Write-Host ""
Write-Host "Attempting to run JAR file..."
Write-Host "JAR Path: e:\code\Invoicing\invoicing-backend\invoicing-auth\target\invoicing-auth-1.0.0.jar"

try {
    & "D:\program\java\jdk-21\bin\java.exe" -jar "e:\code\Invoicing\invoicing-backend\invoicing-auth\target\invoicing-auth-1.0.0.jar" --spring.profiles.active=local 2>&1
} catch {
    Write-Host "Exception caught: $_"
}