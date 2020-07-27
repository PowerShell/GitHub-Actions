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

        $sb = [scriptblock]::Create("$sudoCmd npm i -g @zeit/ncc ")
        Invoke-Expression -Command $sb
    }
    default {
        throw "Unknow parameterset $($pscmdlet.ParameterSetName)"
    }
}
