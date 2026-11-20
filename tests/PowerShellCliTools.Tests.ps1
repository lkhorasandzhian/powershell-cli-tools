Describe 'PowerShellCliTools module' {
    BeforeAll {
        $moduleManifest = Join-Path $PSScriptRoot '..\PowerShellCliTools\PowerShellCliTools.psd1'
        Import-Module $moduleManifest -Force
    }

    It 'counts all lines in a multi-line file' {
        $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid().ToString())
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

        try {
            Set-Location $tempDir
            @('first', 'second', 'third') | Set-Content -Path '.\sample.ps1'

            $result = Get-LineCount -Exts ps1

            $result | Should -Match '\.ps1\s+3$'
        }
        finally {
            Set-Location $PSScriptRoot

            if (Test-Path $tempDir) {
                Remove-Item $tempDir -Recurse -Force
            }
        }
    }

    Context 'when there are no matching files' {
        BeforeEach {
            $sampleDir = Join-Path $TestDrive ([guid]::NewGuid().ToString('N'))
            New-Item -ItemType Directory -Path $sampleDir | Out-Null
            Push-Location -LiteralPath $sampleDir
        }

        AfterEach {
            Pop-Location
        }

        It 'returns zero for an absent extension' {
            'sample content' | Set-Content -LiteralPath './sample.ps1'
            Get-LineCount -Exts xyz -ErrorAction Stop | Should -Match '^\.xyz\s+0$'
        }

        It 'returns zero in an empty directory' {
            Get-LineCount -Exts ps1 -ErrorAction Stop | Should -Match '^\.ps1\s+0$'
        }
    }

    It 'exports the approved-verb commands' {
        Get-Command Get-FileCount -ErrorAction Stop | Should -Not -BeNullOrEmpty
        Get-Command Get-LineCount -ErrorAction Stop | Should -Not -BeNullOrEmpty
        Get-Command Get-CodeStats -ErrorAction Stop | Should -Not -BeNullOrEmpty
        Get-Command Show-ColorTree -ErrorAction Stop | Should -Not -BeNullOrEmpty
    }

    It 'keeps the legacy aliases' {
        Get-Command file-counter -ErrorAction Stop | Should -Not -BeNullOrEmpty
        Get-Command line-counter -ErrorAction Stop | Should -Not -BeNullOrEmpty
        Get-Command super-counter -ErrorAction Stop | Should -Not -BeNullOrEmpty
        Get-Command tree-color -ErrorAction Stop | Should -Not -BeNullOrEmpty
        Get-Command la -ErrorAction Stop | Should -Not -BeNullOrEmpty
        Get-Command .. -ErrorAction Stop | Should -Not -BeNullOrEmpty
        Get-Command home -ErrorAction Stop | Should -Not -BeNullOrEmpty
        Get-Command repos -ErrorAction Stop | Should -Not -BeNullOrEmpty
    }
}
