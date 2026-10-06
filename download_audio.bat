@echo off
echo ============================================================
echo Downloading Beautiful Recitations of Allah's 99 Names
echo ============================================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo Error: Python is not installed or not in PATH
    echo Please install Python from https://www.python.org/
    pause
    exit /b 1
)

REM Install requests if needed
echo Installing required packages...
pip install requests >nul 2>&1

REM Run the download script
echo.
echo Starting download...
echo.
python download_audio.py

echo.
echo ============================================================
echo Download process completed!
echo ============================================================
pause
