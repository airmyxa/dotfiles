export PATH=$HOME/bin:/usr/local/bin:$HOME/.cargo/bin:/usr/bin:/bin:/sbin:$HOME/go/bin:$HOME/.local/share/nvm/v22.14.0/bin:$PATH:
export BAT_THEME="Catppuccin Mocha"
export MANPAGER="nvim +Man!"
export GOPATH=$HOME/go

# aliases
alias --save obsidian="flatpak run md.obsidian.Obsidian --ozone-platform-hint=auto &> /dev/null &; echo"

if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source
    zoxide init fish | source
    fzf --fish | source
end

# For allacritty compatibility. Alacritty is configured to use Option as Alt
# and motions with unicode keycodes to use it in different shells. For example
# when entering remove shell where there is no my local configured shell.
# But fish need to support it's keybindings also.
bind \u001bB backward-bigword
bind \u001bF forward-bigword
