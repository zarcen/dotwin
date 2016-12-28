:: grep.cmd
::There is name conflict in your system. Use grep.cmd to distinguish the bash one
@echo off
bash -c "grep --color=always %*"
