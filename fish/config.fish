export PATH=$HOME/bin:/usr/local/bin:/opt/homebrew/bin:~/.cargo/bin:/usr/bin:/bin:$PATH
export BAT_THEME="Catppuccin Mocha"

if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source
    zoxide init fish | source
    fzf --fish | source
end
