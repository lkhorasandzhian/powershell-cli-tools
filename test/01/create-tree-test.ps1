$root = "tree-color-test"

# Удалим старое (если есть)
if (Test-Path $root) {
    Remove-Item $root -Recurse -Force
}

# Создаём структуру
New-Item -ItemType Directory -Path $root | Out-Null

# Подпапки
$dirs = @(
    "$root/src",
    "$root/include",
    "$root/scripts",
    "$root/docs",
    "$root/docker"
)

foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Path $dir | Out-Null
}

# Файлы
$files = @(
    "$root/src/main.cpp",
    "$root/src/app.cs",
    "$root/src/program.java",

    "$root/include/main.h",

    "$root/scripts/script.py",
    "$root/scripts/notebook.ipynb",

    "$root/docs/readme.md",
    "$root/docs/paper.tex",

    "$root/.env",

    "$root/docker/Dockerfile",
    "$root/docker/docker-compose.yaml"
)

foreach ($file in $files) {
    New-Item -ItemType File -Path $file | Out-Null
}

Write-Host "Test tree created at: $root" -ForegroundColor Green