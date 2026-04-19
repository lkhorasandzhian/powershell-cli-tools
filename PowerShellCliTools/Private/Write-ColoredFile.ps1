function Write-ColoredFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $nameLower = $Name.ToLowerInvariant()

    if ($nameLower -in @('dockerfile', 'docker-compose.yaml', 'docker-compose.yml')) {
        Write-Host $Name -ForegroundColor Cyan
        return
    }

    $base = [System.IO.Path]::GetFileNameWithoutExtension($Name)
    $extension = [System.IO.Path]::GetExtension($Name)
    $color = Get-ExtensionColor -Name $Name -Extension $extension

    if (-not $color) {
        Write-Host $Name
        return
    }

    if ($color -is [string] -and $color -notin [enum]::GetNames([System.ConsoleColor])) {
        $reset = $PSStyle.Reset
        Write-Host ($base + $color + $extension + $reset)
        return
    }

    Write-Host $base -NoNewline
    Write-Host $extension -ForegroundColor $color
}
