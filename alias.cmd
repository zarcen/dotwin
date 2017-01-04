:: alias.cmd
::@echo off

:: ----- utilities -----
doskey ls=dir $*
:: Usecase:
::     > ps -F my.ps1
::     > ps -C "& echo foo"
::     > ps -C Write-Output bar
doskey ps=powershell.exe $*
:: Usecase:
::     > bashc ./foo arg1 arg2
::     > bash -c "./foo arg1 arg2" (equiv.)
::     i.e. Use whenever running a executable that is compiled in bash
doskey bashc=bash -c "$*" :: usecase, bashc ./foo arg1 arg2
:: ****************************************************************************

:: ----- powershell wrapping -----
if "%DOTWIN%"=="" (set DOTWIN=%USERPROFILE%\dotwin)
set DOTWIN_PS1=%DOTWIN%\ps1
:: Usecase:
::    > sudo regedit
::    > sudo notepad (editing with elevated premission)
doskey sudo=powershell.exe -File %DOTWIN_PS1%\sudo.ps1 $*
:: ****************************************************************************

:: ----- applications -----
:: Put frequently used application alias here
doskey npp=start notepad++ $*
:: ****************************************************************************

:: bash wrapping is in dotwin\bashee
:: ****************************************************************************

exit /b 0