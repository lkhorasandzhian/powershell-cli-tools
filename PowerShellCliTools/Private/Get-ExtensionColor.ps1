function Get-ExtensionColor {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [AllowEmptyString()]
        [string]$Extension = ''
    )

    $pink = $PSStyle.Foreground.FromRgb(255, 140, 180)
    $pinkLight = $PSStyle.Foreground.FromRgb(255, 180, 200)
    $orange = $PSStyle.Foreground.FromRgb(255, 120, 0)

    $nameLower = $Name.ToLowerInvariant()
    $extensionLower = $Extension.ToLowerInvariant()

    switch ($true) {
        { $extensionLower -eq '.cs' } { 'Green'; break }
        { $extensionLower -eq '.cpp' } { $pink; break }
        { $extensionLower -eq '.h' } { $pinkLight; break }
        { $extensionLower -eq '.java' } { $orange; break }
        { $extensionLower -eq '.py' } { 'Yellow'; break }
        { $extensionLower -eq '.ipynb' } { 'Yellow'; break }
        { $nameLower -eq '.env' } { 'DarkRed'; break }
        { $extensionLower -eq '.md' } { 'DarkYellow'; break }
        { $extensionLower -eq '.tex' } { 'DarkYellow'; break }
        default { $null }
    }
}
