@echo off
set JAVA_HOME=D:\program\java\jdk-21
set PATH=%JAVA_HOME%\bin;%PATH%

echo Starting auth service...
echo %date% %time% > e:\code\Invoicing\service.log
java -jar "e:\code\Invoicing\invoicing-backend\invoicing-auth\target\invoicing-auth-1.0.0.jar" --spring.profiles.active=local --debug >> e:\code\Invoicing\service.log 2>&1
echo Service exited with code %errorlevel% >> e:\code\Invoicing\service.log