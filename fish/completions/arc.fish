function __fish_arc_files
    # print information about arc files in following format
    # path/to/file status_description
    #
    # example:
    #
    # path/to/file Deleted file
    # path/to/other/file Added file

    set -l files (command arc status --short)
    for f in $files
        set -l file (string sub -s 4 -- $f)
        set -l mode (string sub -l 2 -- $f)
        set -l desc
        switch $mode
            case ' M'
                set desc "Modified file"
            case '\?\?'
                set desc "Added file"
            case ' D'
                set desc "Deleted file"
            case '*'
                continue
        end

        printf '%s\t%s\n' "$file" $desc

    end
end

function __fish_arc_remote_branches
    set -l branches (command arc branch -a | grep "arcadia/")
    for b in $branches
        set -l name (string sub -s 3 -- $b)
        printf '%s\t%s\n' "$name" "Remote Branch"
    end
end

function __fish_arc_local_branches
    set -l branches (command arc branch)
    for b in $branches
        set -l name (string sub -s 3 -- $b)
        printf '%s\t%s\n' "$name" "Local Branch"
    end
end

function __fish_arc_all_branches
    __fish_arc_local_branches
    __fish_arc_remote_branches
end

complete -c arc -x # disable dir completeion

# version
complete -c arc -n '__fish_use_subcommand' -a 'version' -d 'Get arc version with build metadata'

# help
complete -c arc -n '__fish_use_subcommand' -a 'help' -d 'Display the manual of a arc command'

# init
complete -c arc -n '__fish_use_subcommand' -a 'init' -d 'Initialize environment for a local repository'

# mount
complete -c arc -n '__fish_use_subcommand' -a 'mount' -d 'Initialize environment with virtual working tree'
complete -c arc -n '__fish_seen_subcommand_from mount' -s h -l help -d 'Print usage'
complete -c arc -n '__fish_seen_subcommand_from mount' -r -s m -l mount -d 'Mount path'
complete -c arc -n '__fish_seen_subcommand_from mount' -r -s S -l store -d 'Path to store fetched objects'
complete -c arc -n '__fish_seen_subcommand_from mount' -x -s s -l server -d 'Address of vcs data service (default: "arc-vcs.yandex-team.ru")'
complete -c arc -n '__fish_seen_subcommand_from mount' -x -s p -l port -d 'Port of vcs data service (default: 5623)'
complete -c arc -n '__fish_seen_subcommand_from mount' -x -l log -d 'Path to log file'
complete -c arc -n '__fish_seen_subcommand_from mount' -x -l pull-server -d 'Address of vcs pull service (default: "arc-vcs.yandex-team.ru")'
complete -c arc -n '__fish_seen_subcommand_from mount' -x -l pull-port -d 'Port of vcs pull service (default: 7057)'
complete -c arc -n '__fish_seen_subcommand_from mount' -x -s r -l repository -d 'NAME name of the repository (default: "arcadia")'
complete -c arc -n '__fish_seen_subcommand_from mount' -x -s c -l commit -d 'Commit id'
complete -c arc -n '__fish_seen_subcommand_from mount' -x -s b -l branch -d 'Branch name'
complete -c arc -n '__fish_seen_subcommand_from mount' -l local -d 'Initialize local repository'
complete -c arc -n '__fish_seen_subcommand_from mount' -s F -l foreground -d 'Run FUSE in foreground mode'
complete -c arc -n '__fish_seen_subcommand_from mount' -s D -l debug -d 'Enable FUSE debug output'
complete -c arc -n '__fish_seen_subcommand_from mount' -l allow-root -d 'Allow root access to the mounted filesystem'
complete -c arc -n '__fish_seen_subcommand_from mount' -l no-threads -d 'Run FUSE in single thread mode'
complete -c arc -n '__fish_seen_subcommand_from mount' -x -s C -l cache-size -d 'Memory size for cache in bytes'
complete -c arc -n '__fish_seen_subcommand_from mount' -l fetch-trees -d 'Prefetch directory entries in background'

