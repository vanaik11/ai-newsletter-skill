@echo off
setlocal enabledelayedexpansion

REM ============================================================
REM  AI Newsletter Skill - One-Click Setup (Windows)
REM
REM  Run this once on your Windows laptop. It will:
REM    1. Download the AI newsletter skill from GitHub
REM    2. Install it into your Claude Code skills folder
REM    3. Create a "AI Newsletter.bat" launcher on your Desktop
REM
REM  Prerequisites:
REM    - Claude Code installed and signed in
REM    - Internet access (downloads from github.com)
REM
REM  Safe to re-run any time to update the skill to the latest
REM  version from GitHub.
REM ============================================================

echo.
echo  ============================================================
echo    AI Newsletter Skill - Setup
echo  ============================================================
echo.

REM ----- 1. Verify Claude Code is installed --------------------
for /f "delims=" %%v in ('powershell -NoProfile -Command "Get-ChildItem '%APPDATA%\Claude\claude-code' -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 1 -ExpandProperty Name"') do set "CLAUDE_VER=%%v"

if "%CLAUDE_VER%"=="" (
    echo  ERROR: Claude Code is not installed on this machine.
    echo.
    echo  Install Claude Code first from https://claude.com/download,
    echo  sign in, then re-run this setup.
    echo.
    pause
    exit /b 1
)

echo   [OK] Found Claude Code v%CLAUDE_VER%

REM ----- 2. Resolve real Desktop (OneDrive-aware) --------------
for /f "delims=" %%d in ('powershell -NoProfile -Command "[Environment]::GetFolderPath('Desktop')"') do set "DESKTOP=%%d"

if "%DESKTOP%"=="" set "DESKTOP=%USERPROFILE%\Desktop"
echo   [OK] Desktop folder: %DESKTOP%

REM ----- 3. Set up working paths -------------------------------
set "TMP_DIR=%TEMP%\ai-newsletter-setup"
set "ZIP_FILE=%TMP_DIR%\repo.zip"
set "EXTRACT_DIR=%TMP_DIR%\extract"
set "SKILL_DIR=%USERPROFILE%\.claude\skills"
set "TARGET_SKILL=%SKILL_DIR%\ai-newsletter"

if exist "%TMP_DIR%" rmdir /s /q "%TMP_DIR%"
mkdir "%TMP_DIR%"
mkdir "%EXTRACT_DIR%"

REM ----- 4. Download the repo as a ZIP -------------------------
echo.
echo   Downloading skill from GitHub...
powershell -NoProfile -Command "$ProgressPreference='SilentlyContinue'; try { Invoke-WebRequest 'https://github.com/vanaik11/ai-newsletter-skill/archive/refs/heads/main.zip' -OutFile '%ZIP_FILE%' -UseBasicParsing } catch { exit 1 }"

if not exist "%ZIP_FILE%" (
    echo.
    echo  ERROR: Download failed.
    echo  Check your internet connection or proxy settings, then re-run.
    echo.
    pause
    exit /b 1
)

REM ----- 5. Extract the archive --------------------------------
echo   Extracting...
powershell -NoProfile -Command "Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%EXTRACT_DIR%' -Force"

set "SRC_DIR="
for /d %%d in ("%EXTRACT_DIR%\ai-newsletter-skill-*") do set "SRC_DIR=%%d"
if "!SRC_DIR!"=="" (
    echo.
    echo  ERROR: Could not find extracted folder.
    echo  Setup files may be corrupted -- delete %TMP_DIR% and re-run.
    echo.
    pause
    exit /b 1
)

REM ----- 6. Install the skill ---------------------------------
echo   Installing skill...
if not exist "%SKILL_DIR%" mkdir "%SKILL_DIR%"
if exist "%TARGET_SKILL%" rmdir /s /q "%TARGET_SKILL%"
xcopy /e /q /i "!SRC_DIR!\ai-newsletter" "%TARGET_SKILL%" >nul

if not exist "%TARGET_SKILL%\SKILL.md" (
    echo.
    echo  ERROR: Skill install failed -- SKILL.md not present at:
    echo  %TARGET_SKILL%
    echo.
    pause
    exit /b 1
)
echo   [OK] Skill installed to %TARGET_SKILL%

REM ----- 7. Install Desktop launcher ---------------------------
echo   Creating Desktop launcher...
copy /y "!SRC_DIR!\windows\AI Newsletter.bat" "%DESKTOP%\AI Newsletter.bat" >nul
echo   [OK] Launcher at %DESKTOP%\AI Newsletter.bat

REM ----- 8. Suggest permissions config -------------------------
REM We don't auto-edit settings.json (user may have unrelated config),
REM but we point them at the recommendation.
echo.
echo   TIP: To silence permission prompts when the skill runs,
echo        add this to %%USERPROFILE%%\.claude\settings.json:
echo.
echo          "permissions": {
echo            "allow": ["WebFetch","WebSearch","Read","Write",
echo                      "Edit","Bash","Glob","Grep"]
echo          }

REM ----- 9. Clean up -------------------------------------------
rmdir /s /q "%TMP_DIR%" >nul 2>&1

REM ----- 10. Show success message and next steps ---------------
echo.
echo  ============================================================
echo    Setup complete!
echo  ============================================================
echo.
echo   NEXT STEPS:
echo.
echo   1. QUIT Claude Code completely
echo      (right-click system tray icon ^> Quit -- NOT just close
echo      the window. Otherwise it won't see the new skill.)
echo.
echo   2. Double-click "AI Newsletter.bat" on your Desktop
echo      (the launcher we just created)
echo.
echo   3. When the Claude prompt appears, type:
echo.
echo        run my AI newsletter, then open the HTML when done
echo.
echo   4. Wait ~5 minutes. Your browser will open with this
echo      week's personalized AI digest.
echo.
echo   To customize sources (newsletters, YouTubers, voices you
echo   follow), edit:
echo     %TARGET_SKILL%\SKILL.md
echo.
echo   Repo + docs: https://github.com/vanaik11/ai-newsletter-skill
echo.
pause
endlocal
