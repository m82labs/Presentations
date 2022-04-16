# Create hashtables
$RunspaceHash = @{}
$Hash = @{}

# Add some data to the hashtable
$RunspaceHash.Data = "Hello"
$Hash.Data = "Hello"

# Append data to both
$Script = {
    $RunspaceHash.Data += " World"
    $Hash.Data += " World"
}

# Set up our runspace
$Runspace = [runspacefactory]::CreateRunspace()
$Runspace.Open()
$Runspace.SessionStateProxy.SetVariable("RunspaceHash",$RunspaceHash)

# Add our scriptblock
$Session = [powershell]::Create().AddScript($Script)
$Session.Runspace = $Runspace

# Run it!
$Session.Invoke()

# See the results
$RunspaceHash
$Hash
