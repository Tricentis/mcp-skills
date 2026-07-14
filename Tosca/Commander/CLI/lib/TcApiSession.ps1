#Requires -Version 5.1
<#
.SYNOPSIS
  Load TCAPI.dll / TCAPIObjects.dll from COMMANDER_HOME — no separate program to build.
.DESCRIPTION
  Dot-source this file, then call Connect-TcApi and workspace helpers.
  Uses Add-Type when possible; falls back to reflection. Works across Commander 24.1–26.1.
#>

. (Join-Path $PSScriptRoot 'Get-TcApiRuntime.ps1')

$script:TcApiInstance = $null
$script:TcApiWorkspace = $null
$script:TcApiUseReflection = $false
$script:TcApiAssembly = $null
$script:TcApiType = $null
$script:TcApiCommanderVersion = $null

function Connect-TcApi {
    param(
        [string]$CommanderHome = $env:COMMANDER_HOME,
        [string]$CommanderVersion
    )
    if (-not $CommanderHome) {
        throw 'Set COMMANDER_HOME or pass -CommanderHome'
    }
    $home = $CommanderHome.TrimEnd('\', '/')
    $objectsPath = Join-Path $home 'TCAPIObjects.dll'
    $apiPath = Join-Path $home 'TCAPI.dll'
    if (-not (Test-Path $apiPath)) { throw "TCAPI.dll not found: $apiPath" }
    if (-not (Test-Path $objectsPath)) { throw "TCAPIObjects.dll not found: $objectsPath" }

    $env:COMMANDER_HOME = $home
    $script:TcApiCommanderVersion = Resolve-CommanderVersionForTcApi -CommanderHome $home -ExplicitVersion $CommanderVersion

    try {
        Add-Type -Path $objectsPath -ErrorAction Stop
        Add-Type -Path $apiPath -ReferencedAssemblies $objectsPath -ErrorAction Stop
        $script:TcApiInstance = [Tricentis.TCAPI.TCAPI]::CreateInstance()
        $script:TcApiUseReflection = $false
    }
    catch {
        $script:TcApiUseReflection = $true
        [void][System.Reflection.Assembly]::LoadFrom($objectsPath)
        $script:TcApiAssembly = [System.Reflection.Assembly]::LoadFrom($apiPath)
        $script:TcApiType = $script:TcApiAssembly.GetType('Tricentis.TCAPI.TCAPI')
        if (-not $script:TcApiType) { throw 'Type Tricentis.TCAPI.TCAPI not found in TCAPI.dll' }
        $create = $script:TcApiType.GetMethod('CreateInstance', [Type]::EmptyTypes)
        $script:TcApiInstance = $create.Invoke($null, $null)
        if (-not $script:TcApiInstance) { throw 'TCAPI.CreateInstance returned null' }
    }

    return $script:TcApiInstance
}

function Get-TcApiCommanderVersion {
    return $script:TcApiCommanderVersion
}

function Open-TcApiWorkspace {
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [string]$User = 'Admin',
        [string]$Password = ''
    )
    if (-not $script:TcApiInstance) { throw 'Call Connect-TcApi first' }

    if ($script:TcApiUseReflection) {
        $method = $script:TcApiType.GetMethod(
            'OpenWorkspace',
            [Type[]]@([string], [string], [string])
        )
        if (-not $method) {
            $method = $script:TcApiType.GetMethods() | Where-Object {
                $_.Name -eq 'OpenWorkspace' -and $_.GetParameters().Count -ge 3
            } | Select-Object -First 1
        }
        $script:TcApiWorkspace = $method.Invoke($script:TcApiInstance, @($Path, $User, $Password))
    }
    else {
        $script:TcApiWorkspace = $script:TcApiInstance.OpenWorkspace($Path, $User, $Password)
    }
    if (-not $script:TcApiWorkspace) { throw "OpenWorkspace failed: $Path" }
    return $script:TcApiWorkspace
}

