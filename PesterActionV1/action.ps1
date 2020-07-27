#!/usr/bin/env pwsh

## Load up some common functionality for interacting
## with the GitHub Actions/Workflow environment
$path = Join-Path -Path $PSScriptRoot -ChildPath 'lib/ActionsCore.ps1'
. $path

Write-ActionInfo 'checking for Pester module...'
$module = Get-Module -ListAvailable Pester
if(!$module) {
    Write-ActionInfo 'installing Pester module...'
    $ProgressPreference = 'SilentlyContinue'
    Install-Module Pester -Force
}
else{
    Write-ActionInfo 'Pester module already installed.'
}

## Pull in some inputs
$script = Get-ActionInput script -Required

Write-ActionInfo "running Pester on '$script'"

$r = Invoke-Pester -Script $script -PassThru

Write-ActionInfo ($r | Out-String)

if($r)
{
    Write-ActionError "Pester found issues"
    Throw "Pester found issues"
}
