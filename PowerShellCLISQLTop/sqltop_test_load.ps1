$Clients = 20
Write-Host "Running with $Clients concurrent connections..."
$RunspacePool = [RunspaceFactory]::CreateRunspacePool(1, $Clients)
$RunspacePool.Open()

$ScriptBlock = {
    param(
        [switch]$Warehouse = $false
    )

    if ( -not $Warehouse ) {
        $Applications = @(
            'FleetTracker 5000'
        )

        $Hosts = @(
            'SRV',
            'TRK'
        )

        $Queries = @(
            'EXEC dbo.UpdateRandomVehicleLocation',
            'EXEC dbo.UpdateRandomVehicleMiles'
        )
    } else {
        $Applications = @('Warehouse')
        $Hosts = @('REPORT')
        $Queries = @('EXEC dbo.WarehouseReport01')
    }

    Invoke-Sqlcmd  -ServerInstance localhost `
                   -Database FleetTracking `
                   -Username sa `
                   -Password "1ontsurt!" `
                   -HostName "PROD-$($Hosts | Get-Random)-$(Get-Random -Maximum 99 -Minimum 10)" `
                   -Query $($Queries | Get-Random) `
                   -ApplicationName "$($Applications | Get-Random)"
                        
}

Write-Host "Starting executions..."
$Runspaces = @()
(1..10000) | ForEach-Object {
    Write-Host "." -NoNewline
    if ( $_ -eq 250 ) {
        Write-Host "W" -NoNewline
        $params = @{ 'Warehouse' = $true }
    } else {
        $params = @{ 'Warehouse' = $false }
    }
    $Runspace = [powershell]::Create().AddScript($ScriptBlock).AddParameters($params)
    $Runspace.RunspacePool = $RunspacePool
    $Runspaces += New-Object PSObject -Property @{
        Runspace = $Runspace
        State = $Runspace.BeginInvoke()
    }
}


Write-Host "`nWaiting for executions to finish..."
while ( $Runspaces.State.IsCompleted -contains $False) {
    Start-Sleep -Milliseconds 10
    if($global:Host.UI.RawUI.KeyAvailable) {
        $key = $($global:Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")).character
        if ( $key -eq 'x' ) {
            Write-Host "EXITTNG NOW!!!"
            $Runspaces | % { 
                $_.Runspace.Stop(); 
                $_.Runspace.Dispose()
            }
            $RunspacePool.Close()
            exit
        }
    }
}

$Results = @()

$Runspaces | ForEach-Object {
    $Results += $_.Runspace.EndInvoke($_.State)
}

$RunspacePool.Close()

$Results