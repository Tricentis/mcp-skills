# Inline TCAPI — paste in terminal after setting paths below.

$env:COMMANDER_HOME = 'C:\Program Files\Tricentis\Tosca\Commander'
$tws = 'C:\Projects\Demo.tws'

Add-Type -Path "$env:COMMANDER_HOME\TCAPIObjects.dll"
Add-Type -Path "$env:COMMANDER_HOME\TCAPI.dll"

$api = [Tricentis.TCAPI.TCAPI]::CreateInstance()
$ws = $api.OpenWorkspace($tws, 'Admin', '')
$project = $ws.GetProject()

$project.Search('=>SUBPARTS:TestCase[Name~\"Login\"]') | ForEach-Object {
    Write-Output "$($_.Name)  $($_.NodePath)"
}

$ws.Save()
$api.CloseWorkspace()
