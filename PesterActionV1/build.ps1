[CmdletBinding(DefaultParameterSetName = 'build')]
param(
    [parameter(ParameterSetName = 'bootstrap', Mandatory)]
    [switch]
    $Bootstrap,
    [parameter(ParameterSetName = 'bootstrap')]
    [switch]
    $Sudo,
    [parameter(ParameterSetName = 'build')]
    [switch]
    $Build

)

# this function wraps native command Execution
# for more information, read https://mnaoumov.wordpress.com/2015/01/11/execution-of-external-commands-in-powershell-done-right/
function script:Start-NativeExecution
{
    param(
        [scriptblock]$ScriptBlock,
        [switch]$IgnoreExitcode,
        [switch]$VerboseOutputOnError
    )
    $backupEAP = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        if($VerboseOutputOnError.IsPresent)
        {
            $output = & $ScriptBlock 2>&1
        }
        else
        {
            & $ScriptBlock
        }

        # note, if $ScriptBlock doesn't have a native invocation, $LASTEXITCODE will
        # point to the obsolete value
        if ($LASTEXITCODE -ne 0 -and -not $IgnoreExitcode) {
            if($VerboseOutputOnError.IsPresent -and $output)
            {
                $output | Out-String | Write-Verbose -Verbose
            }

            # Get caller location for easier debugging
            $caller = Get-PSCallStack -ErrorAction SilentlyContinue
            if($caller)
            {
                $callerLocationParts = $caller[1].Location -split ":\s*line\s*"
                $callerFile = $callerLocationParts[0]
                $callerLine = $callerLocationParts[1]

                $errorMessage = "Execution of {$ScriptBlock} by ${callerFile}: line $callerLine failed with exit code $LASTEXITCODE"
                throw $errorMessage
            }
            throw "Execution of {$ScriptBlock} failed with exit code $LASTEXITCODE"
        }
    } finally {
        $ErrorActionPreference = $backupEAP
    }
}

switch ($PSCmdlet.ParameterSetName) {
    'build' {
        Push-Location -Path $PSScriptRoot
        try {
            $scripPath = (Resolve-Path .\invoke-pwsh.js).ProviderPath
            ncc build $scripPath -o _init
        }
        finally {
            Pop-Location
        }
    }
    'bootstrap' {
        $sudoCmd = ''
        if ($Sudo.IsPresent) {
            $sudoCmd = 'sudo'
        }

        $ScriptBlock = [scriptblock]::Create("$sudoCmd npm i -g @zeit/ncc ")
        Start-NativeExecution -ScriptBlock $ScriptBlock
    }
    default {
        throw "Unknow parameterset $($pscmdlet.ParameterSetName)"
    }
}