# add
complete -c arc -n '__fish_use_subcommand' -a 'add' -d 'Add file contents to the index'
complete -c arc -n '__fish_seen_subcommand_from add' -s A -l all -d 'Add changes from all tracked and untracked files'
complete -c arc -n '__fish_seen_subcommand_from add' -s n -l dry-run -d 'Dry run'
complete -c arc -n '__fish_seen_subcommand_from add' -s u -l update -d 'Update tracked files'
complete -c arc -n '__fish_seen_subcommand_from add' -s v -l verbose -d 'Be verbose'
complete -c arc -n '__fish_seen_subcommand_from add' -a '(__fish_arc_files)'

# mv
complete -c arc -n '__fish_use_subcommand' -a 'mv' -d 'Move or rename a file, a directory, or a symlink'

# reset
complete -c arc -n '__fish_use_subcommand' -a 'reset' -d 'Reset current HEAD to the specified state'

# rm
complete -c arc -n '__fish_use_subcommand' -a 'rm' -d 'Remove files from the working tree and from the index'

# diff
complete -c arc -n '__fish_use_subcommand' -a 'diff' -d 'Show changes between commits, commit and working tree, etc'

# log
complete -c arc -n '__fish_use_subcommand' -a 'log' -d 'Show commit logs'

# show
complete -c arc -n '__fish_use_subcommand' -a 'show' -d 'Show various types of objects'

# status
complete -c arc -n '__fish_use_subcommand' -a 'status' -d 'Show the working tree status'
complete -c arc -n '__fish_seen_subcommand_from status' -s b -l branch -d 'Show branch information'
complete -c arc -n '__fish_seen_subcommand_from status' -s s -l short -d 'Show status concisely'
complete -c arc -n '__fish_seen_subcommand_from status' -l json -d 'Output in json format'
complete -c arc -n '__fish_seen_subcommand_from status' -s u -a 'all no normal' -d 'Show untracked files (default: "normal")'
complete -c arc -n '__fish_seen_subcommand_from status' -l ignored -d 'Show ignored files'
complete -c arc -n '__fish_seen_subcommand_from status' -l no-ahead-behind -d 'Do not display detailed ahead/behind counts'

# root
complete -c arc -n '__fish_use_subcommand' -a 'roow' -d 'Show working tree root'

# branch
complete -c arc -n '__fish_use_subcommand' -a 'branch' -d 'List, create, or delete branches'
complete -c arc -n '__fish_seen_subcommand_from branch' -s v -l verbose -d 'Show hash and subject'
complete -c arc -n '__fish_seen_subcommand_from branch' -a '(__fish_arc_remote_branches)' -s u -l set-upstream-to -x -d 'Change the upstream info'
complete -c arc -n '__fish_seen_subcommand_from branch' -s a -l all -a '(__fish_arc_all_branches)' -d 'List both remote-tracking and local branches'
complete -c arc -n '__fish_seen_subcommand_from branch' -s d -l delete -a '(__fish_arc_local_branches)' -x -d 'Delete fully merged branch'
complete -c arc -n '__fish_seen_subcommand_from branch' -s D -a '(__fish_arc_local_branches)' -x -d 'Delete branch (even if not merged)'
complete -c arc -n '__fish_seen_subcommand_from branch' -l list -d 'List branch names'
complete -c arc -n '__fish_seen_subcommand_from branch' -s f -l force -d 'Force creation, move/rename, deletion'
complete -c arc -n '__fish_seen_subcommand_from branch' -l merged -x -a '(__fish_arc_all_branches)' -d 'Print only branches that are merged'
complete -c arc -n '__fish_seen_subcommand_from branch' -l points-at -d 'Print only branches of the object'
complete -c arc -n '__fish_seen_subcommand_from branch' -l json -d 'Output in json format'
complete -c arc -n '__fish_seen_subcommand_from branch' -l desc -d 'Dranch description'

# checkout
complete -c arc -n '__fish_use_subcommand' -a 'checkout' -d 'Switch branches or restore working tree files'
complete -c arc -n '__fish_seen_subcommand_from checkout' -a '(__fish_arc_local_branches)' -d 'Switch working tree to branch'

