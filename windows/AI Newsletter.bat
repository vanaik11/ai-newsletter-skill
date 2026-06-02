@echo off
setlocal

REM ============================================================
REM  AI Newsletter (Windows, interactive)
REM
REM  Double-click to open Claude Code in your AI Newsletter folder.
REM  Then type at the prompt:
REM
REM      run my AI newsletter, then open the HTML when done
REM
REM  Walk away. About 5 minutes later your browser opens with
REM  this week's digest. Files land in your Documents\AI Newsletter\
REM  folder (handles OneDrive document redirection).
REM
REM  No API key needed -- uses your interactive Claude Code session
REM  and your existing subscription.
REM ============================================================

REM Find the latest installed Claude Code version (resilient to updates)
for /f "delims=" %%v in ('powershell -NoProfile -Command "Get-ChildItem '%APPDATA%\Claude\claude-code' -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 1 -ExpandProperty Name"') do set "CLAUDE_VER=%%v"
set "CLAUDE=%APPDATA%\Claude\claude-code\%CLAUDE_VER%\claude.exe"

REM Resolve the real Documents folder (handles OneDrive redirection)
for /f "delims=" %%d in ('powershell -NoProfile -Command "[Environment]::GetFolderPath('MyDocuments')"') do set "DOCS=%%d"
if "%DOCS%"=="" set "DOCS=%USERPROFILE%\Documents"

set "OUTDIR=%DOCS%\AI Newsletter"
set "SKILLDIR=%USERPROFILE%\.claude\skills\ai-newsletter"

if "%CLAUDE_VER%"=="" (
    echo ERROR: Could not find Claude Code installation.
    pause
    exit /b 1
)

if not exist "%SKILLDIR%\SKILL.md" (
    echo ERROR: ai-newsletter skill not installed at:
    echo   %SKILLDIR%
    echo See the repo README for install instructions.
    pause
    exit /b 1
)

if not exist "%OUTDIR%" mkdir "%OUTDIR%"
cd /d "%OUTDIR%"

echo.
echo ============================================================
echo  Claude Code is opening in your newsletter folder:
echo    %OUTDIR%
echo.
echo  When the prompt appears, type:
echo    run my AI newsletter, then open the HTML when done
echo.
echo  Walk away. ~5 minutes. Your browser will open the result.
echo ============================================================
echo.

"%CLAUDE%"

endlocal
