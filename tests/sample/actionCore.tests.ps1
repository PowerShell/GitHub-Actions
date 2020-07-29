# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

Import-Module -Name 'PesterActionV1\lib\ActionsCore.psm1'

Describe "Send-ActionVariable" {
    it "Contructs command string correctly" {
        Set-ActionVariable "name" "value" | Should -Be "::set-env name=name::value$([System.Environment]::NewLine)"
        Set-ActionVariable "name" "value" -SkipLocal | Should -Be "::set-env name=name::value$([System.Environment]::NewLine)"
    }
    it "Sets environment variable with no SkipLocal flag" {
        [System.Environment]::SetEnvironmentVariable("name", $null)
        Set-ActionVariable "name" "value" 
        [System.Environment]::GetEnvironmentVariable("name") | Should -Be "value"
    }
    it "Does not set environment variable with SkipLocal flag" {
        [System.Environment]::SetEnvironmentVariable("name", $null)
        Set-ActionVariable "name" "value" -SkipLocal 
        [System.Environment]::GetEnvironmentVariable("name") | Should -Be $null
    }
}

Describe "Add-ActionSecretMask" {
    it "Contructs command string correctly" {
        Add-ActionSecretMask "secret" | Should -Be "::add-mask::secret$([System.Environment]::NewLine)"
    }
}

Describe "Add-ActionPath" {
    it "Contructs command string correctly" {
        $oldPath = [System.Environment]::GetEnvironmentVariable('PATH')
        Add-ActionPath "path" | Should -Be "::add-path::path$([System.Environment]::NewLine)"
        Add-ActionPath "path" -SkipLocal | Should -Be "::add-path::path$([System.Environment]::NewLine)"
   
        # restore old path var
        [System.Environment]::SetEnvironmentVariable('PATH', $oldPath)
    }
    it "Sets environment path variable with no SkipLocal flag" {
        $oldPath = [System.Environment]::GetEnvironmentVariable('PATH')
        
        Add-ActionPath "path"
        [System.Environment]::GetEnvironmentVariable('PATH') | Should -Be "path$([System.IO.Path]::PathSeparator)$oldPath"

        # restore old path var
        [System.Environment]::SetEnvironmentVariable('PATH', $oldPath)
    }
    it "Does not set environment path variable with SkipLocal flag" {
        $oldPath = [System.Environment]::GetEnvironmentVariable('PATH')
        
        Add-ActionPath "path" -SkipLocal
        [System.Environment]::GetEnvironmentVariable('PATH') | Should -Be $oldPath
      
        # restore old path var
        [System.Environment]::SetEnvironmentVariable('PATH', $oldPath)
    }
}

Describe "Set-ActionOutput" {
    it "Contructs command string correctly" {
        Set-ActionOutput "name" "value" | Should -Be "::set-output name=name::value$([System.Environment]::NewLine)"
    }
}

Describe "Write-Action" {
    it "Contructs debug command string correctly" {
        Write-ActionDebug "message" | Should -Be "::debug::message$([System.Environment]::NewLine)"
    }

    it "Contructs error command string correctly" {
        Write-ActionError "message" | Should -Be "::error::message$([System.Environment]::NewLine)"
    }

    it "Contructs warning command string correctly" {
        Write-ActionWarning "message" | Should -Be "::warning::message$([System.Environment]::NewLine)"
    }

    it "Contructs info command string correctly" {
        Write-ActionInfo "message" | Should -Be "message$([System.Environment]::NewLine)"
    }
}

Describe "ActionOutputGroup" {
    it "Constructs Enter command string correctly" {
        Enter-ActionOutputGroup "name" | Should -Be "::group::name$([System.Environment]::NewLine)"
    }

    it "Constructs Exit command string correctly" {
        Exit-ActionOutputGroup "name" | Should -Be "::endgroup::$([System.Environment]::NewLine)"
    }
}
