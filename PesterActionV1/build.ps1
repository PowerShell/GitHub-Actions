
Push-Location -Path $PSScriptRoot
try {
    ncc build .\invoke-pwsh.js -o _init
}
finally {
    Pop-Location
}
