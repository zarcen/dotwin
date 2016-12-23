# Install the bash wrapper scripts according to tools.json
@"
:: To use the mapping, firstly you need to enable the Windows Feature,
:: "Windows Subsystem for Linux", supported from Windows 10 Redstone.
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
$DOTWIN_ALIAS="$DOTWINPATH\alias.cmd"
$TOOLJSON="tools.json"

Write-Host $args.Length
# Loading the list of tools to map from bash in this json file
$toolsjson = ConvertFrom-Json -InputObject (Get-Content tools.json -Raw)

If(!(test-path $DOTWINBASHEE)) {
    New-Item -ItemType Directory -Force -Path $DOTWINBASHEE
}

foreach($t in $toolsjson.tools) {
    $WrapperCmd="bash -c `"$($t.name) $($t.args) %*`""
    $DupAlert=""
    if (Get-Command $t.name -ErrorAction SilentlyContinue) {
        $DupAlert="::There is name conflict in your system. Use $($t.name).cmd to distinguish the bash one"
    }
    # Generating a dumb .cmd file to cheat $PATH
    # Why not appending to alias.cmd as doskey mapping? Because .cmd file can be consumed in powershell
    # like "PS> & grep ...", which is awesome!
    ":: $($t.name).cmd`n$DupAlert`n@echo off`n$WrapperCmd" | Out-File -FilePath "$DOTWINBASHEE\$($t.name).cmd" -Encoding default
    
    # If prefer using doskey instead of generating wrapper .cmd files, uncomment the following line 
    #":: $($t.name).cmd`ndoskey $($t.name)=$WrapperCmd" | Out-File -FilePath $DOTWIN_ALIAS -Encoding default -Append
}

#TODO: check Computer\HKEY_CURRENT_USER\Software\Microsoft\Command Processor and install init.cmd into
#      registry value (AutoRun) as %USERPROFILE%\dotwin\init.cmd