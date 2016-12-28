:: ifconfig.cmd
::There is name conflict in your system. Use ifconfig.cmd to distinguish the bash one
@echo off
bash -c "ifconfig  %*"
