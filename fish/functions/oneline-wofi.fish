function oneline-wofi --description 'Single-line input via wofi dmenu'
    wofi --dmenu --prompt "Task: " < /dev/null $argv
end
