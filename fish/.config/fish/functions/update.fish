function update --description 'Update system packages, fish, starship and completions'
    switch (uname)
        case Darwin
            if type -q brew
                echo "==> Homebrew"
                brew update; and brew upgrade; and brew cleanup
            end
        case Linux
            echo "==> System packages"
            if type -q paru
                paru -Syu
            else if type -q yay
                yay -Syu
            else if type -q pacman
                sudo pacman -Syu
            else if type -q apt
                sudo apt update; and sudo apt upgrade
            else if type -q dnf
                sudo dnf upgrade --refresh
            end

            if type -q flatpak
                echo "==> Flatpak"
                flatpak update
            end

            if test -x /home/linuxbrew/.linuxbrew/bin/brew
                echo "==> Linuxbrew"
                brew update; and brew upgrade
            end
    end

    # Starship installed via its install script isn't covered by a package
    # manager, so re-run the installer into the same directory.
    if type -q starship
        set -l bin (command -s starship)
        if not string match -qr '^(/usr/bin|/opt/homebrew|/home/linuxbrew)/' -- $bin
            echo "==> Starship ($bin)"
            curl -sS https://starship.rs/install.sh | sh -s -- --yes --bin-dir (path dirname $bin)
        end
    end

    echo "==> Fish completions"
    fish_update_completions >/dev/null

    echo "Done. Restart fish (exec fish) to pick up a new fish version."
end
