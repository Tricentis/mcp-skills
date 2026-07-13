@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-CommanderMcpPack.ps1" %*
exit /b %ERRORLEVEL%
