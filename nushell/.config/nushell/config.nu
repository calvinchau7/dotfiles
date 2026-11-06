# Nushell config — the nu counterpart of fish/config.fish.
# Linked to %APPDATA%\nushell on Windows (install.ps1), ~/.config/nushell elsewhere.

$env.config.show_banner = false
$env.config.edit_mode = 'emacs'   # bash/zsh-style keys: Ctrl+A/E/K/U/W, Ctrl+R
$env.config.history.file_format = 'sqlite'
$env.config.history.max_size = 100_000
$env.config.completions.algorithm = 'fuzzy'

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
