function Show-TreeNode {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$CurrentPath,

        [string]$Indent = '',

        [int]$Level = 0,

        [Parameter(Mandatory = $true)]
        [int]$Depth,

        [string[]]$Exclude = @()
    )

    if ($Level -ge $Depth) {
        return
    }

    $items = Get-ChildItem -LiteralPath $CurrentPath -Force -ErrorAction SilentlyContinue |
        Where-Object { $Exclude -notcontains $_.Name } |
        Sort-Object @{ Expression = { -not $_.PSIsContainer } }, Name

    for ($index = 0; $index -lt $items.Count; $index++) {
        $item = $items[$index]
        $isLast = $index -eq ($items.Count - 1)

        $branch = if ($isLast) { '└── ' } else { '├── ' }
        $nextIndent = if ($isLast) { "$Indent    " } else { "$Indent│   " }

        Write-Host "$Indent$branch" -NoNewline

        if ($item.PSIsContainer) {
            Write-Host "$($item.Name)/" -ForegroundColor DarkCyan
            Show-TreeNode -CurrentPath $item.FullName -Indent $nextIndent -Level ($Level + 1) -Depth $Depth -Exclude $Exclude
            continue
        }

        Write-ColoredFile -Name $item.Name
    }
}
