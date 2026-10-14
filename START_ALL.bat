@echo off
title TrastornadoresApp - Autonomous Cycles Launcher
echo ==========================================
echo  TRASTORNADORESAPP - AUTONOMOUS CYCLES
echo ==========================================
echo.
echo Starting OpenCode Server (port 8080)...
start "OpenCode Server" cmd /k "cd /d D:\Projects\TrastornadoresApp && opencode serve --port 8080"
timeout /t 5 >nul
echo.
echo Starting Autonomous Cycles...
start "Autonomous Cycles" cmd /k "cd /d D:\Projects\TrastornadoresApp && powershell.exe -ExecutionPolicy Bypass -File .opencode\scripts\run-cycles.ps1 todos iniciar"
timeout /t 3 >nul
echo.
echo ==========================================
echo  BOTH SERVICES STARTED IN SEPARATE WINDOWS
echo ==========================================
echo.
echo OpenCode Server:  http://localhost:8080
echo Cycles Log:       Check the "Autonomous Cycles" window
echo.
echo To stop: Close the two console windows
echo.
pause