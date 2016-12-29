# Install the bash wrapper scripts according to tools.json

#Write-Host $args.Length
@"
:: ***** Install Helper of dotwin *****
:: Description: wrapping tools from bash to natively run on cmd.exe
:: 
:: To use the bash wrappers, firstly you need to enable the Windows Feature,
:: "Windows Subsystem for Linux", supported from Windows 10 Redstone.
::
:: Installation Guide:
::     https://msdn.microsoft.com/en-us/commandline/wsl/install_guide
::
:: The doskey mapping from Windows Subsystem for Linux could be
:: overwritten by existing command in Windows. Instead, create a .cmd
:: file as a wrapper.
:: e.g. If you've installed git on Windows, git.cmd is created and put
:: under `$PATH to give you some flexibility to choose which to use.
::
:: Usecases: 
::         > sort.cmd  // using GNU sort
::         > sort.exe  // using Win32 sort
::         > sort      // depends on how PATH is configured (See dotwin.cmd)
"@

$DotwinRoot="$Env:USERPROFILE\dotwin"
$DotwinBashee="$DotwinRoot\bashee"
$DotwinInit="$DotwinRoot\dotwin.cmd"
$DotwinAlias="$DotwinRoot\alias.cmd"
$DotwinConfigJson="$DotwinRoot\tools.json"
$CmdRegPath="HKCU:\Software\Microsoft\Command Processor"

function Deploy-Bashee {
    $title = "Action for bash wrapper scripts in .\bashee"
    $message = "Install or Uninstall(Clear) bash wrapper scripts in .\bashee?"
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Install", `
        "Install bash wrapper scripts based on $DotwinConfigJson in $DotwinBashee"
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&Clear", `
        "Clear wrapper script files in $DotwinBashee"

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

    $result = $host.ui.PromptForChoice($title, $message, $options, 0)
    switch ($result) {
        0 {
            "You selected `"Install`"."
        }
        1 {
            "You selected `"Clear`"."
            Remove-Item -Recurse -Force $DotwinBashee
            "Deleted $DotwinBashee"
            exit
        }
    }
    # Loading the list of tools to map from bash in this json file
    $toolsjson = ConvertFrom-Json -InputObject (Get-Content $DotwinConfigJson -Raw)

    # Install bash wrapper script in the bashee folder
    "Installing bash wrapper scripts...`n"
    "`tSource     : $DotwinConfigJson"
    "`tDestination: $DotwinBashee`n"
    if (!(Test-Path $DotwinBashee)) {
        New-Item -ItemType Directory -Force -Path $DotwinBashee
    }
    foreach($t in $toolsjson.tools) {
        if (!$t.enabled)  {
            continue
        }
        $WrapperCmd="bash -c `"$($t.name) $($t.args) %*`""
        $DupAlert=""
        if (Get-Command $t.name -ErrorAction SilentlyContinue) {
            $DupAlert="::There is name conflict in your system. Use $($t.name).cmd to distinguish the bash one"
        }
        # Generating a dumb .cmd file to cheat $PATH
        # Why not appending to alias.cmd as doskey mapping? Because .cmd file can be consumed in powershell
        # like "PS> & grep ...", which is awesome!
        ":: $($t.name).cmd`n$DupAlert`n@echo off`n$WrapperCmd" | Out-File -FilePath "$DotwinBashee\$($t.name).cmd" -Encoding default
        "Generated {0, -10}: {1, -50}" -f $($t.name), "$DotwinBashee\$($t.name).cmd"

        # If prefer using doskey instead of generating wrapper .cmd files, uncomment the following line 
        #":: $($t.name).cmd`ndoskey $($t.name)=$WrapperCmd" | Out-File -FilePath $DotwinAlias -Encoding default -Append
    }
}

