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
::         > sort      // depends on how PATH is configured (See init.cmd)
"@

$DOTWINPATH="$Env:USERPROFILE\dotwin"
$DOTWINBASHEE="$DOTWINPATH\bashee"
$DOTWININIT="$DOTWINPATH\init.cmd"
$DOTWINALIAS="$DOTWINPATH\alias.cmd"
$DOTWINTOOLJSON="$DOTWINPATH\tools.json"
$CmdRegPath="HKCU:\Software\Microsoft\Command Processor"

function Deploy-Bashee {
    $title = "Action for bash wrapper scripts in .\bashee"
    $message = "Install or Uninstall(Clear) bash wrapper scripts in .\bashee?"
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Install", `
        "Install bash wrapper scripts based on $DOTWINTOOLJSON in $DOTWINBASHEE"
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&Clear", `
        "Clear wrapper script files in $DOTWINBASHEE"

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

    $result = $host.ui.PromptForChoice($title, $message, $options, 0)
    switch ($result) {
        0 {
            "You selected `"Install`"."
        }
        1 {
            "You selected `"Clear`"."
            Remove-Item -Recurse -Force $DOTWINBASHEE
            "Deleted $DOTWINBASHEE"
            exit
        }
    }
    # Loading the list of tools to map from bash in this json file
    $toolsjson = ConvertFrom-Json -InputObject (Get-Content $DOTWINTOOLJSON -Raw)

    # Install bash wrapper script in the bashee folder
    "Installing bash wrapper scripts...`n"
    "`tSource     : $DOTWINTOOLJSON"
    "`tDestination: $DOTWINBASHEE`n"
    if (!(Test-Path $DOTWINBASHEE)) {
        New-Item -ItemType Directory -Force -Path $DOTWINBASHEE
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
        ":: $($t.name).cmd`n$DupAlert`n@echo off`n$WrapperCmd" | Out-File -FilePath "$DOTWINBASHEE\$($t.name).cmd" -Encoding default
        "Generated {0, -10}: {1, -50}" -f $($t.name), "$DOTWINBASHEE\$($t.name).cmd"

        # If prefer using doskey instead of generating wrapper .cmd files, uncomment the following line 
        #":: $($t.name).cmd`ndoskey $($t.name)=$WrapperCmd" | Out-File -FilePath $DOTWINALIAS -Encoding default -Append
    }
}

function Deploy-Cmd-AutoRun-Regpath {
    $title = "AutoRun script when starting cmd.exe"
    $message = "Do you want to add $DOTWININIT as the startup AutoRun script of cmd.exe?"
    $add = New-Object System.Management.Automation.Host.ChoiceDescription "&Add", `
        "Add registry value, $CmdRegPath\AutoRun, as $DOTWININIT"
    $delete = New-Object System.Management.Automation.Host.ChoiceDescription "&Delete", `
        "Delete registry value, $CmdRegPath\AutoRun"
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($add, $delete)

    $result = $host.ui.PromptForChoice($title, $message, $options, 0) 
    switch ($result) {
        0 {
            "You selected `"Add`"."
            # Install init.cmd as startup script of cmd.exe in its registry path
            if (Test-Path $CmdRegPath) {
                New-ItemProperty -Path $CmdRegPath -Name "AutoRun" `
                    -Value $DOTWININIT -PropertyType String -Force
            }
            else {
                Out-Host "Installed failed due to invalid cmd.exe registry path"
            }
        }
        1 {
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

function Enable-Subsystem-Linux {
    $title = "Enable the Windows Subsystem for Linux feature (This requires Admin Access and Machine Reboot)"
    $message = "Do you want to enable the Windows Subsystem for Linux feature?"
    $skip = New-Object System.Management.Automation.Host.ChoiceDescription "&Skip", `
        "Skip this step"
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Enable", `
        "Update $CmdRegPath\AutoRun as $DOTWININIT"
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

