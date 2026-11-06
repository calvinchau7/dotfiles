# dotfiles

## macOS / Linux

```sh
./install.sh            # install packages + link configs (stow)
./install.sh --no-pkgs  # only link configs
```

## Windows

```powershell
.\install.ps1           # install winget packages + link configs
.\install.ps1 -NoPkgs   # only link configs
```

Windows uses WezTerm instead of Ghostty/kitty and PowerShell instead of fish
(`powershell/profile.ps1` mirrors the fish config: same aliases, `mkcd`,
`update`, starship, zoxide, fzf). No admin needed: nvim and wezterm are
directory junctions, starship uses `STARSHIP_CONFIG`, and `~/.gitconfig`
includes `git/.config/git/config`.
