# Disable the fish greeting message
set -g fish_greeting ""

# --- OS-specific setup -------------------------------------------------------
switch (uname)
    case Darwin
        # Homebrew (Apple Silicon, then Intel)
        if test -x /opt/homebrew/bin/brew
            /opt/homebrew/bin/brew shellenv | source
        else if test -x /usr/local/bin/brew
            /usr/local/bin/brew shellenv | source
        end
        if set -q HOMEBREW_PREFIX; and test -d "$HOMEBREW_PREFIX/opt/llvm/bin"
            fish_add_path "$HOMEBREW_PREFIX/opt/llvm/bin"
        end
    case Linux
        # Linuxbrew, if installed
        if test -x /home/linuxbrew/.linuxbrew/bin/brew
            /home/linuxbrew/.linuxbrew/bin/brew shellenv | source
        end
end

# --- Common PATH -------------------------------------------------------------
fish_add_path "$HOME/.local/bin"

# ZVM
set -gx ZVM_INSTALL "$HOME/.zvm/self"
if test -d "$ZVM_INSTALL"
    fish_add_path --append "$HOME/.zvm/bin" "$ZVM_INSTALL"
end

# --- Environment -------------------------------------------------------------
if type -q nvim
    set -gx EDITOR nvim
    set -gx VISUAL nvim
    set -gx MANPAGER "nvim +Man!"
end

# Gruvbox dark hard everywhere
set -gx BAT_THEME gruvbox-dark
set -gx FZF_DEFAULT_OPTS "--color=bg+:#3c3836,bg:#1d2021,spinner:#8ec07c,hl:#83a598,fg:#bdae93,header:#83a598,info:#fabd2f,pointer:#8ec07c,marker:#8ec07c,fg+:#ebdbb2,prompt:#fabd2f,hl+:#83a598,border:#504945"

# --- Tools (only if installed) -----------------------------------------------
type -q fnm; and fnm env --use-on-cd --version-file-strategy=recursive --shell fish | source

if status is-interactive
    if type -q starship
        starship init fish | source
        # Collapse previous prompts to just the prompt character
        enable_transience
    end

    # Ctrl-R fuzzy history, Ctrl-T fuzzy file picker, Alt-C fuzzy cd
    type -q fzf; and fzf --fish | source

    # `z foo` jumps to the most-used dir matching "foo"
    type -q zoxide; and zoxide init fish | source

    if type -q eza
        alias ls="eza -ahl"
    end
end
