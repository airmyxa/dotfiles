fish_add_path /opt/homebrew/bin /opt/homebrew/sbin
fish_add_path $HOME/bin $HOME/.local/bin $HOME/.cargo/bin $HOME/go/bin
fish_add_path $HOME/.local/share/nvm/v22.14.0/bin
fish_add_path $HOME/.opencode/bin

set -gx BAT_THEME "Catppuccin Mocha"
set -gx MANPAGER "nvim +Man!"
set -gx GOPATH $HOME/go
set -gx ELECTRON_OZONE_PLATFORM_HINT wayland

if status is-interactive
    if command -q starship
        starship init fish | source
    end
    if command -q zoxide
        zoxide init fish | source
    end
    if command -q fzf
        fzf --fish | source
    end
end

# Alacritty compatibility: Option as Alt for unicode keybindings
bind B backward-bigword
bind F forward-bigword


# Added by Antigravity CLI installer
set -gx PATH "/Users/axymria/.local/bin" $PATH
