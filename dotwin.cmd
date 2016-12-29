:: init.cmd
:: My Windows version of general config file just like .bashrc or .profile

:: This script is automatically executed when starting cmd.exe by
:: defining its path in the following regkey:
:: "HKEY_CURRENT_USER\Software\Microsoft\Command Processor\AutoRun"
@echo off

:: Set Environment variables
if "%DOTWIN%"=="" (
    call :set_dotwin_var
) else (
    :: dotwin.cmd has been loaded
    exit /b
)

:: Load personal alias definition
call %DOTWIN%\alias.cmd

:: Put bash wrapper scripts to be visible in PATH;
:: Change order if prefer system default
path %PATH%;%DOTWIN_BASHEE%
if exist %DOTWIN_PRIVATE% path %PATH%;%DOTWIN_PRIVATE%
call :launch
exit /b

:::::: Environment variables ::::::::::::::::::::::::::::::::::::::::::::::::::
:set_dotwin_var
    :: Set dotwin Root Path
    set DOTWIN=%USERPROFILE%\dotwin
    set DOTWIN_PS1=%DOTWIN%\ps1
    set DOTWIN_BASHEE=%DOTWIN%\bashee
    :: Private(or Corporate internal) stuff
    if exist %DOTWIN%\private set DOTWIN_PRIVATE=%DOTWIN%\private
exit /b

:::::: PROMPT setting :::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:set_prompt
:: This will start prompt with `User@PC `
set PromptHead=[$E[0;36m%USERNAME%@%COMPUTERNAME%$E[0;37m]$S

:: Followed by colored `Path`
set PromptHead=%PromptHead%$E[0;32m$P$E[0;37m
if NOT "%PROCESSOR_ARCHITECTURE%" == "AMD64" (
  if "%PROCESSOR_ARCHITEW6432%" == "AMD64" if "%PROCESSOR_ARCHITECTURE%" == "x86" (
    :: Use bright text color if cmd was run from SysWow64
    set PromptHead=%PromptHead%$E[1;32m$P$E[0;37m
  )
)

:: Use net command to test if it's run by Admin or not
:: Carriage return and `$`(Admin) or `>`(User)
net session >nul 2>&1 && set PromptRet=$E[1;31m$$$S$E[1;37m || set PromptRet=$E[1;31m$G$S$E[1;37m

:: Set new prompt and show current time (format hh:mm:ss)
PROMPT %PromptHead%$S($T)$_%PromptRet%
exit /b 0

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:launch
call :set_prompt
:: Simple "ver" prints empty line before Windows version
:: Use this construction to print just a version info
cmd /d /c ver | "%windir%\system32\find.exe" "Windows"
:: Pick right version of clink
if "%PROCESSOR_ARCHITECTURE%"=="x86" (
    set architecture=86
) else (
    set architecture=64
)
:: Run clink
"%~dp0\clink\clink_x%architecture%.exe" inject --quiet


exit /b 0
