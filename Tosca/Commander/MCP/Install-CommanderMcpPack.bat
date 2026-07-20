@echo off
setlocal
powershell -NoProfile -File "%~dp0Install-CommanderMcpPack.ps1" %*
exit /b %ERRORLEVEL%
