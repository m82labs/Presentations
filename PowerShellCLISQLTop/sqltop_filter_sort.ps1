## SAME OLD STUFF ##
# Create a synchronized hashtable
$StateData = [System.Collections.Hashtable]::Synchronized(@{})
$Stop = $False
# Add some data to the hashtable
$StateData.HasData = $False

# Set up our runspace
$Runspace = [runspacefactory]::CreateRunspace()
$Runspace.Open()
$Runspace.SessionStateProxy.SetVariable("StateData",$StateData)

# Alter the hashtable in a runspace
$Sb = {
    while($True) {
        Start-Sleep -Seconds 2
        $StateData.Data = Get-Process
        $StateData.HasData = $True
    }
}

$Session = [PowerShell]::Create()
$Session.Runspace = $Runspace
$null = $Session.AddScript($Sb)
$Handle = $Session.BeginInvoke()

## THIS IS NEW! ##
# Set the default sort/columns
$View = 'CPU'

# Set up sorting options
$SortOptions = @{
    'Threads' = @(
        @{
            Expression={$_.Threads.Count}
            Descending=$True
        },
        'CPU'
    )
    'CPU' = @(
        @{
            Expression={$_.CPU}
            Descending=$True
        }
    )
}

$DisplayOptions = @{  # <<= CAVEAT: You have to include ALL columns you want displayed, and could lose some nice formatting
    'Threads' = @(
        @{
            Name='Thread Count'
            Expression={$_.Threads.Count}
        },
        'CPU',
        'Id',
        'Name'
    )
}

Clear-Host
[Console]::CursorVisible = $False # <<== This particlular app needs no cursor
while(-not $Stop) {
    # Had to add some logic to allow re-draw to smooth out menu transitions
    $Start = Get-Date
    if ( $StateData.HasData -or $Redraw ) {
         $Result = $StateData.Data  | Sort-Object -Property $SortOptions.$View `
                                    | Select-Object -First 10 `
                                    | Format-Table -Property $DisplayOptions.$View `
                                    | Out-String
         # Reset HasData
         $StateData.HasData = $False
         # Reset Redraw
         $Redraw = $False
    }
    
    # Reset the cursor to the top left corner
    $host.UI.RawUI.CursorPosition = @{X=0;Y=0}
    # Draw spaces over the data that is already there (based on the number of lines displayed * the width of the window)
    $blanks = ' '.PadRight(13 * ($host.UI.RawUI.WindowSize.Width))
    [Console]::Write($blanks)
    # Reset the cursor again
    $host.UI.RawUI.CursorPosition = @{X=0;Y=0}
    # Finally send the output to the screen
    [Console]::Write($Result)
    [Console]::Write("Render time (ms): $(((Get-Date) - $Start).TotalMilliseconds)`n")

    Write-Host "Press 'q' to quit, 'c' to sort by CPU, and 't' to sort by thread count." -NoNewLine
   
    if($global:Host.UI.RawUI.KeyAvailable) {
        $key = $($global:Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")).character
        if ( $key -eq 'q' ) {
            $Stop = $True
            $Session.Stop()
            $Runspace.Dispose()
        } elseif ( $key -eq 'c' ) {
            $View = 'CPU'
            $Redraw = $True
            Clear-Host
        } elseif ( $key -eq 't' ) {
            $View = 'Threads'
            $Redraw = $True
            Clear-Host
        }
    }
    Start-Sleep -Milliseconds 50
}