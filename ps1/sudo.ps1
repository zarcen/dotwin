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
