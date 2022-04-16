function color {
    param (
        $Text,
        $ForegroundColor = 'default',
        $BackgroundColor = 'default'
    )
    # Terminal Colors
    $Colors = @{
        "default" = @(40,50)
        "black" = @(30,0)
        "lightgrey" = @(33,43)
        "grey" = @(37,47)
        "darkgrey" = @(90,100)
        "red" = @(91,101)
        "darkred" = @(31,41)
        "green" = @(92,102)
        "darkgreen" = @(32,42)
        "yellow" = @(93,103)
        "white" = @(97,107)
        "brightblue" = @(94,104)
        "darkblue" = @(34,44)
        "indigo" = @(35,45)
        "cyan" = @(96,106)
        "darkcyan" = @(36,46)
    }

    if ( $ForegroundColor -notin $Colors.Keys -or $BackgroundColor -notin $Colors.Keys) {
        Write-Error "Invalid color choice!" -ErrorAction Stop
    }

    "$([char]27)[$($colors[$ForegroundColor][0])m$([char]27)[$($colors[$BackgroundColor][1])m$($Text)$([char]27)[0m"    
}


Write-Host "$(color "Hey" "green") folks!"