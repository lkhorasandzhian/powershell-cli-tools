function Get-LineCount {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Exts
    )

    $files = Get-ProjectFiles

    if ($Exts -contains '*') {
        $files |
            Group-Object Extension |
            Where-Object {
                -not (Test-BinaryExtension -Extension $_.Name)
            } |
            ForEach-Object {
                $extensionName = if ([string]::IsNullOrEmpty($_.Name)) { '[no ext]' } else { $_.Name }

                [PSCustomObject]@{
                    Extension = $extensionName
                    Lines = Get-TotalLineCount -Files $_.Group
                }
            } |
            Sort-Object Lines -Descending |
            ForEach-Object {
                '{0,-10} {1}' -f $_.Extension, $_.Lines
            }
        return
    }

    foreach ($ext in $Exts) {
        $normalizedExt = Normalize-Extension -Extension $ext

        if (Test-BinaryExtension -Extension $normalizedExt) {
            continue
        }

        $matchedFiles = $files | Where-Object { $_.Extension -ieq $normalizedExt }
        $lineCount = Get-TotalLineCount -Files $matchedFiles
        '{0,-10} {1}' -f $normalizedExt, $lineCount
    }
}
