# Wait for a keypress while doing stuff WITHOUT BLOCKING
while ( -not $Global:Host.UI.RawUI.KeyAvailable ) {
    Write-Host "." -NoNewline
    Start-Sleep -Milliseconds 100
}
$key = $Global:Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") # Blocks!
Write-Host "`nYou pressed:`n$($key | Out-String)"

# Get keycodes
$Stop = $False
while( -not $Stop ) {
    $key = $Global:Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")
    Clear-Host
    $key | Out-String

    if ( $key.Character -eq 'q' ) { 
        $Stop = $True
    }

    Start-Sleep -Milliseconds 15
}

# Press ANY key
Write-Host "Press any key to continue..."; $Global:Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") | Out-Null

# Wait for escape key
Clear-Host
Write-Host "Press ESCAPE to contiue..."
while( $Global:Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp").VirtualKeyCode -ne 27 ) {
    Write-Host "Press ESCAPE to contiue..."
}
