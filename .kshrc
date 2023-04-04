# Shell resource file
#

set -o emacs
set -o ignoreeof
set -o trackall

# Source global definitions and OS environment
#
if [ -r /etc/kshrc ]; then
    source /etc/kshrc
fi

if [ -r /etc/environment ]; then
    source /etc/environment
fi

typeset LC_ALL="C"
typeset LC_TIME="POSIX"
typeset LANG="en_GB.UTF-8"
typeset SHELL="/bin/ksh"
typeset OS=$(uname -s)
typeset -u HOSTNAME=$(hostname -s)
typeset PRD=${PWD/$HOME\//}
typeset TERM_TITLE=$(tty); TERM_TITLE=${TERM_TITLE##*/}
typeset -x LC_ALL LC_TIME LANG SHELL OS HOSTNAME PRD TERM_TITLE

# Conditional PATH updates
#
[[ -d ~/bin ]] && PATH+=:~/bin
[[ -d /usr/local ]] && PATH+=:/usr/local/bin:/usr/local/sbin
[[ -d /usr/local/opt/gettext/bin ]] && PATH+=:/usr/local/opt/gettext/bin

# User specific aliases and functions
#
if [[ ${OS} == FreeBSD ]];then
    typeset MD5=$(which md5)
    alias md5sum='md5 -r'
    alias ls='ls -G -D "%Y-%m-%d %H:%M"'
elif [[ ${OS} == Darwin ]]; then
    typeset MD5=$(which md5)
    alias md5sum='md5 -r'
    alias ls='ls -G'
    alias eject='diskutil eject'
elif [[ ${OS} =~ Linux ]]; then
    typeset MD5=$(which md5sum)
    alias ls='ls --color'
    export TIME_STYLE=long-iso
else
    print "WARNING: Operating System unknown"
fi

# Variables that determine whether and how often a Git upstream is checked.
#
typeset -i CD_CHECK
typeset CD_FILE=~/.gitconfig
typeset -x CD_CHECK CD_FILE

# Continued general aliases
alias la='ls -a'
alias lf='ls -F'
alias ll='ls -l'
alias l.='ls -l ${PWD}'
alias lsd='ls -ld'
alias lm='/bin/ls'
alias lt='ls -t'
alias llt='ls -lcr'
alias lrt='ls -lctr'
alias cdb='cd $OLDPWD'
alias pwe='openssl enc -aes-256-cbc -salt -in ~/.pw.txt -out ~/.pw.enc && rm ~/.pw.txt'
alias pwc='openssl enc -aes-256-cbc -d -in ~/.pw.enc -out ~/.pw.txt'
alias wn='printf "%(%W)T\n" now'
alias sssh='pssh -i -t8 -x " -q"'
alias ssssh='pssh -i -t8 -x " -q" -x " -tt"'

# Colour aliases for prompts (e.g `cd` function command
alias fgw='export COL_NORM=${COL_WHITE}'
alias fgk='export COL_NORM=${COL_BLACK}'
alias fgg='export COL_NORM=${COL_GREY}'
alias fgy='export COL_NORM=${COL_GREEN}'

# Some other useful alises
alias line='grep -n --colour'

# Set up per-session histories
#
if test -t 0; then
    if [[ ! -d ~/.local ]]; then
        mkdir ~/.local
    fi

    HISTFILE=~/.local/ksh-hist$(tty | tr / .)
    touch ${HISTFILE}
fi

# Load user-defined functions/commands from library files
#
if [[ -d ~/lib/ksh ]]; then
    for USERFUNC in ~/lib/ksh/*; do
        if [[ -f ${USERFUNC} ]]; then
            source ${USERFUNC}
        fi
    done
fi

# Begin functions and aliases for `cd` program/pretty prompts
#
function xdate {
    typeset _x_datestamp _x_datestring _x_datearg;

    if (( ${#} > 0 )); then
        for _x_datearg in ${@}; do
            if (( ${#_x_datearg} > 8 )) || (( ${#_x_datearg} < 8 )); then
                printf "error: %s is not a valid xdate string\n" ${_x_datearg}
                _x_pdate=false
                continue
            elif [[ ${_x_datearg} =~ [0-9,a-f,A-F] ]]; then
                if [[ ${_x_datearg} =~ 0x ]]; then
                    _x_datestamp=$(printf "%d" ${_x_datearg})
                else
                    _x_datestamp=$(printf "%d" 0x${_x_datearg})
                fi
                _x_datestring=$(printf '%(%FT%T)T' '#'${_x_datestamp})
            else
                _x_datestring=$(printf "%X" ${1})
            fi
            print ${_x_datestring}
        done
    else
        _x_datestring=$(printf "%X" $(printf '%(%s)T' now))
        print ${_x_datestring}
    fi

}

function oldxdate {
    typeset _ox_datestamp _ox_datestring _ox_datearg;

    if (( $# > 0 )); then
        for _ox_datearg in $@; do
            if [[ ${_ox_datearg} =~ [0-9,a-f,A-F] ]]; then
                if [[ ${_ox_datearg} =~ 0x ]]; then
                    _ox_datestamp=$(printf "%d" ${_ox_datearg})
                else
                    _ox_datestamp=$(printf "%d" 0x${_ox_datearg})
                fi
                _ox_datestring=$(print ${_ox_datestamp} | sed -e 's/\(....\)\(..\)\(..\)\(..\)\(..\)\(..\)/\1-\2-\3T\4:\5:\6/g')
            else
                _ox_datestring=$(printf "%X" $1)
            fi
        done
    else
        _ox_datestring=$(printf "%X" $(date +"%Y%m%d%H%M%S"))
    fi

    print ${_ox_datestring}
}

# Now for lots of extra code to make pretty prompts
export hosttype=""

export COL_FG=""
export COL_NORM=""
export COL_BOLD=""
export COL_UNBOLD=""
export COL_UBAR=""
export COL_UNUBAR=""
export COL_RED=""
export COL_GREEN=""
export COL_BLUE=""
export COL_BLACK=""
export COL_GREY=""

typeset CURRDIR
typeset STATA

typeset -i infocols=24 columns=$(tput cols)

if [[ -x $(type -p tput) ]]; then
    COL_BOLD="$(tput smso)"
    COL_UNBOLD="$(tput rmso)"
    COL_UBAR="$(tput smul)"
    COL_UNUBAR="$(tput rmul)"
    COL_BLACK="$(tput setaf 0)"
    COL_RED="$(tput setaf 1)"
    COL_GREEN="$(tput setaf 2)"
    COL_YELLOW="$(tput setaf 3)"
    COL_BLUE="$(tput setaf 4)"
    COL_GREY="$(tput setaf 6)"
    COL_LTGREY="$(tput setaf 7)"
    COL_DKGREY="$(tput setaf 8)"
    COL_WHITE="$(tput setaf 9)"
    COL_NORM="${COL_DKGREY}"
    COL_FG="${COL_BLACK}"

    case "${TERM}" in
        xterm*|vt100|screen|eterm-color)
            COL_NORM="${COL_DKGREY}"
            COL_FG="${COL_BLACK}"
            ;;
        linux)
            COL_NORM="${COL_LTGREY}"
            COL_FG="${COL_WHITE}"
            ;;
        *) print -u2 "WARNING: unknown terminal type ${TERM}; not setting prompt colours" ;;
    esac
else
    print -u2 "NOTICE: unable to run tput command; not setting prompt colours"
fi

typeset hn="@${HOSTNAME}";

strata() {
    if [[ -z ${hosttype} ]]; then
        case ${HOSTNAME} in
            *) hosttype="Lo";;
        esac
    fi

    hosttype=${hosttype:-Un}
    print "${hosttype}"
}

typeset STRATA="$(strata)"
typeset WHOWHERE="$(whoami)${hn}"
typeset INFOLINE="${SHELL}"
typeset SLINE=""
typeset BRANCH=""
typeset COMMIT_ID=""
typeset OLD_COMMIT_ID=""
typeset -a VCSINFO=()
typeset -a GITAB=()

is_gitrepo() {
    typeset _is_grdir=${PWD}

    while [[ ${_is_grdir} != "" ]]; do
        [[ -d ${_is_grdir}/.git ]] && return 0
        _is_grdir=${_is_grdir%/*}
    done

    return 1
}

gitpoll() {
    touch ${CD_FILE}

    git fetch origin ${BRANCH} > /dev/null 2>&1
    if (( $? != 0 )); then
        GITAB=( -1 -1 )
     else
        GITAB=( $(git rev-list --left-right --count ${BRANCH}...origin/${BRANCH}) )
    fi
}

cd_checkupstream() {
    typeset -i _cd_file_time=$(stat -f "%m" ${CD_FILE})
    typeset -i _cd_time=$(printf "%(%s)T" now)
    typeset -a _cd_cmds=( $(hist -l -n -N 1) )
    typeset -a _cd_gitc=(
      pull
      push
      commit
    )

    if (( CD_CHECK > 0 )); then
        if (( (( _cd_time - _cd_file_time )) > CD_CHECK )); then
            gitpoll
        elif (( ${#GITAB[@]} < 2 )) || [[ -z ${GITAB[@]} ]]; then
            gitpoll
        elif [[ ${OLD_COMMIT_ID} != ${COMMIT_ID} ]]; then
            gitpoll
        else
            for _cd_sub in ${_cd_gitc[@]}; do
                if [[ ${_cd_cmd[@]} =~ "git ${_cd_sub}" ]]; then
                    gitpoll
                    break
                fi
            done
        fi

        OLD_COMMIT_ID=${COMMIT_ID}
    fi
}

cd() {
    typeset _cd_gs _cd_cwd _vcc _vccpref _vccpost _shrt_prmt _long_prmt
    typeset -i _cd_gi _cd_cu _infolen

    if [[ ${1} == -d ]]; then
        if [[ -d ${2} ]]; then
            print -u2 "directory ${2} exists"
        else
            mkdir "${2}"
            print -u2 "created directory ${2}"
        fi

        command cd "${2}"
    else
        command cd "${@}"
    fi

    columns=$(tput cols)
    PRD=${PWD/$HOME\//}

    if [[ -r ./.svn/all-wcprops ]]; then
        VCSINFO=( $(sed -n 's/^\/svn\/repos\///g;s/\/\!/ /g;s/svn\/ver\///g;s/\([0-9]*\)\//\1:\//p' ./.svn/all-wcprops) )

        if (( ${#VCSINFO[@]} < 2 )); then
            CURRDIR="$(printf "%sSVN%s %s%s" "${COL_BLUE}" "${COL_GREEN}" "${PWD##*/}" "${COL_NORM}")"
        else
            CURRDIR="$(printf "%s%s %sSVN v.%s%s" "${COL_BLUE}" ${VCSINFO[0]} "${COL_GREEN}" ${VCSINFO[1]} "${COL_NORM}")"
        fi
    elif [[ ${PWD} =~ /.git ]]; then
        _pdng=${PWD/\/.git}
        _pd=${_pdng##*/}
        CURRDIR="$(printf "%s%s/%s%s.git%s%s" "${COL_BLUE}" "${_pd}" "${COL_BOLD}" "${COL_RED}" "${COL_UNBOLD}" "${COL_NORM}")"
    elif $(is_gitrepo); then
        _vcc=$(git config remote.origin.url)
        _vccpref=${_vcc#http*\/\/}
        _vccpref=${_vcc#git@}
        _vccpost=${_vcc##*/}
        VCSINFO=( ${_vccpref%%/*} ${_vccpost%.git} )
        BRANCH=$(git rev-parse --abbrev-ref HEAD)
        COMMIT_ID=$(git rev-list -n 1 ${BRANCH})

        if (( ${#VCSINFO[@]} < 2 )); then
            CURRDIR="$(printf "%sGit %s%s%s" "${COL_BLUE}" "${COL_YELLOW}" "${PWD##*/}" "${COL_NORM}")"
        else
            _cd_gs="$(git status 2>&1)"
            _cd_cwd="$(print ${PWD#$HOME/code} | tr -d "[:alnum:]_.-")${PWD##*/}"
            _cd_gi=$(egrep -c -v '^#' $(git rev-parse --show-toplevel)/.git/info/exclude)

            cd_checkupstream

            case ${VCSINFO[0]} in
                'ssh:'|'http:'|'https:')
                    VCSINFO[0]=${VCSINFO[0]/:}
                    ;;
            esac

            if (( _cd_gi > 0 )); then
                _cd_cwd="!!${_cd_cwd}"
            fi

            if [[ "${_cd_gs}" =~ "unmerged paths" ]]; then
                BRANCH+='|MERGING'
                SLINE="${COL_GREEN}${_cd_cwd}${COL_NORM}"
            elif [[ "${_cd_gs}" =~ "have diverged" ]]; then
                BRANCH+='|DIVERGENT'
                SLINE="${COL_YELLOW}${COL_UBAR}${_cd_cwd}${COL_UNUBAR}${COL_NORM}"
            elif [[ "${_cd_gs}" =~ "modified" ]] || [[ "${_cd_gs}" =~ "Changes to be committed" ]]; then
                SLINE="${COL_RED}${COL_BOLD}${_cd_cwd}${COL_UNBOLD}${COL_NORM}"
            elif [[ "${_cd_gs}" =~ "Your branch is ahead" ]]; then
                SLINE="${COL_YELLOW}${COL_BOLD}${_cd_cwd}${COL_UNBOLD}${COL_NORM}"
            elif [[ "${_cd_gs}" =~ "Untracked files" ]]; then
                SLINE="${COL_UBAR}${_cd_cwd}${COL_UNUBAR}${COL_NORM}"
            else
                SLINE="${COL_WHITE}${_cd_cwd}${COL_NORM}"
            fi

            _shrt_prmt="$(printf "%sGit %s%s:%s \"%s\"" \
              "${COL_BLUE}" "${COL_YELLOW}" ${VCSINFO[1]} "${SLINE}" "${BRANCH}")"
            _long_prmt="$(printf "%sGit %s %s%s:%s \"%s\"" \
              "${COL_BLUE}" ${VCSINFO[0]} "${COL_YELLOW}" ${VCSINFO[1]} "${SLINE}" "${BRANCH}")"

            if (( CD_CHECK < 1 )); then
                if (( (( infocols + ${#VCSINFO[0]} + ${#VCSINFO[1]} )) > (( columns / 2 )) )); then
                    CURRDIR=${_shrt_prmt}
                else
                    CURRDIR=${_long_prmt}
                fi
            else
                (( _infolen = infocols + ${#VCSINFO[0]} + ${#VCSINFO[1]} + ${#BRANCH} ))
                if (( _infolen > (( columns / 2 )) )); then
                    CURRDIR="${_shrt_prmt} (${GITAB[0]}|${GITAB[1]})"
                else
                    CURRDIR="${_long_prmt} (${GITAB[0]}|${GITAB[1]})"
                    #CURRDIR="$(printf "%sGit %s %s%s:%s \"%s\" (%d|%d)" \
                    #  "${COL_BLUE}" ${VCSINFO[0]} "${COL_YELLOW}" ${VCSINFO[1]} "${SLINE}" "${BRANCH}" ${GITAB[0]} ${GITAB[1]})"
                fi
            fi
        fi
    else
        VCSINFO=( 0 0 )
        _cd_cwd=${PWD/$HOME/\~}
        CURRDIR="${COL_GREEN}$(print ${_cd_cwd} | tr -d "[:alnum:]_.-")${PWD##*/}${COL_NORM}"
    fi

    if (( infocols + ${#CURRDIR} > columns )); then
        INFOLINE="${COL_BOLD}${STRATA}${COL_UNBOLD}"
    else
        INFOLINE="${WHOWHERE} ${COL_BOLD}${STRATA}${COL_UNBOLD}"
    fi

    command cd .
}

getdirstat() {
    cd .
    print ${CURRDIR}
}

termtitle() {
    case ${TERM} in
        *xterm*)
            printf "\033]0;${TERM_TITLE}\007"
            ;;
        *)
            return
            ;;
    esac
}

PS1='$(termtitle)${COL_NORM}[ ${INFOLINE} $(xdate) $(getdirstat) ]
${COL_NORM}$ ${COL_FG}'

# The localenv file should exist and contain, at a minimum, the line:
# cd
[ -r ~/.localenv ] && . ~/.localenv
