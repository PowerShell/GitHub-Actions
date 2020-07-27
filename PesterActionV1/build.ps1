[CmdletBinding(DefaultParameterSetName='build')]
param(
    [parameter(ParameterSetName='bootstrap',Mandatory)]
    [switch]
    $Bootstrap,
    [parameter(ParameterSetName='build')]
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
        npm i -g @zeit/ncc
    }
    default {
        throw "Unknow parameterset $($pscmdlet.ParameterSetName)"
    }
}
