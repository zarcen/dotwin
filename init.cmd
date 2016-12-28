:: init.cmd
:: My Windows version of general config file just like .bashrc or .profile

:: This script is automatically executed when starting cmd.exe by
:: defining its path in the following regkey:
:: "HKEY_CURRENT_USER\Software\Microsoft\Command Processor\AutoRun"
@echo off

:: Set Environment variables
call :set_dotwin_var
:: Load personal alias definition
call %DOTWIN%\alias.cmd

:: Put bash wrapper scripts to be visible in PATH;
:: Change order if prefer system default
path %PATH%;%DOTWIN_BASHEE%
if exist %DOTWIN_PRIVATE% path %PATH%;%DOTWIN_PRIVATE%
exit /b

:: ******************************** SUBROUTINE ********************************
:set_dotwin_var:
    :: Set dotwin Root Path
    if "%DOTWIN%"=="" set DOTWIN=%USERPROFILE%\dotwin
    set DOTWIN_PS1=%DOTWIN%\ps1
    set DOTWIN_BASHEE=%DOTWIN%\bashee
    :: Private(or Corporate internal) stuff
    if exist %DOTWIN%\private set DOTWIN_PRIVATE=%DOTWIN%\private
exit /b