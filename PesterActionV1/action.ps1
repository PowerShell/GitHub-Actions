#!/usr/bin/env pwsh

## Load up some common functionality for interacting
## with the GitHub Actions/Workflow environment
$path = Join-Path -Path $PSScriptRoot -ChildPath 'lib/ActionsCore.ps1'
. $path

# replace with parameter/configuration when available
$Version = Get-ActionInput Version

$installModParams = @{ Name = 'Pester'; Force = $true }

if ($Version) {
    $installModParams.Add('RequiredVersion', $Version)
}

Write-ActionInfo 'checking for Pester module...'
# find out if pester is installed and what the versions are
# if the version is specified and doesn't exist, we'll need to install it
# if the version is not specified and pester is installed we'll use what's installed
$modules = Get-Module -ListAvailable Pester
$requiredPester = $null
if ( $Version ) {
    $requiredPester = $modules | Where-Object {$_.Version -eq $Version}
}
else {
    $requiredPester = $modules | Sort-Object Version | Select-Object -Last 1
}

if ( $requiredPester ) {
    Write-ActionInfo ('Pester module version {0} already installed.' -f $requiredPester.Version)
}
else {
    # if version is provided we'll get it, otherwise we get what we get
    Write-ActionInfo 'installing Pester module {0}...' -f "version: ${version}"
    $ProgressPreference = 'SilentlyContinue'
    Install-Module @installModParams
}

# Don't rely on autoloading
Import-Module @installModParams

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
