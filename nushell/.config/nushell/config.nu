# Nushell config — the nu counterpart of fish/config.fish.
# Linked to %APPDATA%\nushell on Windows (install.ps1), ~/.config/nushell elsewhere.

$env.config.show_banner = false
$env.config.edit_mode = 'emacs'   # bash/zsh-style keys: Ctrl+A/E/K/U/W, Ctrl+R
$env.config.history.file_format = 'sqlite'
$env.config.history.max_size = 100_000
$env.config.completions.algorithm = 'fuzzy'

# Windows' ConPTY mangles the prompt marks nu emits, which makes the prompt
# jump up a line on every keypress in WezTerm
if $nu.os-info.name == 'windows' {
    $env.config.shell_integration.osc133 = false
    $env.config.shell_integration.osc633 = false
}

# --- PATH --------------------------------------------------------------------
use std/util "path add"
path add ($nu.home-dir | path join '.local' 'bin')
path add ($nu.home-dir | path join '.cargo' 'bin')

# --- Environment -------------------------------------------------------------
if (which nvim | is-not-empty) {
    $env.EDITOR = 'nvim'
    $env.VISUAL = 'nvim'
    $env.config.buffer_editor = 'nvim'
}

# Gruvbox dark hard everywhere
$env.BAT_THEME = 'gruvbox-dark'
$env.FZF_DEFAULT_OPTS = '--color=bg+:#3c3836,bg:#1d2021,spinner:#8ec07c,hl:#83a598,fg:#bdae93,header:#83a598,info:#fabd2f,pointer:#8ec07c,marker:#8ec07c,fg+:#ebdbb2,prompt:#fabd2f,hl+:#83a598,border:#504945'

if (which fnm | is-not-empty) {
    fnm env --json | from json | load-env
    path add ($env.FNM_MULTISHELL_PATH | path join (if $nu.os-info.name == 'windows' { '' } else { 'bin' }))
}

# --- Tools (only if installed) -----------------------------------------------
# Each tool's init script is regenerated into the vendor autoload dir, which nu
# sources after this file. (First launch after installing a tool needs a restart.)
let autoload = ($nu.data-dir | path join 'vendor' 'autoload')
mkdir $autoload
if (which starship | is-not-empty) { starship init nu | save -f ($autoload | path join 'starship.nu') }
if (which zoxide | is-not-empty) { zoxide init nushell | save -f ($autoload | path join 'zoxide.nu') }
if (which carapace | is-not-empty) {
    # completions for git, winget, cargo, ... (falls back to bash/fish/zsh specs)
    $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
    carapace _carapace nushell | save -f ($autoload | path join 'carapace.nu')
}

# --- Aliases (same names as fish/conf.d/abbreviations.fish) ------------------
alias v = nvim

# Windows: gsudo (approve once per session); elsewhere the real sudo
def --wrapped sudo [...args] {
    if $nu.os-info.name == 'windows' { ^gsudo ...$args } else { ^sudo ...$args }
}
def --env .. [] { cd .. }
def --env ... [] { cd ../.. }
def --env .... [] { cd ../../.. }

# nu's own `ls` returns a table (sortable, filterable), so keep it; eza for the rest
alias ll = eza -l --git --icons
alias la = eza -la --git --icons
alias lt = eza --tree --level=2 --icons

# --- Windows PATH ------------------------------------------------------------
# Installers update PATH in the registry, but running shells (and every tab
# WezTerm opens) keep the old copy. These pull the new one in.

# Reload PATH from the registry, keeping entries added this session
def --env refresh-path [] {
    if $nu.os-info.name != 'windows' { return }
    let reg = (^powershell -NoProfile -Command '[Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User")'
        | str trim | split row ';')
    $env.Path = ($reg | append $env.Path | where $it != '' | uniq)
}

# winget, then refresh-path so new commands work right away
def --env --wrapped winget [...args] {
    ^winget ...$args
    refresh-path
}

# Permanently add a folder to your user PATH (for apps that don't, like 7-Zip)
def --env add-path [dir: path] {
    $env.NU_ADD_PATH = ($dir | path expand)
    ^powershell -NoProfile -Command '$p = [Environment]::GetEnvironmentVariable("Path","User"); if (($p -split ";") -notcontains $env:NU_ADD_PATH) { [Environment]::SetEnvironmentVariable("Path", "$p;$env:NU_ADD_PATH", "User") }'
    hide-env NU_ADD_PATH
    refresh-path
}

# Load the Visual Studio C++ toolchain (cl, link, Windows SDK) into this shell,
# so CMake/Ninja, clangd and make can find the compiler
def --env vsdev [] {
    let script = '
        $vs = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -products * -property installationPath
        Import-Module "$vs\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"
        $env:Path += ";${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer"
        Enter-VsDevShell -VsInstallPath $vs -SkipAutomaticLocation -DevCmdArguments "-arch=x64 -host_arch=x64" | Out-Null
        $vars = @{}; Get-ChildItem env: | Where-Object Name -notin "Path", "PWD", "PSModulePath" | ForEach-Object { $vars[$_.Name] = $_.Value }
        @{ vars = $vars; path = $env:Path } | ConvertTo-Json -Compress'
    let dev = (^powershell -NoProfile -Command $script | from json)
    load-env $dev.vars
    $env.Path = ($dev.path | split row ';' | append $env.Path | where $it != '' | uniq)
    print $"VS dev env loaded: (which cl | get path.0)"
}

# --- Functions (same as fish/functions) --------------------------------------
# Create a directory and cd into it
def --env mkcd [dir: path] {
    mkdir $dir
    cd $dir
}

# Update everything: system packages, scoop, rustup, tldr
# (fish calls this `update`, but that's a nu builtin)
def upgrade [] {
    if $nu.os-info.name == 'windows' {
        print '==> winget'
        winget upgrade --all --accept-source-agreements --accept-package-agreements
        if (which scoop | is-not-empty) { print '==> scoop'; scoop update * }
    } else if (which brew | is-not-empty) {
        print '==> Homebrew'
        brew update; brew upgrade; brew cleanup
    }
    if (which rustup | is-not-empty) { print '==> rustup'; rustup update }
    if (which tldr | is-not-empty) { tldr --update | ignore }
    print 'Done. Open a new terminal to pick up new versions.'
}