# commit
complete -c arc -n '__fish_use_subcommand' -a 'commit' -d 'Record changes to the repository'
complete -c arc -n '__fish_seen_subcommand_from commit' -s F -l 'file' -r -d 'Read commit message from file'
complete -c arc -n '__fish_seen_subcommand_from commit' -s m -l message -d 'Commit message'
complete -c arc -n '__fish_seen_subcommand_from commit' -s a -l all -d 'Commit all changed files'
complete -c arc -n '__fish_seen_subcommand_from commit' -l dry-run -d 'Show what would be committed'
complete -c arc -n '__fish_seen_subcommand_from commit' -l allow-empty-message -d 'Allow to create a commit with an empty commit message'
complete -c arc -n '__fish_seen_subcommand_from commit' -s e -l edit -d 'Further edit message taken from file with -F, command line with -m'
complete -c arc -n '__fish_seen_subcommand_from commit' -l amend -d 'Amend previous commit'
complete -c arc -n '__fish_seen_subcommand_from commit' -l no-edit -d 'Use the selected commit message without launching an editor'

# merge
complete -c arc -n '__fish_use_subcommand' -a 'merge' -d 'Join two development histories together'

# rebase
complete -c arc -n '__fish_use_subcommand' -a 'rebase' -d 'Forward-port local commits to the updated upstream head'
complete -c arc -n '__fish_seen_subcommand_from rebase' -a '(__fish_arc_local_branches)' -d 'Rebase onto branch'

# fetch
complete -c arc -n '__fish_use_subcommand' -a 'fetch' -d 'Download refs from remote repository'

# pull
complete -c arc -n '__fish_use_subcommand' -a 'pull' -d 'Fetch from remote repository and integrate with a local branch'
complete -c arc -n '__fish_seen_subcommand_from pull' -a '(__fish_arc_local_branches)' -d 'Pull branch'

# push
complete -c arc -n '__fish_use_subcommand' -a 'push' -d 'Update remote refs along with associated objects'
complete -c arc -n '__fish_seen_subcommand_from push' -a '(__fish_arc_local_branches)' -d 'Push branch'
complete -c arc -n '__fish_seen_subcommand_from push' -a '(__fish_arc_local_branches)' -l force -d 'Force push branch'

# pr
complete -c arc -n '__fish_use_subcommand' -a 'pr' -d 'Create a pull request'
complete -c arc -n '__fish_seen_subcommand_from pr' -s h -l help -d 'Print usage'
# pr list
complete -c arc -n '__fish_seen_subcommand_from pr;' -a 'list' -d 'List pull requests'
complete -c arc -n '__fish_seen_subcommand_from pr; and __fish_seen_subcommand_from list' -s h -l help -d 'Print usage'
complete -c arc -n '__fish_seen_subcommand_from pr; and __fish_seen_subcommand_from list' -s a -l all -d 'List all pull requests'

# pr create
complete -c arc -n '__fish_seen_subcommand_from pr;' -a 'create' -d 'Create pull request'
complete -c arc -n '__fish_seen_subcommand_from pr; and __fish_seen_subcommand_from create' -s h -l help -d 'Print usage'

# pr select
complete -c arc -n '__fish_seen_subcommand_from pr;' -a 'select' -d ' View changes of PR by target branch'
complete -c arc -n '__fish_seen_subcommand_from pr; and __fish_seen_subcommand_from select' -s h -l help -d 'Print usage'
complete -c arc -n '__fish_seen_subcommand_from pr; and __fish_seen_subcommand_from select' -l svnrevision -d 'print svn version'
complete -c arc -n '__fish_seen_subcommand_from pr; and __fish_seen_subcommand_from select' -s S -l submitted -d 'View changes of last submitted to PR (default: 0)'

