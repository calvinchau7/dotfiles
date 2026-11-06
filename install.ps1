# Set up these dotfiles on Windows. Safe to re-run.
#
#   .\install.ps1            install packages + link configs
#   .\install.ps1 -NoPkgs    only link configs
#
# Symlinks need admin or Developer Mode on Windows, so this uses directory
# junctions, env vars and include files instead.
param([switch]$NoPkgs)
$ErrorActionPreference = 'Stop'

$Dotfiles = $PSScriptRoot
$Backup = Join-Path $HOME ".config-backup-$(Get-Date -Format yyyy-MM-dd-HHmmss)"

# winget for apps and things that integrate with Windows
$WingetPkgs = @(
    'Microsoft.PowerShell', 'Git.Git', '7zip.7zip', 'ImageMagick.ImageMagick',
    'astral-sh.uv',
    # terminal + font (Iosevka Nerd Font isn't on winget; wezterm falls back to this)
    'wez.wezterm', 'DEVCOM.JetBrainsMonoNerdFont'
)
# Scoop for CLI tools (the Brewfile equivalents): per-user, no admin, always on
# PATH. Toolchains whose versions must pair up live here too (ols-dev is built
# against odin-dev nightlies); Zig + zls come from zvm, like on macOS/Linux.
$ScoopBuckets = @('extras', 'versions')
$ScoopPkgs = @(
    # shell + prompt
    'nu', 'extras/carapace-bin', 'starship', 'fnm', 'zoxide', 'fzf', 'fastfetch', 'gsudo',
    # cli tools
    'eza', 'bat', 'fd', 'ripgrep', 'jq', 'tealdeer',
    # git
    'delta', 'gh', 'extras/lazygit',
    # editor
    'neovim', 'tree-sitter',
    # build
    'cmake', 'ninja', 'make',
    # languages
    'versions/odin-dev', 'versions/ols-dev', 'zvm'
)
$PsModules = @('CompletionPredictor', 'PSFzf')

function Info($msg) { Write-Host '==> ' -ForegroundColor Blue -NoNewline; Write-Host $msg }
function Warn($msg) { Write-Host 'warning: ' -ForegroundColor Yellow -NoNewline; Write-Host $msg }

function Install-Packages {
    Info 'Installing winget packages'
    foreach ($id in $WingetPkgs) {
        winget list --id $id -e *> $null
        if ($LASTEXITCODE -eq 0) { continue }
        Info "  $id"
        winget install --id $id -e --silent --accept-source-agreements --accept-package-agreements
        if ($LASTEXITCODE -ne 0) { Warn "winget couldn't install $id" }
    }
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Info 'Installing Scoop'
        Invoke-RestMethod https://get.scoop.sh | Invoke-Expression
    }
    $buckets = scoop bucket list | ForEach-Object Name
    foreach ($b in $ScoopBuckets) { if ($b -notin $buckets) { scoop bucket add $b } }
    $installed = scoop list 6> $null | ForEach-Object Name
    foreach ($p in $ScoopPkgs) {
        if (($p -split '/')[-1] -notin $installed) { Info "  scoop: $p"; scoop install $p }
    }
    if (-not (Get-Command zig -ErrorAction SilentlyContinue)) {
        Info "Next: run 'zvm install --zls <version>' (or master) to get Zig + ZLS"
    }
    foreach ($m in $PsModules) {
        if (-not (Get-Module $m -ListAvailable)) {
            Info "Installing PowerShell module $m"
            Install-Module $m -Scope CurrentUser -Force
        }
    }
}

# Move a real file/dir out of the way before replacing it
function Backup-Path($path) {
    $item = Get-Item $path -Force -ErrorAction SilentlyContinue
    if (-not $item -or $item.LinkType) { return }
    New-Item -ItemType Directory -Force $Backup | Out-Null
    Move-Item $path (Join-Path $Backup $item.Name)
    Warn "Backed up $path to $Backup"
}

function Link-Dir($target, $source) {
    $item = Get-Item $target -Force -ErrorAction SilentlyContinue
    if ($item -and $item.LinkType -eq 'Junction' -and $item.Target -eq $source) { return }
    if ($item -and $item.LinkType) { Remove-Item $target -Force }
    Backup-Path $target
    New-Item -ItemType Directory -Force (Split-Path $target) | Out-Null
    New-Item -ItemType Junction -Path $target -Target $source | Out-Null
    Info "Linked $target"
}

function Link-Configs {
    # nvim reads %LOCALAPPDATA%\nvim on Windows
    Link-Dir (Join-Path $env:LOCALAPPDATA 'nvim') "$Dotfiles\nvim\.config\nvim"
    # nushell reads %APPDATA%\nushell on Windows
    Link-Dir (Join-Path $env:APPDATA 'nushell') "$Dotfiles\nushell\.config\nushell"
    Link-Dir "$HOME\.config\wezterm" "$Dotfiles\wezterm\.config\wezterm"

    # starship: point at the repo file directly
    [Environment]::SetEnvironmentVariable('STARSHIP_CONFIG', "$Dotfiles\starship\.config\starship.toml", 'User')
    $env:STARSHIP_CONFIG = "$Dotfiles\starship\.config\starship.toml"

    # git: ~/.gitconfig includes the repo config; anything already in it
    # (e.g. a different user.email for this machine) stays and wins
    $gitconfig = "$HOME\.gitconfig"
    $include = "[include]`n`tpath = $($Dotfiles -replace '\\','/')/git/.config/git/config`n"
    $existing = if (Test-Path $gitconfig) { Get-Content $gitconfig -Raw } else { '' }
    if ($existing -notmatch 'git/\.config/git/config') {
        Set-Content $gitconfig ($include + $existing) -NoNewline
        Info "Added include to $gitconfig"
    }

    # PowerShell profile dot-sources the repo profile
    $line = ". `"$Dotfiles\powershell\profile.ps1`""
    New-Item -ItemType Directory -Force (Split-Path $PROFILE) | Out-Null
    $current = if (Test-Path $PROFILE) { Get-Content $PROFILE -Raw } else { '' }
    if ($current -notmatch [regex]::Escape("powershell\profile.ps1")) {
        Backup-Path $PROFILE
        Set-Content $PROFILE $line
        Info "Wrote $PROFILE"
    }
}

if (-not $NoPkgs) { Install-Packages }
Link-Configs
if (Test-Path $Backup) { Info "Replaced files were backed up to $Backup" }
Info 'Done. Open a new terminal.'
if (Get-Command gh -ErrorAction SilentlyContinue) {
    gh auth status *> $null
    if ($LASTEXITCODE -ne 0) { Info "Next: run 'gh auth login' to sign in to GitHub" }
}
