@echo off
REM Setup script to create .claude symlink in a project directory
REM Usage: setup-symlink.bat [project-path]
REM If no path provided, uses current directory

setlocal

if "%~1"=="" (
    set "PROJECT_DIR=%CD%"
) else (
    set "PROJECT_DIR=%~1"
)

set "MCP_CONFIG_DIR=C:\MCP-Config\.claude"
set "SYMLINK_TARGET=%PROJECT_DIR%\.claude"

echo.
echo ========================================
echo Claude MCP Symlink Setup
echo ========================================
echo.
echo Project Directory: %PROJECT_DIR%
echo MCP Config Source:  %MCP_CONFIG_DIR%
echo Symlink Target:     %SYMLINK_TARGET%
echo.

REM Check if MCP config exists
if not exist "%MCP_CONFIG_DIR%" (
    echo ERROR: MCP config directory not found at %MCP_CONFIG_DIR%
    echo Please ensure C:\MCP-Config\.claude exists
    exit /b 1
)

REM Check if symlink already exists
if exist "%SYMLINK_TARGET%" (
    echo WARNING: .claude already exists at %SYMLINK_TARGET%
    echo.
    choice /C YN /M "Do you want to remove it and create a symlink"
    if errorlevel 2 (
        echo Cancelled.
        exit /b 0
    )

    REM Remove existing .claude (could be folder or symlink)
    rd /s /q "%SYMLINK_TARGET%" 2>nul
    del /f /q "%SYMLINK_TARGET%" 2>nul
)

REM Create directory symlink (requires admin rights)
echo Creating symlink...
mklink /D "%SYMLINK_TARGET%" "%MCP_CONFIG_DIR%"

if errorlevel 1 (
    echo.
    echo ERROR: Failed to create symlink.
    echo This usually means you need to run this script as Administrator.
    echo.
    echo Right-click this file and select "Run as administrator"
    exit /b 1
)

echo.
echo SUCCESS! Symlink created successfully.
echo.
echo Your project now uses the centralized MCP configuration.
echo Any changes to .claude files will be reflected across all projects.
echo.

endlocal
