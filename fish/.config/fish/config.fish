# Remove the universal fish greeting message
set -U fish_greeting ""

if status is-interactive
    # Commands to run in interactive sessions can go here
    fastfetch
end

starship init fish | source
