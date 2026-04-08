# === PowerShell CLI Tools ===
# Author: Levon Khorasandzhian (https://github.com/lkhorasandzhian)
# Repo: https://github.com/lkhorasandzhian/powershell-cli-tools
#
# MIT License

# =========================
# PowerShell 7 Dev Profile
# =========================

# --- UTF-8 ---
[Console]::InputEncoding  = [System.Text.UTF8Encoding]::new()
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$OutputEncoding           = [System.Text.UTF8Encoding]::new()

# --- Basic useful aliases ---
function ll { Get-ChildItem -Force }
function la { Get-ChildItem -Force -Recurse }
function .. { Set-Location .. }

# --- Fast move to favorite folders ---
function home  { Set-Location $HOME }
function repos { Set-Location "$HOME\source\repos" }

# --- File counter by extensions ---
function file-counter {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Exts
    )

    $files = Get-ChildItem -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object {
            $_.FullName -notmatch '\\(node_modules|bin|obj)\\'
        }

    if ($Exts -contains "*") {
        $files |
            Group-Object Extension |
            Sort-Object Count -Descending |
            ForEach-Object {
                "{0,-10} {1}" -f $(if ([string]::IsNullOrEmpty($_.Name)) { "[no ext]" } else { $_.Name }), $_.Count
            }
        return
    }

    foreach ($ext in $Exts) {
        if ($ext -notmatch '^\.') {
            $ext = ".$ext"
        }

        $count = ($files | Where-Object { $_.Extension -ieq $ext }).Count
        "{0,-10} {1}" -f $ext, $count
    }
}

# --- Line counter by extensions ---
function line-counter {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Exts
    )

    $files = Get-ChildItem -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object {
            $_.FullName -notmatch '\\(node_modules|bin|obj)\\'
        }

    if ($Exts -contains "*") {
        $files |
            Group-Object Extension |
            Sort-Object Name |
            ForEach-Object {
                $ext = if ([string]::IsNullOrEmpty($_.Name)) { "[no ext]" } else { $_.Name }

                $lineCount = 0
                foreach ($file in $_.Group) {
                    try {
                        $lineCount += (Get-Content $file.FullName -ErrorAction Stop | Measure-Object -Line).Lines
                    }
                    catch {
                    }
                }

                "{0,-10} {1}" -f $ext, $lineCount
            }
        return
    }

    foreach ($ext in $Exts) {
        if ($ext -notmatch '^\.') {
            $ext = ".$ext"
        }

        $matchedFiles = $files | Where-Object { $_.Extension -ieq $ext }

        $lineCount = 0
        foreach ($file in $matchedFiles) {
            try {
                $lineCount += (Get-Content $file.FullName -ErrorAction Stop | Measure-Object -Line).Lines
            }
            catch {
            }
        }

        "{0,-10} {1}" -f $ext, $lineCount
    }
}

# --- File and line counter by extensions ---
function super-counter {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Exts
    )

    Write-Host "Files:"
    file-counter @Exts

    Write-Host ""

    Write-Host "Lines:"
    line-counter @Exts
}

# --- Colorful Directory Tree ---
function tree-color {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Path = ".",

        [int]$Depth = 50,

        [string[]]$Exclude = @("bin", "obj", ".git", ".vs", "node_modules")
    )

    # Custom Colors.
    $Pink = $PSStyle.Foreground.FromRgb(255, 140, 180)
    $PinkLight = $PSStyle.Foreground.FromRgb(255, 180, 200)
    $Orange = $PSStyle.Foreground.FromRgb(255, 120, 0)
    $Reset = $PSStyle.Reset

    function Get-ExtensionColor {
        param(
            [string]$Name,
            [string]$Extension
        )

        $nameLower = $Name.ToLower()
        $ext = $Extension.ToLower()

        switch ($true) {
            # Programming Languages
            { $ext -eq ".cs" }   { "Green"; break }
            { $ext -eq ".cpp" }  { $Pink; break }
            { $ext -eq ".h" }    { $PinkLight; break }
            { $ext -eq ".java" } { $Orange; break }
            { $ext -eq ".py" }   { "Yellow"; break }
            { $ext -eq ".ipynb" } { "Yellow"; break }

            # Secrets
            { $nameLower -eq ".env" } { "DarkRed"; break }

            # Docs
            { $ext -eq ".md" }   { "DarkYellow"; break }
            { $ext -eq ".tex" }   { "DarkYellow"; break }

            default { $null }
        }
    }

    function Write-ColoredFile {
        param(
            [string]$Name
        )

        $nameLower = $Name.ToLower()

        if ($nameLower -eq "dockerfile" -or $nameLower -eq "docker-compose.yaml") {
            Write-Host $Name -ForegroundColor Cyan
            return
        }

        $base = [System.IO.Path]::GetFileNameWithoutExtension($Name)
        $ext  = [System.IO.Path]::GetExtension($Name)

        $color = Get-ExtensionColor $Name $ext

        if ($color) {
            if ($color -is [string] -and $color -notin [enum]::GetNames([System.ConsoleColor])) {
                # ANSI color.
                Write-Host ($base + $color + $ext + $Reset)
            }
            else {
                # Classic color.
                Write-Host $base -NoNewline
                Write-Host $ext -ForegroundColor $color
            }
        }
        else {
            Write-Host $Name
        }
    }

    function Show-TreeNode {
        param(
            [string]$CurrentPath,
            [string]$Indent = "",
            [int]$Level = 0
        )

        if ($Level -ge $Depth) {
            return
        }

        $items = Get-ChildItem -LiteralPath $CurrentPath -Force -ErrorAction SilentlyContinue |
            Where-Object { $Exclude -notcontains $_.Name } |
            Sort-Object @{ Expression = { -not $_.PSIsContainer } }, Name

        for ($i = 0; $i -lt $items.Count; $i++) {
            $item = $items[$i]
            $isLast = $i -eq ($items.Count - 1)

            $branch = if ($isLast) { "└── " } else { "├── " }
            $nextIndent = if ($isLast) { "$Indent    " } else { "$Indent│   " }

            Write-Host "$Indent$branch" -NoNewline

            if ($item.PSIsContainer) {
                Write-Host "$($item.Name)/" -ForegroundColor DarkCyan
                Show-TreeNode -CurrentPath $item.FullName -Indent $nextIndent -Level ($Level + 1)
            }
            else {
                Write-ColoredFile $item.Name
            }
        }
    }

    $resolvedPath = (Resolve-Path -LiteralPath $Path -ErrorAction Stop).Path
    Write-Host $resolvedPath -ForegroundColor DarkMagenta

    Show-TreeNode -CurrentPath $resolvedPath
}
