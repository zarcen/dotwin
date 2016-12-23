:: alias.cmd
@echo off

:: utilities
doskey ls=dir $*
doskey ps=powershell.exe $*
:: ****************************************************************************

:: powershell wrapping
if "%DOTWIN%"=="" (set DOTWIN=%USERPROFILE%\dotwin)
set DOTWIN_PS1=%DOTWIN%\ps1
doskey sudo=ps %DOTWIN_PS1%\sudo.ps1 $*
:: ****************************************************************************

:: applications
doskey npp=start notepad++ $*
:: ****************************************************************************

:: bash wrapping is in dotwin\bashee
:: ****************************************************************************