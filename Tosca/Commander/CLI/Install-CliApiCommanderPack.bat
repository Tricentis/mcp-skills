@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-CliApiCommanderPack.ps1" %*
exit /b %ERRORLEVEL%
