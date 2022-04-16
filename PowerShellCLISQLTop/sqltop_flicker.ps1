#### The flicker issue
$RefreshMS = 200
While($True) {
    Clear-Host
    Get-Process | Sort-Object -Property CPU -Descending `
                | Select-Object -First 10 `
                | Out-String
    Start-Sleep -Milliseconds $RefreshMS
}

#### No more flicker
# - Don't clear the host, just draw over what was there
#   - Reset text cursor to 0,0
#   - Draw blanks to fill the screen
#   - Reset the cursor again
#   - Write out the data we want to see
# - Hide the cursor just before redraw, this removes flickering artifacts as the
#   cursor moves
# - Storing the output in a variable first cuts out "processing" time in the
#   middle of the draw
Clear-Host
$RefreshMS = 200
While($True) {
    # Store the output in a string, this is sort of like "double-buffering"
    $output = Get-Process | Sort-Object -Property CPU -Descending `
                          | Select-Object -First 10 `
                          | Out-String
    [Console]::CursorVisible = $False
    # Reset the cursor to the top left corner
    $host.UI.RawUI.CursorPosition = @{X=0;Y=0}
    # Draw spaces over the data that is already there 
    # (based on the number of lines displayed * the width of the window)
    $blanks = ' '.PadRight(12 * ($host.UI.RawUI.WindowSize.Width))
    [Console]::Write($blanks)
    # Reset the cursor again
    $host.UI.RawUI.CursorPosition = @{X=0;Y=0}
    # Finally send the output to the screen
    [Console]::Write($output)
    [Console]::CursorVisible = $True
    Start-Sleep -Milliseconds $RefreshMS
}
Clear-Host