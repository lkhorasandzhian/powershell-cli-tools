function Get-ProjectFiles {
    [CmdletBinding()]
    param(
        [string[]]$ExcludeDirectories = @('node_modules', 'bin', 'obj')
    )

    $excludePattern = '\\(' + (($ExcludeDirectories | ForEach-Object { [regex]::Escape($_) }) -join '|') + ')\\'

    Get-ChildItem -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object {
            $_.FullName -notmatch $excludePattern
        }
}

function Normalize-Extension {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Extension
    )

    if ($Extension -match '^\.') {
        return $Extension
    }

    ".$Extension"
}

function Get-TotalLineCount {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo[]]$Files
    )

    $lineCount = 0

    foreach ($file in $Files) {
        try {
            $lineCount += ([System.IO.File]::ReadLines($file.FullName) | Measure-Object).Count
        }
        catch {
            Write-Verbose "Failed to read file: $($file.FullName)"
        }
    }

    $lineCount
}
