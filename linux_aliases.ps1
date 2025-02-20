# Linux command aliases (simple ones)
# Remove existing alias (if present) before setting a new one:
if (Get-Alias cp -ErrorAction SilentlyContinue) {
    Remove-Item alias:cp -ErrorAction SilentlyContinue
}
Set-Alias ls Get-ChildItem
Set-Alias cat Get-Content
Set-Alias grep Select-String
Set-Alias mv Move-Item
Set-Alias rm Remove-Item
Set-Alias cp Copy-Item
Set-Alias pwd Get-Location
Set-Alias ps Get-Process
Set-Alias kill Stop-Process
Set-Alias clear Clear-Host
Set-Alias which Get-Command
Set-Alias man Get-Help

# For commands requiring parameters use functions

function touch {
    param(
        [string]$Path
    )
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -ItemType File | Out-Null
    }
}

# 'sudo' runs a command elevated
function sudo {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        $Args
    )
    Start-Process powershell -Verb RunAs -ArgumentList $Args
}

# Git shortcuts using functions
function g { git @args }
function ga { git add @args }
function gc { git commit @args }
function gp { git push @args }
function gl { git log --oneline --graph --decorate --all @args }

# Additional zoxide alias with fzf integration
function zf {
    zoxide query -l | fzf | Set-Location
}
Set-Alias zz zf