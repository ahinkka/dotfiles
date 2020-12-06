if [ -f "$HOME/.bash_profile.local" ]; then
    . "$HOME/.bash_profile.local"
fi

if [ -f $HOME/.aliases ]; then
    . $HOME/.aliases
fi

function shorten_pwd
{
    MAX_PWD_LENGTH=$1
    PWD=$(pwd)

    # determine part of path within HOME, or entire path if not in HOME
    RESIDUAL=${PWD#$HOME}

    # compare RESIDUAL with PWD to determine whether we are in HOME or not
    if [ X"$RESIDUAL" != X"$PWD" ]; then
        PREFIX="~"
    fi

    # Takes a substring from each dash-separated name part, e.g.
    #   company-division-project-system => com-div-pro-sys
    DASH_AWARE_SHORTENER='BEGIN { FS="-"; } { printf "/"; printf substr($1, 1, 3); for(i=2;i<=NF;i++) { printf "-%s", substr($i, 1, 3) }; }'

    # Check if residual needs truncating to keep total length below the desired length
    NORMAL=${PREFIX}${RESIDUAL}
    if [ ${#NORMAL} -ge $(($MAX_PWD_LENGTH)) ]; then
        result=${PREFIX}
        OIFS=$IFS
        IFS='/'
        bits=$RESIDUAL
        for x in $bits; do
            if [ ${#x} -ge 3 ]; then
		NEXT=$(echo "$x" | awk "$DASH_AWARE_SHORTENER")
                # NEXT="/${x:0:1}"
            elif [ ${#x} -ge 1 ]; then
                NEXT="/$x"
	    else
                 NEXT="$x"
	    fi
            result="$result$NEXT"
        done

        IFS=$OIFS
    else
        result=${PREFIX}${RESIDUAL}
    fi

    echo $result
}

parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

export PS1="\h \[\033[32m\]\$(shorten_pwd 20)\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PROMPT_COMMAND='echo -ne "\033]0; $(pwd)\007"'

    # Show the currently running command in the terminal title:
    # http://www.davidpashley.com/articles/xterm-titles-with-bash.html
    show_command_in_title_bar()
    {
        case "$BASH_COMMAND" in
            *\033]0*)
                # The command is trying to set the title bar as well;
                # this is most likely the execution of $PROMPT_COMMAND.
                # In any case nested escapes confuse the terminal, so don't
                # output them.
                ;;
            *)
                echo -ne "\033]0; ${BASH_COMMAND}\007"
                ;;
        esac
    }
    trap show_command_in_title_bar DEBUG
    ;;
*)
    ;;
esac