# pr changes
complete -c arc -n '__fish_seen_subcommand_from pr;' -a 'changes' -d 'View changes of PR'
complete -c arc -n '__fish_seen_subcommand_from pr; and __fish_seen_subcommand_from changes' -s h -l help -d 'Print usage'
complete -c arc -n '__fish_seen_subcommand_from pr; and __fish_seen_subcommand_from changes' -l svnrevision -d 'print svn version'
complete -c arc -n '__fish_seen_subcommand_from pr; and __fish_seen_subcommand_from changes' -s S -l submitted -d 'View changes of last submitted to PR (default: 0)'

# submit
complete -c arc -n '__fish_use_subcommand' -a 'submit' -d 'Submit a revision'

complete -c arc -n '__fish_seen_subcommand_from submit' -l svnrevision -d 'print svn version'
complete -c arc -n '__fish_seen_subcommand_from submit' -s h -l help -d 'Print usage'
complete -c arc -n '__fish_seen_subcommand_from submit' -l abort -d 'abort and check out the original state'

complete -c arc -n '__fish_seen_subcommand_from submit' -l all -d 'submit untracked files'
complete -c arc -n '__fish_seen_subcommand_from submit' -l new -d 'create new PR from current unsubmitted changes'
complete -c arc -n '__fish_seen_subcommand_from submit' -l stack -d 'create new PR that includes current submitted and unsubmitted changes'
complete -c arc -n '__fish_seen_subcommand_from submit' -s m -l message -d 'review description'
complete -c arc -n '__fish_seen_subcommand_from submit' -s F -l file --force-files -r -d 'read review description from file'
complete -c arc -n '__fish_seen_subcommand_from submit' -s e -l edit -d 'further edit message taken from file with -F or command line with -m'
complete -c arc -n '__fish_seen_subcommand_from submit' -l no-edit -d 'use the selected commit message without launching an editor'
complete -c arc -n '__fish_seen_subcommand_from submit' -l skip-hook -d 'skip specific hook'
complete -c arc -n '__fish_seen_subcommand_from submit' -s n -l no-verify -d 'bypass all hooks'
complete -c arc -n '__fish_seen_subcommand_from submit' -l to -a '(__fish_arc_remote_branches)' -r -d 'target branch of PR'
complete -c arc -n '__fish_seen_subcommand_from submit' -l skip-linter -f -r -d 'skip specific linter in format <glob>:<linter-id>'
complete -c arc -n '__fish_seen_subcommand_from submit' -l auto -d 'shortcut for --publish --no-code-review --merge. Merge PR after all checks except Code Review have passed'
complete -c arc -n '__fish_seen_subcommand_from submit' -s M -l merge -d 'enable automatic merging'
complete -c arc -n '__fish_seen_subcommand_from submit' -l publish -d 'publish pull request'
complete -c arc -n '__fish_seen_subcommand_from submit' -l code-review -d 'enable arcanum Code Review check'
complete -c arc -n '__fish_seen_subcommand_from submit' -l no-code-review -d 'disable arcanum Code Review check'
complete -c arc -n '__fish_seen_subcommand_from submit' -l view -d 'open the pull request in a web browser'
complete -c arc -n '__fish_seen_subcommand_from submit' -l label -f -r -d 'add label to the pull request, can be used multiple times, examples: proj/label1, proj/label2'


# up
complete -c arc -n '__fish_use_subcommand' -a 'up' -d 'Update current PR to the freshest upstream (usually trunk)'
complete -c arc -n '__fish_seen_subcommand_from up' -l svnrevision -d 'print svn version'
complete -c arc -n '__fish_seen_subcommand_from up' -s h -l help -d 'Print usage'
complete -c arc -n '__fish_seen_subcommand_from up' -l abort -d 'Abort the current conflict resolution process, and try to reconstruct the state before arc up'
complete -c arc -n '__fish_seen_subcommand_from up' -l to -a '(__fish_arc_remote_branches)' -r -d 'Update to given branch or commit, you can use as value: branch, commit, revision, other hash value (branch~N, HEAD@{N}, so on) (default: "trunk")'

# cherry-pick
complete -c arc -n '__fish_use_subcommand' -a 'cherry-pick' -d 'Apply one commit'
