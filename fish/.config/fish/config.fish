set -g fish_greeting

if status is-interactive
    alias ls 'eza -al'
    alias grep 'grep --color=auto'

    fastfetch
end

source "$HOME/.cargo/env.fish"

starship init fish | source

if status is-login
    if uwsm check may-start
        and uwsm select
        exec uwsm start default
    end
end
