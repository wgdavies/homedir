# Shell resource file
#

set -o emacs
set -o ignoreeof
set -o trackall

# Source global definitions
#
if [ -f /etc/kshrc ]; then
	. /etc/kshrc
fi

export LC_ALL="C"
export LANG="en_GB.UTF-8"
export OS=$(uname -o)
export HOSTNAME=$(hostname -s)

# Conditional PATH updates
#
export APP_HOME=/opt/app/home

for newpath in ${APP_HOME}; do
	if [[ -d ${newpath} ]]; then
		PATH=${PATH}:${newpath}/bin
	fi
done

# User specific aliases and functions
#
if [[ ${OS} == FreeBSD ]]; then
	alias ls='ls -G -D "%Y-%m-%d %H:%M"'
elif [[ ${OS} == GNU/Linux ]]; then
	alias ls='ls --color'
	export TIME_STYLE=long-iso
else
	print "WARNING: Operating System unknown"
fi

alias la='ls -a'
alias lf='ls -F'
alias ll='ls -l'
alias lsd='ls -ld'
alias lm='/bin/ls'
alias cdb='cd $OLDPWD'
alias cdt='cd ${PWD%/trunk/*}/trunk'
alias tl='jove ~/.tasks'

alias fgw='export COL_NORM=${COL_WHITE}'
alias fgk='export COL_NORM=${COL_BLACK}'
alias fgg='export COL_NORM=${COL_GREY}'
alias fgy='export COL_NORM=${COL_GREEN}'

# Various other nodes and aliases
alias gss='git status -s'
alias gca='git commit -a'

# Some other useful alises
alias line='grep -n'

