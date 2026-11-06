# PowerShell profile for Windows — the pwsh counterpart of fish/config.fish.
# install.ps1 makes $PROFILE dot-source this file.

# --- Environment -------------------------------------------------------------
if (Get-Command nvim -ErrorAction SilentlyContinue) {
    $env:EDITOR = 'nvim'
    $env:VISUAL = 'nvim'
}

# Gruvbox dark hard everywhere
$env:BAT_THEME = 'gruvbox-dark'
$env:FZF_DEFAULT_OPTS = '--color=bg+:#3c3836,bg:#1d2021,spinner:#8ec07c,hl:#83a598,fg:#bdae93,header:#83a598,info:#fabd2f,pointer:#8ec07c,marker:#8ec07c,fg+:#ebdbb2,prompt:#fabd2f,hl+:#83a598,border:#504945'

# --- Tools (only if installed) -----------------------------------------------
if (Get-Command fnm -ErrorAction SilentlyContinue) {
    fnm env --use-on-cd --version-file-strategy=recursive --shell powershell | Out-String | Invoke-Expression
}

if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

# `z foo` jumps to the most-used dir matching "foo"
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# --- Line editing (PSReadLine ships with PowerShell) -------------------------
# bash/zsh-style keys, history + IntelliSense suggestions as you type
Set-PSReadLineOption -EditMode Emacs
if (Get-Module CompletionPredictor -ListAvailable) {
    Import-Module CompletionPredictor
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin
} else {
    Set-PSReadLineOption -PredictionSource History
}
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# Ctrl-R fuzzy history, Ctrl-T fuzzy file picker (needs: Install-Module PSFzf)
if (Get-Module PSFzf -ListAvailable) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}

# --- Aliases (same names as fish/conf.d/abbreviations.fish) ------------------
Set-Alias v nvim
# gsudo instead of Windows' built-in sudo (approve once per session)
if (Get-Command gsudo -ErrorAction SilentlyContinue) { Set-Alias sudo gsudo }
function .. { Set-Location .. }
function ... { Set-Location ../.. }
function .... { Set-Location ../../.. }

if (Get-Command eza -ErrorAction SilentlyContinue) {
    Remove-Item Alias:ls -Force -ErrorAction SilentlyContinue
    function ls { eza -ahl @args }
    function ll { eza -l --git --icons @args }
    function la { eza -la --git --icons @args }
    function lt { eza --tree --level=2 --icons @args }
}

# --- Functions (same as fish/functions) --------------------------------------
function mkcd($dir) {
    New-Item -ItemType Directory -Force $dir | Out-Null
    Set-Location $dir
}

function update {
    Write-Host '==> winget' -ForegroundColor Blue
    winget upgrade --all --accept-source-agreements --accept-package-agreements
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Host '==> scoop' -ForegroundColor Blue
        scoop update *
    }
    if (Get-Command rustup -ErrorAction SilentlyContinue) {
        Write-Host '==> rustup' -ForegroundColor Blue
        rustup update
    }
    if (Get-Command tldr -ErrorAction SilentlyContinue) { tldr --update | Out-Null }
    Write-Host 'Done. Open a new terminal to pick up new versions.'
}
