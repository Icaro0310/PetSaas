@echo off
cd /d "%~dp0"
start "" /min cmd /c "node_modules\electron\dist\electron.exe . > nul 2>&1"