function Get-TcApiActiveWorkspace {
    if ($script:TcApiWorkspace) { return $script:TcApiWorkspace }
    if (-not $script:TcApiInstance) { return $null }

    if ($script:TcApiUseReflection) {
        $prop = $script:TcApiType.GetProperty('ActiveWorkspace')
        return $prop.GetValue($script:TcApiInstance)
    }
    return $script:TcApiInstance.ActiveWorkspace
}

function Get-TcApiProject {
    $workspace = Get-TcApiActiveWorkspace
    if (-not $workspace) { throw 'No workspace open. Call Open-TcApiWorkspace first.' }

    if ($script:TcApiUseReflection) {
        $method = $workspace.GetType().GetMethod('GetProject', [Type]::EmptyTypes)
        return $method.Invoke($workspace, $null)
    }
    return $workspace.GetProject()
}

function Search-TcApi {
    param(
        [Parameter(Mandatory)]
        $Start,
        [Parameter(Mandatory)]
        [string]$Tql
    )
    if ($script:TcApiUseReflection) {
        $method = $Start.GetType().GetMethod('Search', [Type[]]@([string]))
        $result = $method.Invoke($Start, @($Tql))
        if ($null -eq $result) { return @() }
        return @($result)
    }
    return @($Start.Search($Tql))
}

function Save-TcApiWorkspace {
    $workspace = Get-TcApiActiveWorkspace
    if (-not $workspace) { throw 'No workspace open' }

    if ($script:TcApiUseReflection) {
        $save = $workspace.GetType().GetMethod('Save', [Type]::EmptyTypes)
        if (-not $save) { $save = $workspace.GetType().GetMethod('SaveAll', [Type]::EmptyTypes) }
        if ($save) { $save.Invoke($workspace, $null) }
        return
    }
    $workspace.Save()
}

function Close-TcApiWorkspace {
    if (-not $script:TcApiInstance) { return }

    try {
        if ($script:TcApiUseReflection) {
            $closeWs = $script:TcApiType.GetMethod('CloseWorkspace', [Type]::EmptyTypes)
            if ($closeWs) { $closeWs.Invoke($script:TcApiInstance, $null) }
            $closeInstance = $script:TcApiType.GetMethod('CloseInstance', [Type]::EmptyTypes)
            if ($closeInstance) { $closeInstance.Invoke($null, $null) }
        }
        else {
            $script:TcApiInstance.CloseWorkspace()
            [Tricentis.TCAPI.TCAPI]::CloseInstance()
        }
    }
    catch {
        # best-effort shutdown across Commander versions
    }
    finally {
        $script:TcApiWorkspace = $null
        $script:TcApiInstance = $null
    }
}

function Find-TcApiFolder {
    param(
        [Parameter(Mandatory)]
        $Parent,
        [Parameter(Mandatory)]
        [string]$Name
    )
    if ($script:TcApiUseReflection) {
        $itemsProp = $Parent.GetType().GetProperty('Items')
        $items = $itemsProp.GetValue($Parent)
        foreach ($item in $items) {
            $n = $item.GetType().GetProperty('Name').GetValue($item)
            if ($n -eq $Name) { return $item }
        }
        return $null
    }
    return $Parent.Items | Where-Object { $_.Name -eq $Name } | Select-Object -First 1
}

function Format-TcApiObject {
    param([Parameter(Mandatory)] $Object)
    if ($script:TcApiUseReflection) {
        $name = $Object.GetType().GetProperty('Name').GetValue($Object)
        $type = $Object.GetType().Name
        $pathProp = $Object.GetType().GetProperty('NodePath')
        if ($pathProp) {
            $path = $pathProp.GetValue($Object)
            return "${type}:${name} NodePath=${path}"
        }
        return "${type}:${name}"
    }
    if ($Object.NodePath) { return "$($Object.GetType().Name):$($Object.Name) NodePath=$($Object.NodePath)" }
    return "$($Object.GetType().Name):$($Object.Name)"
}
