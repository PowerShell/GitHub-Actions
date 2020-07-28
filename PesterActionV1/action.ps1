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
$importedModule = Import-Module @installModParams -PassThru

## Pull in some inputs
$script = Get-ActionInput script -Required

Write-ActionInfo ("running Pester version {0} on '$script'" -f $importedModule.Version)

$logFormat = Get-ActionInput logformat -Required
$logFileName = 'testresults-{0}.xml' -f (New-Guid)
Set-ActionOutput -Name 'logPath' -Value (Join-Path -Path $PWD.ProviderPath  -ChildPath $logFileName)

Write-ActionInfo ("Chosen LogFormat: {0} with filename: {1}" -f $logFormat, $logFileName)

$r = Invoke-Pester -Script $script -PassThru -OutputFormat $logFormat -OutputFile $logFileName

Write-ActionInfo ($r | Format-List Result,ExecutedAt,*Count | Out-String)

if ( $importedModule.Version -ge "5.0.0" ) {
    $result = $r.Result
    $pesterErrors = $r.failed | Format-Table name,@{L="ErrorMessage";E={$_.ErrorRecord.DisplayErrorMessage}} -wrap | out-string
}
else {
    $result = $r.TestResult.Result
    $pesterErrors = $r.TestResult | Format-Table name,@{L="ErrorMessage";E={$_.ErrorRecord.DisplayErrorMessage}} -wrap | out-string
}

if ($result -ne "Passed")
{
    Write-ActionError $message
    Throw "Pester found issues"
}
