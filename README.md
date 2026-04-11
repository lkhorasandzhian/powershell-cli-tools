# powershell-cli-tools 

<img width="640" height="320" alt="powershell-cli-tools_preview" src="https://github.com/user-attachments/assets/28c17a66-cc06-4a3b-af72-4091966fdfe6" />

[![GitHub stars](https://img.shields.io/github/stars/lkhorasandzhian/powershell-cli-tools?style=social)](https://github.com/lkhorasandzhian/powershell-cli-tools/stargazers)

Collection of useful PowerShell 7 scripts, shortcuts and CLI tools for productivity and terminal enhancements.

## ✨ CLI Extensions
- Handy CLI utilities  
- Useful aliases & shortcuts  
- Productivity-focused scripts  
- Terminal enhancements (colors, output, navigation)

## 🚀 Quick start
Clone the repo and use any script you need:

```powershell
git clone https://github.com/lkhorasandzhian/powershell-cli-tools
cd powershell-cli-tools
```

Run scripts directly or add them to your PowerShell profile.

### 🚀 Install
Run the install script:

```powershell
.\install.ps1
```

This will:
1. Copy the script to your PowerShell directory;
2. Automatically update your $PROFILE just by adding call for `powershell-cli-tools.ps1`;
3. Enable tools on every PowerShell startup.

## ⭐ Support
If you find this useful, consider giving it a star ❤️ — it really helps the project grow and keeps me motivated to add more tools!  
More tools and improvements are coming.

## 📁 Repository structure
```txt
powershell-cli-tools/
│
├── scripts/
│   └── powershell-cli-tools.ps1
│
├── test/
│   └── 01/
│       ├── tree-color-test/
│       └── create-tree-test.ps1
│
├── install.ps1
├── LICENSE
└── README.md
```

## 🧪 Tests
Test cases are located in the `test/` directory.  
They are used to verify CLI behavior, output formatting, and ensure consistent functionality across different scenarios.
