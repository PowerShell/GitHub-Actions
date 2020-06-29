#!/usr/bin/env pwsh

## Load up some common functionality for interacting
## with the GitHub Actions/Workflow environment
$path = Join-Path -Path $PSScriptRoot -ChildPath 'lib/ActionsCore.ps1'
. $path

Write-ActionInfo 'checking for script analyzer module...'
$module = Get-Module -ListAvailable PSScriptAnalyzer
if(!$module) {
    Write-ActionInfo 'installing script analyzer module...'
    $ProgressPreference = 'SilentlyContinue'
    Install-Module PSScriptAnalyzer -Force
}
else{
    Write-ActionInfo 'script analyzer module already installed.'
}

## Pull in some inputs
$script = Get-ActionInput script -Required

Write-ActionInfo "running script analyzer on '$script'"

$r = Invoke-ScriptAnalyzer -Path $script -Recurse

Write-ActionInfo ($r | Out-String)

if($r)
{
    Write-ActionError "Script analyzer found issues"
    Throw "Script analyzer found issues"
}
