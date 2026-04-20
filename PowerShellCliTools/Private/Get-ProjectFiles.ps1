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

[string[]]$script:BinaryExtensions = @(
    '.7z',
    '.bmp',
    '.class',
    '.dll',
    '.doc',
    '.docx',
    '.exe',
    '.gif',
    '.gz',
    '.ico',
    '.jar',
    '.jpeg',
    '.jpg',
    '.mov',
    '.mp3',
    '.mp4',
    '.pdf',
    '.png',
    '.ppt',
    '.pptx',
    '.rar',
    '.so',
    '.tar',
    '.tif',
    '.tiff',
    '.wav',
    '.webp',
    '.xls',
    '.xlsx',
    '.zip'
)

function Test-BinaryExtension {
    [CmdletBinding()]
    param(
        [AllowEmptyString()]
        [string]$Extension = ''
    )

    $Extension.ToLowerInvariant() -in $script:BinaryExtensions
}

function Test-TextFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo]$File
    )

    -not (Test-BinaryExtension -Extension $File.Extension)
}

function Get-TotalLineCount {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo[]]$Files
    )

    $lineCount = 0

    foreach ($file in $Files) {
        if (-not (Test-TextFile -File $file)) {
            continue
        }

        try {
            $lineCount += ([System.IO.File]::ReadLines($file.FullName) | Measure-Object).Count
        }
        catch {
            Write-Verbose "Failed to read file: $($file.FullName)"
        }
    }

    $lineCount
}
