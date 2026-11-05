#!/usr/bin/env bash
# Set up these dotfiles on macOS or Linux. Safe to re-run.
#
#   ./install.sh            install packages + link configs
#   ./install.sh --no-pkgs  only link configs
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
BACKUP="$HOME/.config-backup-$(date +%Y-%m-%d-%H%M%S)"
OS="$(uname)"

COMMON_PKGS=(fish nvim starship git ghostty kitty tuios)
LINUX_PKGS=(hypr niri quickshell)

# Arch packages (official repos)
ARCH_PKGS=(
    fish starship fnm zoxide fzf fastfetch
    eza bat fd ripgrep jq tealdeer tree wget stow
    git git-delta github-cli lazygit
    neovim tree-sitter-cli luarocks
    uv
    ghostty kitty ttf-iosevka-nerd
)
# Arch packages from the AUR (need paru or yay)
AUR_PKGS=(tuios-bin)

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*"; }

install_packages() {
    if [[ $OS == Darwin ]]; then
        if ! command -v brew >/dev/null; then
            info "Installing Homebrew"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
        fi
        info "Installing Brewfile packages"
        brew bundle --file="$DOTFILES/Brewfile"
    elif command -v pacman >/dev/null; then
        local aur=""
        command -v paru >/dev/null && aur=paru
        [[ -z $aur ]] && command -v yay >/dev/null && aur=yay
        info "Installing Arch packages"
        sudo pacman -S --needed --noconfirm "${ARCH_PKGS[@]}"
        if [[ -n $aur ]]; then
            "$aur" -S --needed --noconfirm "${AUR_PKGS[@]}"
        else
            warn "No AUR helper (paru/yay); skipping: ${AUR_PKGS[*]}"
        fi
    elif command -v brew >/dev/null; then
        info "Installing Brewfile packages via Linuxbrew"
        brew bundle --file="$DOTFILES/Brewfile"
    else
        warn "Unsupported distro: install Linuxbrew (https://brew.sh) and re-run, or install packages manually"
    fi
}

# Move real files that would block stow into a backup dir.
backup_conflicts() {
    local pkg=$1 src rel target
    while IFS= read -r -d '' src; do
        rel="${src#"$DOTFILES/$pkg/"}"
        target="$HOME/$rel"
        # skip if it already resolves to the dotfiles copy (e.g. parent dir is linked)
        if [[ -e $target && ! -L $target && ! $target -ef $src ]]; then
            mkdir -p "$BACKUP/$(dirname "$rel")"
            mv "$target" "$BACKUP/$rel"
            warn "Backed up ~/$rel to $BACKUP/$rel"
        fi
    done < <(find "$DOTFILES/$pkg" \( -type f -o -type l \) -print0)
}

link_configs() {
    command -v stow >/dev/null || { warn "stow is not installed; can't link configs"; exit 1; }
    local pkgs=("${COMMON_PKGS[@]}")
    [[ $OS == Linux ]] && pkgs+=("${LINUX_PKGS[@]}")

    info "Linking: ${pkgs[*]}"
    for pkg in "${pkgs[@]}"; do
        backup_conflicts "$pkg"
        stow --dir="$DOTFILES" --target="$HOME" --restow "$pkg"
    done

    # macOS tuios reads ~/Library/Application Support, not ~/.config
    if [[ $OS == Darwin ]]; then
        local as="$HOME/Library/Application Support/tuios"
        mkdir -p "$as"
        if [[ -e $as/config.toml && ! -L $as/config.toml ]]; then
            mkdir -p "$BACKUP"
            mv "$as/config.toml" "$BACKUP/tuios-config.toml"
        fi
        ln -sfn ../../../.config/tuios/config.toml "$as/config.toml"
    fi
}

set_fish_shell() {
    local fish
    fish="$(command -v fish || true)"
    [[ -z $fish ]] && return
    if ! grep -qx "$fish" /etc/shells; then
        info "Adding $fish to /etc/shells"
        echo "$fish" | sudo tee -a /etc/shells >/dev/null
    fi
    local current
    if [[ $OS == Darwin ]]; then
        current="$(dscl . -read "$HOME" UserShell | awk '{print $2}')"
    else
        current="$(getent passwd "$USER" | cut -d: -f7)"
    fi
    if [[ $current != "$fish" ]]; then
        info "Changing login shell to fish"
        chsh -s "$fish"
    fi
}

post_install() {
    command -v tldr >/dev/null && tldr --update >/dev/null 2>&1 || true
    command -v fish >/dev/null && fish -c 'fish_update_completions' >/dev/null 2>&1 || true
}

main() {
    [[ ${1:-} != --no-pkgs ]] && install_packages
    link_configs
    set_fish_shell
    post_install
    [[ -d $BACKUP ]] && info "Replaced files were backed up to $BACKUP"
    info "Done. Open a new terminal (or run: exec fish)."
    if command -v gh >/dev/null && ! gh auth status >/dev/null 2>&1; then
        info "Next: run 'gh auth login' to sign in to GitHub"
    fi
}

main "$@"
