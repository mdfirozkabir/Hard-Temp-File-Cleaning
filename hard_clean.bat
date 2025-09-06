@echo off
:: hard_clean.bat — Temp/Recent/Recycle/Thumbcache cleaner (requests Admin)

:: --- Elevation (run as admin if not) ---
net session >nul 2>&1
if %errorlevel% neq 0 (
  echo Administrator privileges required. Requesting elevation...
  powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)

echo.
echo === Starting HARD CLEAN ===
echo (This will delete TEMP files, Recent links, thumbnail cache, Recycle Bin, etc.)
echo.

:: --- Close common locks (try to reduce "file in use" issues) ---
echo Stopping Explorer to release locks...
taskkill /f /im explorer.exe >nul 2>&1
timeout /t 1 >nul
start explorer.exe

:: --- Clear user TEMP ---
echo Clearing %%TEMP%%...
rd /s /q "%temp%" 2>nul
md "%temp%" 2>nul

:: --- Clear Windows TEMP ---
echo Clearing %windir%\Temp...
rd /s /q "%windir%\Temp" 2>nul
md "%windir%\Temp" 2>nul

:: --- Clear Recent items (shortcuts) ---
echo Clearing Recent folder...
rd /s /q "%userprofile%\Recent" 2>nul
md "%userprofile%\Recent" 2>nul

:: --- Clear Internet Explorer / Edge (temporary files) ---
echo Clearing Internet/Edge temporary files (best-effort)...
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 255  >nul 2>&1

:: --- Clear thumbnail cache ---
echo Removing thumbnail cache...
del /f /s /q "%localappdata%\Microsoft\Windows\Explorer\thumbcache_*.db" 2>nul

:: --- Empty Recycle Bin ---
echo Emptying Recycle Bin...
powershell -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"

:: --- Optional: Windows component store cleanup (may take long) ---
echo Starting component store cleanup (DISM) - optional, may take time...
Dism.exe /Online /Cleanup-Image /StartComponentCleanup /Quiet >nul 2>&1

:: --- Run Disk Cleanup (sagerun) quickly ---
echo Running Disk Cleanup (non-interactive)...
cleanmgr /sagerun:1 >nul 2>&1

:: --- Restart Explorer ---
echo Restarting Explorer...
start explorer.exe

echo.
echo === CLEAN COMPLETE ===
echo Some files in use might not be removable; reboot to finish cleaning.
pause
