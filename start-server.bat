@echo off
cd /d "%~dp0"
echo 启动本地服务器 http://localhost:9865
echo 按 Ctrl+C 停止
echo.
npx serve . -l 9865
pause
