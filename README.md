# powershell-cli-tools

Collection of useful PowerShell 7 scripts, shortcuts and CLI tools for productivity and terminal enhancements.

<img width="640" height="320" alt="powershell-cli-tools_preview" src="https://github.com/user-attachments/assets/28c17a66-cc06-4a3b-af72-4091966fdfe6" />

[![GitHub stars](https://img.shields.io/github/stars/lkhorasandzhian/powershell-cli-tools?style=social)](https://github.com/lkhorasandzhian/powershell-cli-tools/stargazers)

## Features

- `Get-FileCount` for file counters by extension
- `Get-LineCount` for line counters by extension
- `Get-CodeStats` for combined file and line summaries
- `Show-ColorTree` for colorful directory tree output
- Handy legacy aliases like `file-counter`, `tree-color`, `la`, `..`, `home`, and `repos`

## Project Structure

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

The installer copies the module to your PowerShell modules directory and adds an `Import-Module` line to your PowerShell profile.

### 🚀 Install

Run the install script:

```powershell
.\install.ps1
```

This will:

1. Copy the module to your PowerShell modules directory
2. Automatically update your `$PROFILE` by adding an `Import-Module` call
3. Enable tools on every PowerShell startup

### 🛠 Development

You can import the local module directly while working on it:

```powershell
Import-Module .\PowerShellCliTools\PowerShellCliTools.psd1 -Force
Get-Command -Module PowerShellCliTools
```

The module exports PowerShell-style command names and keeps the old shorter names as aliases for convenience.

### 🚀 Install
Run the install script:

```powershell
.\install.ps1
```

If you find this useful, consider giving it a star ❤️ — it really helps the project grow and keeps me motivated to add more tools!
More tools and improvements are coming.

## 📁 Repository structure

```txt
powershell-cli-tools/
├── .github/
│   ├── demo/
│   ├── workflows/
│   │   └── manual-tests.yml
│   └── self-approval.yml
├── PowerShellCliTools/
│   ├── Private/
│   │   ├── Get-ExtensionColor.ps1
│   │   ├── Get-ProjectFiles.ps1
│   │   ├── Show-TreeNode.ps1
│   │   └── Write-ColoredFile.ps1
│   ├── Public/
│   │   ├── Get-CodeStats.ps1
│   │   ├── Get-FileCount.ps1
│   │   ├── Get-LineCount.ps1
│   │   └── Show-ColorTree.ps1
│   ├── PowerShellCliTools.psd1
│   └── PowerShellCliTools.psm1
├── tests/
│   └── PowerShellCliTools.Tests.ps1
├── install.ps1
├── LICENSE
└── README.md
```

## 🧪 Tests

Test cases are located in the `tests/` directory.
They are used to verify that the module imports correctly and that the expected commands and aliases are available.

```powershell
Invoke-Pester .\tests
```
