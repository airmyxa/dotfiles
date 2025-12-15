function askline --wraps='fuzzel --dmenu --prompt-only "Task: " < /dev/null' --description 'alias askline=fuzzel --dmenu --prompt-only "Task: " < /dev/null'
    fuzzel --dmenu --prompt-only "Task: " < /dev/null $argv
end
