@echo off
setlocal
powershell -NoProfile -File "%~dp0Install-CliApiCommanderPack.ps1" %*
exit /b %ERRORLEVEL%
