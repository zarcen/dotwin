# dotwin
A personal environment configuration folder in Windows environment.
For managing personal scripts, small tools, GNU toolset mapping in Windows environment

## Purpose
The purpose of this repo is to do something similar as .zsh, .bashrc, .profile in *nix environment.

## Get Started
### Prerequisite
This repo is dedicated to Windows 10 which version is new enough with the "Windows Subsystem for Linux" feature supported.
+ Windows 10 64-bit OS

+ Build version later than 14393

+ Powershell<br>
    <i>Directly come with Windows 10. If not enabled, in start menu type type "turn windows features on or off" and enable it</i>
+ Developer Mode (Start -> Settings -> Update & Security -> For Developers)

### Install
To install, simply execute `install.cmd`

You would need Admin permission to enable "Windows Subsystem for Linux" and the script will prompt you that. No need to execute it with Administrator privilege.

## Bash support
Now that Windows has bash support natively, powered by "Windows Subsystem for Linux" since Windows 10 Redstone,
we can leverage GNU toolchain and some very useful utilities from bash.
You can find how to enable this feature at https://msdn.microsoft.com/en-us/commandline/wsl/install_guide

Or, to use the installer in this repo directly if you've already had windows in Developor Mode.

You can certainly run bash.exe and do all the stuff under bash shell. However, you may want to use some
GNU tools like grep together with native Windows utilites.

For example,
~~~~
    > tasklist /svc | grep -n -i -C 3 dhcp
    27-svchost.exe                   1536 Dnscache
    28:svchost.exe                   1600 **Dhcp**
    29-svchost.exe                   1620 NcbService
~~~~

Yes, you can use something like `findstr` to deal with it. But IMO, grep is a superiorly versatile one to achieve the goal.

To get toolchain like grep, sed, etc to run like natively on cmd.exe, we have some option like:
~~~~
    > doskey grep=bash -c "grep $*"
~~~~
Correct. Nevertheless, you would firstly need to set up AutoRun in your cmd.exe registry path to make this setup permanent.
Second, considering some name conflict like `sort` (GNU sort and Windows sort.exe), this alias makes no use at all.
Third, doskey cannot become a input to be consumed in Powershell (PS). If you use powershell to pipe utilities all the time
like:
~~~~
PS> & program_foo.exe | Out-File -FilePath foo.log
~~~~
You may hope the utilities from bash to be able to directly pipe in PS. And to reach this is straightforward.
By scripting some dummy .cmd bash wrappers and setup a init script to include them in %PATH%, all these tools can be
executed in cmd.exe *like* native ones.

## Tools.json
* name:    the command name you want to map from bash
* args:    the default args you want to put for this command. e.g. ls -l; grep --color=always
* enabled: true/false; to be deployed or not by executing install.cmd

### Example utilities
Some useful tools that have no harm to deploy and extremely useful:
+ grep
+ sed
+ awk

## TODO
- integrate with cmder (https://github.com/cmderdev/cmder) (https://github.com/cmderdev/cmder/releases)
- integrate with clink (https://github.com/mridgers/clink) (https://github.com/mridgers/clink/releases)

