#!/bin/bash

# If you want to use this, just add some codes as follow into ~/.bashrc
# if [ -f ~/.magicnote_complete.bash ]; then
#     source ~/.magicnote_complete.bash
# fi

function magicnote_complete()
{
    local cur prev opts base
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # level 1 list
    opts="addsource ls add rm edit find run revert show gc"

    # level 2 list
    case "${prev}" in
        ls)
            local ls_list="-p"
            COMPREPLY=( $(compgen -W "${ls_list}" -- ${cur}) )
            return 0
            ;;
        add)
            local add_list="-t"
            COMPREPLY=( $(compgen -W "${add_list}" -- ${cur}) )
            return 0
            ;;
        find)
            local find_list="-p"
            COMPREPLY=( $(compgen -W "${find_list}" -- ${cur}) )
            return 0
            ;;
        show)
            local show_list="-v"
            COMPREPLY=( $(compgen -W "${show_list}" -- ${cur}) )
            return 0
            ;;
        magicnote)
            COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
            return 0
            ;;
        *)
            ;;
    esac

    return 0
}

complete -F magicnote_complete magicnote
