@echo off
setlocal enabledelayedexpansion

REM ============================================================
REM  Run AI Newsletter (Windows)
REM  Double-click to generate this week's personalized AI digest.
REM  Output saves to your Documents\AI Newsletter\ folder
REM  (works with OneDrive document redirection) and auto-opens
REM  in your default browser when done.
REM  Takes ~5 min (parallel web fetches across your sources).
REM ============================================================

REM ---- Find the latest installed Claude Code version --------
REM     Resilient to Claude Code self-updates: re-detects each run.
for /f "delims=" %%v in ('powershell -NoProfile -Command "Get-ChildItem '%APPDATA%\Claude\claude-code' -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 1 -ExpandProperty Name"') do set "CLAUDE_VER=%%v"
set "CLAUDE=%APPDATA%\Claude\claude-code\%CLAUDE_VER%\claude.exe"

REM ---- Resolve the *real* Documents folder ------------------
REM     On machines with OneDrive document redirection (common on
REM     enterprise laptops), %USERPROFILE%\Documents is NOT what
REM     File Explorer shows. Use the OS API to get the real one.
for /f "delims=" %%d in ('powershell -NoProfile -Command "[Environment]::GetFolderPath('MyDocuments')"') do set "DOCS=%%d"
if "%DOCS%"=="" set "DOCS=%USERPROFILE%\Documents"

set "OUTDIR=%DOCS%\AI Newsletter"
set "SKILLDIR=%USERPROFILE%\.claude\skills\ai-newsletter"

REM ---- Pre-flight checks ------------------------------------
if "%CLAUDE_VER%"=="" (
    echo ERROR: Could not find Claude Code installation at:
    echo   %APPDATA%\Claude\claude-code\
    echo Please make sure Claude Code is installed.
    pause
    exit /b 1
)

if not exist "%CLAUDE%" (
    echo ERROR: Claude Code executable not found at:
    echo   %CLAUDE%
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
echo  Generating your AI newsletter for the past 7 days...
echo  Output folder: %OUTDIR%
echo  Using Claude Code v%CLAUDE_VER%
echo  This takes about 5 minutes. Don't close this window.
echo ============================================================
echo.

"%CLAUDE%" -p "Run the ai-newsletter skill to generate this week's personalized AI digest. The skill is installed at ~/.claude/skills/ai-newsletter/ -- follow its SKILL.md procedure exactly. Save both the markdown and the rendered HTML to the current directory. When done, reply with just the filename of the HTML output." --allowedTools "WebFetch WebSearch Read Write Bash Glob Grep Edit" --add-dir "%SKILLDIR%"

set "EXITCODE=%ERRORLEVEL%"
if not "%EXITCODE%"=="0" (
    echo.
    echo Claude Code exited with code %EXITCODE%. Scroll up for details.
    pause
    exit /b %EXITCODE%
)

echo.
echo ============================================================
echo  Done. Opening your newsletter in the browser...
echo ============================================================

REM Find today's HTML file; fall back to most recent if not present.
for /f "delims=" %%d in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd"') do set "TODAY=%%d"

if exist "ai-newsletter-%TODAY%.html" (
    start "" "ai-newsletter-%TODAY%.html"
) else (
    set "LATEST="
    for /f "delims=" %%f in ('dir /b /od "ai-newsletter-*.html" 2^>nul') do set "LATEST=%%f"
    if defined LATEST (
        echo Today's file not found. Opening most recent: !LATEST!
        start "" "!LATEST!"
    ) else (
        echo No newsletter HTML file was generated.
        echo Check the folder for errors: %OUTDIR%
        pause
        exit /b 1
    )
)

REM Brief pause so success message stays visible
timeout /t 3 /nobreak >nul

endlocal
