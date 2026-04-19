# powershell-cli-tools

[![GitHub stars](https://img.shields.io/github/stars/lkhorasandzhian/powershell-cli-tools?style=social)](https://github.com/lkhorasandzhian/powershell-cli-tools/stargazers)

Collection of useful PowerShell 7 CLI tools, shortcuts, and terminal enhancements packaged as a module.

## Features

- `Get-FileCount` for file counters by extension
- `Get-LineCount` for line counters by extension
- `Get-CodeStats` for combined file and line summaries
- `Show-ColorTree` for colorful directory tree output
- Handy legacy aliases like `file-counter`, `tree-color`, `la`, `..`, `home`, and `repos`

## Structure

```text
PowerShellCliTools/
├── PowerShellCliTools.psd1
├── PowerShellCliTools.psm1
├── Public/
└── Private/
```

Public commands live in `Public`, while shared helpers stay in `Private`. This keeps the module easier to extend without growing one large script file.

## Quick start

```powershell
git clone https://github.com/lkhorasandzhian/powershell-cli-tools
cd powershell-cli-tools
.\install.ps1
```

The installer copies the module to your PowerShell modules folder and adds an `Import-Module` line to your PowerShell profile.

## Development

You can import the local module directly while working on it:

```powershell
Import-Module .\PowerShellCliTools\PowerShellCliTools.psd1 -Force
Get-Command -Module PowerShellCliTools
```

The module exports PowerShell-style command names and keeps the old shorter names as aliases for convenience.

## Tests

Basic Pester tests live in `tests`.

```powershell
Invoke-Pester .\tests
```
