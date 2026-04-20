function Get-CodeStats {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Exts
    )

    Write-Host 'Files:'
    Get-FileCount -Exts $Exts

    Write-Host

    Write-Host 'Lines:'
    Get-LineCount -Exts $Exts
}
