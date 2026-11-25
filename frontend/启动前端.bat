@echo off
title Anime Frontend - http://localhost:5500
cd /d "D:\webAi\anime-frontend"
echo ============================================================
echo   Frontend server on http://localhost:5500
echo   Backend must be running on port 9091
echo   Keep this window open. Do NOT close it.
echo   Open browser: http://localhost:5500
echo ============================================================
echo.
python -m http.server 5500
pause >nul
