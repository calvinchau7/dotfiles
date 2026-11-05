status is-interactive; or return

# Abbreviations expand inline when you press space, so history shows the
# real command.

# editor
abbr -a v nvim

# navigation
abbr -a .. cd ..
abbr -a ... cd ../..
abbr -a .... cd ../../..

# eza listings
if type -q eza
    abbr -a ll eza -l --git --icons
    abbr -a la eza -la --git --icons
    abbr -a lt eza --tree --level=2 --icons
end

# !! expands to the previous command (e.g. `sudo !!`)
function __last_history_item
    echo $history[1]
end
abbr -a !! --position anywhere --function __last_history_item
