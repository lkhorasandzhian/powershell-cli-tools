function Get-FileCount {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Exts
    )

    $files = Get-ProjectFiles

    if ($Exts -contains '*') {
        $files |
            Group-Object Extension |
            Sort-Object Count -Descending |
            ForEach-Object {
                $extensionName = if ([string]::IsNullOrEmpty($_.Name)) { '[no ext]' } else { $_.Name }
                '{0,-10} {1}' -f $extensionName, $_.Count
            }
        return
    }

    foreach ($ext in $Exts) {
        $normalizedExt = Normalize-Extension -Extension $ext
        $count = ($files | Where-Object { $_.Extension -ieq $normalizedExt }).Count
        '{0,-10} {1}' -f $normalizedExt, $count
    }
}
