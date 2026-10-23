@echo off
rem Double-click to update the Cultivaria pack in your .minecraft. Close Minecraft first.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0update-cultivaria.ps1" %*
echo.
pause
