# Function to ensure all dependencies are installed and available
function Initialize-Dependencies {
  # Check for installed commands
  $hasOmp    = Get-Command oh-my-posh -ErrorAction SilentlyContinue
  $hasZoxide = Get-Command zoxide -ErrorAction SilentlyContinue
  $hasFzf    = Get-Command fzf -ErrorAction SilentlyContinue
  $hasWinget = Get-Command winget -ErrorAction SilentlyContinue

  # If none are installed, install winget first
  if (-not ($hasOmp -or $hasZoxide -or $hasFzf -or $hasWinget)) {
      Write-Host "None of the required tools are installed. Installing winget..." -ForegroundColor Yellow
      Start-Process powershell -Verb RunAs -ArgumentList "-Command winget install --id Microsoft.DesktopAppInstaller -e --silent" -Wait
      $hasWinget = Get-Command winget -ErrorAction SilentlyContinue
      if ($hasWinget) {
          Write-Host "winget successfully installed." -ForegroundColor Green
      }
      else {
          Write-Host "winget installation failed. Please install winget manually." -ForegroundColor Red
          return
      }
  }

  # Install missing tools via winget if available.
  # Install missing tools via winget if available.
  if (-not $hasOmp -and $hasWinget) {
    Write-Host "Installing oh-my-posh via winget..." -ForegroundColor Yellow
    winget install --id og-my-posh -e --silent
  }
  if (-not $hasZoxide -and $hasWinget) {
    Write-Host "Installing zoxide via winget..." -ForegroundColor Yellow
    winget install --id zoxide -e --silent
  }
  if (-not $hasFzf -and $hasWinget) {
    Write-Host "Installing fzf via winget..." -ForegroundColor Yellow
    winget install --id fzf -e --silent
  }
}

# Ensure dependencies before proceeding
Initialize-Dependencies

# Check if oh-my-posh is available before initializing prompt enhancements
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {

  # Define the default theme path (adjust as needed)
  $ompTheme = "$env:POSH_THEMES_PATH/custom.omp.json"

  # Initialize zoxide if available for enhanced directory navigation
  if (Get-Command zoxide -ErrorAction SilentlyContinue) {
      $zfInit = zoxide init powershell --cmd cd
      if ($zfInit) {
          # Join array output into a single string (in case it returns multiple lines)
          Invoke-Expression ($zfInit -join "`n")
      }
      else {
          Write-Host "zoxide initialization returned no output." -ForegroundColor Yellow
      }
  }

  # Initialize oh-my-posh with the default theme
  oh-my-posh init pwsh --config $ompTheme | Invoke-Expression

  # Function to switch themes on the fly
  function Set-PoshTheme {
      param (
          [string]$theme
      )
      $themePath = "$env:POSH_THEMES_PATH/$theme.omp.json"
      if (Test-Path $themePath) {
          oh-my-posh init pwsh --config $themePath | Invoke-Expression
          Write-Host "Switched to theme: $theme" -ForegroundColor Green
      }
      else {
          Write-Host "Theme not found: $theme" -ForegroundColor Red
      }
  }
}

# Set fzf options for better visuals
$env:FZF_DEFAULT_OPTS = '--layout=reverse --height=40% --border --ansi'

# Load Linux-like aliases from separate file
. "$env:USERPROFILE\Documents\PowerShell\linux_aliases.ps1"