# Useful functions
#
function man2pdf
{
    typeset -a mans=( $@ )
    typeset manpage

    if (( ${#mans[@]} > 0 )); then
	for manpage in ${mans[@]}; do
	    man -t ${manpage} | ps2pdf - ${manpage}.pdf
	done
    else
	print "specify one or more manpages for output to PDF"
    fi
}

function enumerate
{
	typeset -i linenum
	typeset line
	typeset readfile

	for readfile in $@; do
		printf "::::::::\nEnumerating %s\n::::::::\n" ${readfile}
		linenum=0
		OLDIFS="$IFS"
		IFS='\'

		while read -r line; do
			(( linenum++ ))
			printf "%4d: %s\n" ${linenum} "$line"
		done < ${readfile} | less
		
		IFS="$OLDIFS"
	done
}

function where {
	typeset string=$1
	typeset -a lines

	if [[ -z $2 ]]; then
		print "usage: where <string> <file(s)>"
	else
		printf "Searching for occurrences of %s...\n" ${string}
		for filename in ${@:2}; do
			if [[ -r ${filename} ]]; then
				lines=( $(grep -n ${string} ${filename} | cut -d: -f1) )
				
				printf "%s: %d lines; %s\n" ${filename} $(wc -l < ${filename}) "${lines[*]}"
			else
				printf "error: unable to read file: %s\n" ${filename}
			fi
		done
	fi
}

function xdate {
	typeset datestamp datestring datearg;

	if (( $# > 0 )); then
		for datearg in $@; do
			if [[ ${datearg} =~ [0-9,a-f,A-F] ]]; then
				if [[ ${datearg} =~ 0x ]]; then
					datestamp=$(printf "%d" ${datearg})
				else
					datestamp=$(printf "%d" 0x${datearg})
				fi
				datestring=$(date -d @${datestamp} +"%FT%T")
			else
				datestring=$(printf "%X" $1)
			fi
		done
	else
		datestring=$(printf "%X" $(date +"%s"))
	fi

	print ${datestring}
}

function oldxdate {
	typeset datestamp datestring datearg;

	if (( $# > 0 )); then
		for datearg in $@; do
			if [[ ${datearg} =~ [0-9,a-f,A-F] ]]; then
				if [[ ${datearg} =~ 0x ]]; then
					datestamp=$(printf "%d" ${datearg})
				else
					datestamp=$(printf "%d" 0x${datearg})
				fi
				datestring=$(print ${datestamp} | sed -e 's/\(....\)\(..\)\(..\)\(..\)\(..\)\(..\)/\1-\2-\3T\4:\5:\6/g')
			else
				datestring=$(printf "%X" $1)
			fi
		done
	else
		datestring=$(printf "%X" $(date +"%Y%m%d%H%M%S"))
	fi

	print ${datestring}
}

function whatkey {
	xev | \
	grep -A2 --line-buffered '^KeyRelease' | \
	sed -n '/keycode /s/^.*keycode \([0-9]*\).* (.*, \(.*\)).*$/\1 \2/p'
}

function git_id {
	printf 'blob %s\0' "$(ls -l "$1" | awk '{print $5;}')" | cat - "$1" | sha1sum | awk '{print $1}'
}

# Now for lots of extra code to make pretty prompts
export hosttype=""

export COL_NORM=""
export COL_BOLD=""
export COL_UNBOLD=""
export COL_RED=""
export COL_GREEN=""
export COL_BLUE=""
export COL_BLACK=""
export COL_GREY=""

typeset CURRDIR
typeset STATA

typeset -i infocols=72 columns=$(tput cols)

case "${TERM}" in
	xterm|vt100|screen|eterm-color)
		if [[ -x $(type -p tput) ]]; then
			COL_BOLD="$(tput smso)"
			COL_UNBOLD="$(tput rmso)"
			COL_BLACK="$(tput setaf 0)"
			COL_RED="$(tput setaf 1)"
			COL_GREEN="$(tput setaf 2)"
			COL_YELLOW="$(tput setaf 3)"
			COL_BLUE="$(tput setaf 4)"
			COL_GREY="$(tput setaf 6)"
			COL_WHITE="$(tput setaf 9)"
			COL_NORM="${COL_GREY}"
		fi
		;;
esac

strata() {
	if [[ -z ${hosttype} ]]; then
		case ${HOSTNAME} in
			*sv*) hosttype="VM";;
		esac
	fi
	
	hosttype=${hosttype:-Un}
	print "${hosttype}"
}

typeset STRATA="$(strata)"
typeset WHOWHERE="$(whoami)@${HOSTNAME}"
typeset INFOLINE="${SHELL}"
typeset SLINE=""
typeset BRANCH=""

is_gitrepo() {
	dir=$(pwd)

	while [[ ${dir} != "" ]]; do
		[[ -d ${dir}/.git ]] && exit 0
		dir=${dir%/*}
	done

	exit 1
}

cd() {
	command cd "$@"
	columns=$(tput cols)
	
	if [[ -r ./.svn/all-wcprops ]]; then
		VCSINFO=( $(sed -n 's/^\/svn\/repos\///g;s/\/\!/ /g;s/svn\/ver\///g;s/\([0-9]*\)\//\1:\//p' ./.svn/all-wcprops) )

		if (( ${#VCSINFO[@]} < 2 )); then
			CURRDIR="$(printf "%sSVN%s %s%s" "${COL_BLUE}" "${COL_GREEN}" "$(basename ${PWD})" "${COL_NORM}")"
		else
			CURRDIR="$(printf "%s%s %sSVN v.%s%s" "${COL_BLUE}" ${VCSINFO[0]} "${COL_GREEN}" ${VCSINFO[1]} "${COL_NORM}")"
		fi
	elif $(is_gitrepo); then
		VCSINFO=( $(git config remote.origin.url | sed -ne 's/.*:\(.*\)\/\(.*\).git$/\1 \2/p') )

		if (( ${#VCSINFO[@]} < 2 )); then
			CURRDIR="$(printf "%sGit %s%s%s" "${COL_BLUE}" "${COL_YELLOW}" "$(basename ${PWD})" "${COL_NORM}")"
		else
			BRANCH=$(git symbolic-ref HEAD) # $(git branch | sed -ne 's/* \(.*\)/\1/p')
			BRANCH=${BRANCH:##*/}
			git status 2>&1 | grep -q modified:
			if (( $? == 0 )); then SLINE="${COL_RED}"; else SLINE="${COL_WHITE}"; fi
			cwd="$(print ${PWD#$HOME/code/Git/GitLab/} | tr -d "[:alnum:]_.-")$(basename ${PWD})"
			CURRDIR="$(printf "%sGit %s %s%s:%s%s%s \"%s\"" "${COL_BLUE}" ${VCSINFO[0]} "${COL_YELLOW}" ${VCSINFO[1]} "${SLINE}" "${cwd}" "${COL_NORM}" "${BRANCH}")"
		fi
	else
		VCSINFO=( 0 0 )
		cwd=${PWD/$HOME/\~}
		CURRDIR="${COL_GREEN}$(print ${cwd} | tr -d "[:alnum:]_.-")$(basename ${PWD})${COL_NORM}"
	fi

	if (( infocols + ${#VCSINFO[0]} + ${#VCSINFO[1]} > columns )); then
		INFOLINE="${COL_BOLD}${STRATA}${COL_UNBOLD}"
	else
		INFOLINE="${WHOWHERE} ${COL_BOLD}${STRATA}${COL_UNBOLD}"
	fi
}

getdirstat() {
	cd .
	print ${CURRDIR}
}

PS1='${COL_NORM}[ ${INFOLINE} $(xdate) $(getdirstat) ]
${COL_NORM}$ ${COL_WHITE}'

[ -r ~/.localenv ] && . ~/.localenv
[ -r /etc/environment ] && . /etc/environment
