function setup_tars_fzf

  function tars-get-completions
    set cmd (commandline -opc)
    if [ (count $cmd) -eq 1 ]
      cat $HOME/.cache/tars/completion/commands
      return
    end

    if [ (count $cmd) -gt 2 ]
      return
    end

    set tars_command $cmd[2]
    switch $tars_command
      case service hostlist ssh p_exec
        set completion_source services
      case database
        set completion_source databases
      case stq
        set completion_source stq_queues
      case grafana
        set completion_source grafana
      case config
        set completion_source config_v1
      case handler
        set completion_source handler
      case '*'
        return
    end

    set current_word (commandline -ct)
    set regex_pattern (eval echo $current_word | sed 's/\(.\)/\1.*/g')

    grep -i $regex_pattern $HOME/.cache/tars/completion/$completion_source
  end

  function tars-completion-command
    set -l cmd (commandline)
    switch $cmd
      case 'tars *'
        set -l completions (tars-get-completions)
        echo "echo '$completions' | tr ' ' '\n' "
      case '*'
        return 1
    end
  end

  function tars-fzf-completion
    set -l commandline (__fzf_parse_commandline)
    set -l dir $commandline[1]
    set -l fzf_query $commandline[2]

    set -l FZF_CMD (tars-completion-command); or return

    # fzf edge case and formatting (prevents fzf from taking up the whole screen)
    set FZF_HEIGHT 40%
    begin
      set -lx FZF_DEFAULT_OPTS "--height $FZF_HEIGHT --reverse $FZF_DEFAULT_OPTS $FZF_CMD[2]"
      eval "$FZF_CMD[1] | "(__fzfcmd)' -m --query "'$fzf_query'"' | while read -l r; set result $result $r; end
    end
    if [ -z "$result" ]
      commandline -f repaint
      return
    else
      # Remove last token from commandline.
      commandline -t ""
    end
    for i in $result
      commandline -it -- (string escape $i)
      commandline -it -- ' '
    end
    commandline -f repaint
  end

  bind -M insert \ce tars-fzf-completion
  bind \ce tars-fzf-completion

end
