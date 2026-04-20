function Show-ColorTree {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Path = '.',

        [int]$Depth = 50,

        [string[]]$Exclude = @('bin', 'obj', '.git', '.vs', 'node_modules', '.venv', '.dotnet_cli')
    )

    $resolvedPath = (Resolve-Path -LiteralPath $Path -ErrorAction Stop).Path
    Write-Host $resolvedPath -ForegroundColor DarkMagenta

    Show-TreeNode -CurrentPath $resolvedPath -Depth $Depth -Exclude $Exclude
}