function Deploy-Cmd-AutoRun-Regpath {
    $title = "AutoRun script when starting cmd.exe"
    $message = "Do you want to add $DotwinInit as the startup AutoRun script of cmd.exe?"
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
        "Skip the step (Recommended. AutoRun could corrupt some self-defined utilities.)"
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
        "Add dotwin into registry value, $CmdRegPath\AutoRun"
    $delete = New-Object System.Management.Automation.Host.ChoiceDescription "&Delete", `
        "Delete registry value, $CmdRegPath\AutoRun, if it exists"
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($no, $yes, $delete)

    $result = $host.ui.PromptForChoice($title, $message, $options, 0) 
    switch ($result) {
        0 {
            "You selected `"No`"."
        }
        1 {
            "You selected `"Yes`"."
            # Install init.cmd as startup script of cmd.exe in its registry path
            if (Test-Path $CmdRegPath) {
                New-ItemProperty -Path $CmdRegPath -Name "AutoRun" `
                    -Value $DotwinInit -PropertyType String -Force
            }
            else {
                Out-Host "Installed failed due to invalid cmd.exe registry path"
            }
        }
        2 {
            "You selected `"Delete`"."
            $existed = (Get-ItemProperty $CmdRegPath).AutoRun -ne $null 
            if ($existed -eq $True) {
                Remove-ItemProperty -Path $CmdRegPath -Name AutoRun -Force
                "Deleted registry value, $CmdRegPath\AutoRun"
            }
            else {
                Write-Host "The value does not exist"
            }
        }
    }
}

function Deploy-Dotwin-Shortcut {
    # First, create a local shortcut
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$DotwinRoot\dotwin.lnk")
    $Shortcut.TargetPath = "cmd.exe"
    $Shortcut.Arguments = "/k `"$DotwinInit & cd %USERPROFILE%`""
    $Shortcut.Save()
    
    $title = "Create a shortcut in start menu for dotwin.cmd"
    $message = "Do you want to create a shortcut in start menu for dotwin.cmd?"
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
        "Create a shortcut of $DotwinInit in startmenu"
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
        "Skip the step"
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

    $result = $host.ui.PromptForChoice($title, $message, $options, 0) 
    switch ($result) {
        0 {
            "You selected `"Yes`"."
            Copy-Item $DotwinRoot\dotwin.lnk "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
            "The shortcut is established in $env:APPDATA\Microsoft\Windows\Start Menu\Programs"
            "You should be able to find it in start menu or run `'start dotwin`' in cmd.exe"
        }
        1 {
            "You selected `"No`"."
        }
    }
}

function Enable-Subsystem-Linux {
    $title = "Enable the Windows Subsystem for Linux feature (This requires Admin Access and Machine Reboot)"
    $message = "Do you want to enable the Windows Subsystem for Linux feature?"
    $skip = New-Object System.Management.Automation.Host.ChoiceDescription "&Skip", `
        "Skip this step"
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Enable", `
        "Update $CmdRegPath\AutoRun as $DotwinInit"
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&Disable", `
        "Stop registry updating"
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($skip, $yes, $no)

    $result = $host.ui.PromptForChoice($title, $message, $options, 0) 
    switch ($result) {
        0 {
            "You selected `"Skip`"."
        }
        1 {
            "You selected `"Enable`"."
            $arglist = "-C","Enable-WindowsOptionalFeature","-Online","-FeatureName","Microsoft-Windows-Subsystem-Linux"
            start-process "powershell.exe" -ArgumentList $arglist -verb "runAs"
        }
        2 {
            "You selected `"Disable`"."
            $arglist = "-C","Disable-WindowsOptionalFeature","-Online","-FeatureName","Microsoft-Windows-Subsystem-Linux"
            start-process "powershell.exe" -ArgumentList $arglist -verb "runAs"
        }
    }
}

Enable-Subsystem-Linux
Deploy-Cmd-AutoRun-Regpath
Deploy-Bashee
Deploy-Dotwin-Shortcut
"`nStart using dotwin by click the shortcut `'dotwin`'"