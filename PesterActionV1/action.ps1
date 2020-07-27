#!/usr/bin/env pwsh

## Load up some common functionality for interacting
## with the GitHub Actions/Workflow environment
$path = Join-Path -Path $PSScriptRoot -ChildPath 'lib/ActionsCore.ps1'
. $path

# replace with parameter/configuration when available 
# $Version = Get-ActionInput Version -Required
$Version = "5.0.2"

Write-ActionInfo 'checking for Pester module...'
$modules = Get-Module -ListAvailable -Name Pester
$neededVersion = $modules | Where-Object { $_.Version -eq ${Version} }
if ( $neededVersion ) {
    Write-ActionInfo 'Pester module already installed.'
}
else{
    Write-ActionInfo 'installing Pester module version ${Version}...'
    $ProgressPreference = 'SilentlyContinue'
    Install-Module Pester -Force -RequiredVersion ${Version}
}
# Don't rely on autoloading
if ( Get-Module -Name Pester -ErrorAction Ignore ) {
    Remove-Module Pester
    Import-Module Pester -Force -RequiredVersion ${Version}
}

## Pull in some inputs
$script = Get-ActionInput script -Required

Write-ActionInfo "running Pester on '$script'"

$r = Invoke-Pester -Script $script -PassThru

Write-ActionInfo ($r | Format-List Result,ExecutedAt,*Count | Out-String)

if($r.Result -ne "Passed")
{
    $message = $r.failed | ft name,@{L="ErrorMessage";E={$_.ErrorRecord.DisplayErrorMessage}} -wrap | out-string
    Write-ActionError $message
    Throw "Pester found issues"
}
