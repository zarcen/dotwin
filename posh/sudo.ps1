# simulate linux sudo

$usagemsg=@"
    Usage: sudo <executable> [options/args]

    Example: sudo regedit
             sudo notepad
"@

if ($args.Length -eq 1) {
    if ($args[0] -eq "/?") {
        Write-Output $usagemsg
        exit
    }
    start-process $args[0] -verb "runAs"
} 
elseif ($args.Length -gt 1) {
    start-process $args[0] -ArgumentList $args[1..$args.Length] -verb "runAs"
}
else {
    Write-Output $usagemsg
}

<#
-> [bool] - Cast the end result to a bool.
-> [System.Security.Principal.WindowsIdentity]::GetCurrent() - Retrieves the WindowsIdentity for the currently running user.
-> (...).groups - Access the groups property of the identity to find out what user groups the identity is a member of.
-> -match 'S-1-5-32-544' checks to see if groups contains the Well Known SID of the Administrators group, 
   the identity will only contain it if 'run as administrator' was used.
#>
function Test-If-Admin {
    [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
}