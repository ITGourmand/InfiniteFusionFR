@echo off

REM Get the name of the current folder
for %%F in ("%~dp0.") do set "currentFolder=%%~nF"

REM Check if the folder name matches the allowed names
if /i not "%currentFolder%"=="InfiniteFusionFR" (
    echo ERROR: This script must be run from a folder named "InfiniteFusionFR" .
    pause
    exit /b 1
)

REM Proceed with the script if the folder name is correct
set mgit=".\REQUIRED_BY_INSTALLER_UPDATER\cmd\git.exe"
%mgit% init .
%mgit% remote add origin "https://github.com/ITGourmand/InfiniteFusionFR.git"
%mgit% fetch origin release
%mgit% reset --hard origin/release
%mgit% clean -fd --exclude=REQUIRED_BY_INSTALLER_UPDATER/ --exclude=INSTALL_OR_UPDATE.bat
pause