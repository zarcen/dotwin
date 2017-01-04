:: init.cmd
:: My Windows version of general config file just like .bashrc or .profile

:: This script is automatically executed when starting cmd.exe by
:: defining its path in the following regkey:
:: "HKEY_CURRENT_USER\Software\Microsoft\Command Processor\AutoRun"
@echo off

:: Set Environment variables
if "%DOTWIN%"=="" (
    call :set_dotwin_var
)
:: Load personal alias definition
call %DOTWIN%\alias.cmd

call :set_prompt
::TODO: BUG, clink makes doskey invalid in cmder
call :launch_clink
:: Simple "ver" prints empty line before Windows version

:: Use this construction to print just a version info
cmd /d /c ver | "%windir%\system32\find.exe" "Windows"
exit /b 0



:::::: Environment variables ::::::::::::::::::::::::::::::::::::::::::::::::::
:set_dotwin_var
    :: Set dotwin Root Path
    set DOTWIN=%USERPROFILE%\dotwin
    set DOTWIN_PS1=%DOTWIN%\ps1
    set DOTWIN_BASHEE=%DOTWIN%\bashee
    :: Put bash wrapper scripts to be visible in PATH;
    :: Change order if prefer system default
    path %DOTWIN_BASHEE%;%PATH%

    :: Private(or Corporate internal) stuff
    if exist %DOTWIN%\private set DOTWIN_PRIVATE=%DOTWIN%\private
    if exist %DOTWIN_PRIVATE% path %DOTWIN_PRIVATE%;%PATH%
exit /b

:::::: PROMPT setting :::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:set_prompt
:: This will start prompt with `user@hostname`
set PromptHead=$E[0;36m%USERNAME%@%COMPUTERNAME%$E[0;37m$S

:: Followed by colored `pwd`
set PromptHead=%PromptHead%$E[0;32m$P$E[0;37m

:: Use net command to test if it's run by Admin or not
:: Carriage return and `$`(Admin) or `>`(User)
net session >nul 2>&1 && set PromptRet=$E[1;31m$$$E[1;37m$S || set PromptRet=$E[1;31m$G$E[1;37m$S

:: Set new prompt and show current time (format hh:mm:ss)
set PS1=%PromptHead%$_$C$T$F%PromptRet%
PROMPT %PS1%
exit /b 0

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:launch_clink
:: Pick right version of clink
if "%PROCESSOR_ARCHITECTURE%"=="x86" (
    set architecture=86
) else (
    set architecture=64
)
:: Run clink
%DOTWIN%\clink\clink_x%architecture%.exe inject --quiet


exit /b 0
