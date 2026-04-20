$publicPath = Join-Path $PSScriptRoot 'Public'
$privatePath = Join-Path $PSScriptRoot 'Private'

$privateScripts = Get-ChildItem -Path $privatePath -Filter '*.ps1' -File | Sort-Object Name
foreach ($script in $privateScripts) {
    . $script.FullName
}

$publicScripts = Get-ChildItem -Path $publicPath -Filter '*.ps1' -File | Sort-Object Name
foreach ($script in $publicScripts) {
    . $script.FullName
}

[Console]::InputEncoding = [System.Text.UTF8Encoding]::new()
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$global:OutputEncoding = [System.Text.UTF8Encoding]::new()

function Get-AllItems { Get-ChildItem -Force }
function Set-ParentLocation { Set-Location .. }
function Set-HomeLocation { Set-Location $HOME }
function Set-ReposLocation { Set-Location (Join-Path $HOME 'source\repos') }

Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name la -Value Get-AllItems
Set-Alias -Name .. -Value Set-ParentLocation
Set-Alias -Name home -Value Set-HomeLocation
Set-Alias -Name repos -Value Set-ReposLocation
Set-Alias -Name file-counter -Value Get-FileCount
Set-Alias -Name line-counter -Value Get-LineCount
Set-Alias -Name super-counter -Value Get-CodeStats
Set-Alias -Name tree-color -Value Show-ColorTree

Export-ModuleMember -Function @(
    'Get-FileCount',
    'Get-LineCount',
    'Get-CodeStats',
    'Show-ColorTree',
    'Get-AllItems',
    'Set-ParentLocation',
    'Set-HomeLocation',
    'Set-ReposLocation'
)
