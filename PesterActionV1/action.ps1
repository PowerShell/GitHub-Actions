#!/usr/bin/env pwsh

## Load the common function helper module for interacting
## with the GitHub Actions/Workflow environment
Import-Module -Name "$PSScriptRoot/lib/ActionsCore.psm1"

# replace with parameter/configuration when available
$Version = Get-ActionInput Version

$installModParams = @{ Name = 'Pester'; Force = $true }

if ($Version) {
    $installModParams.Add('RequiredVersion', $Version)
}

Write-ActionInfo 'checking for Pester module...'
$module = Get-Module -ListAvailable Pester
if (!$module -and $module.Version -ne ${Version} ) {
    Write-ActionInfo 'installing Pester module...'
    $ProgressPreference = 'SilentlyContinue'
    Install-Module @installModParams
}
else {
    Write-ActionInfo 'Pester module already installed.'
}
# Don't rely on autoloading
Import-Module Pester -Force -RequiredVersion ${Version}

## Pull in some inputs
$script = Get-ActionInput script -Required

Write-ActionInfo "running Pester on '$script'"

$r = Invoke-Pester -Script $script -PassThru

Write-ActionInfo ($r | Format-List Result,ExecutedAt,*Count | Out-String)

if ($r.Result -ne "Passed")
{
    $message = $r.failed | ft name,@{L="ErrorMessage";E={$_.ErrorRecord.DisplayErrorMessage}} -wrap | out-string
    Write-ActionError $message
    Throw "Pester found issues"
}
