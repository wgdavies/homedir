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

typeset LC_ALL="C"
typeset LANG="en_GB.UTF-8"
typeset SHELL="/bin/ksh"
typeset OS=$(uname -s)
typeset -u HOSTNAME=$(hostname -s)
typeset PRD=${PWD/$HOME\//}
typeset TERM_TITLE=$(tty); TERM_TITLE=${TERM_TITLE##*/}
typeset -x LC_ALL LANG SHELL OS HOSTNAME PRD TERM_TITLE

# Conditional PATH updates
#
[[ -d ~/bin ]] && PATH=${PATH}:~/bin

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

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/tatti/bin/google-cloud-sdk/path.ksh.inc' ]; then source '/Users/tatti/bin/google-cloud-sdk/path.ksh.inc'; fi

alias la='ls -a'
alias lf='ls -F'
alias ll='ls -l'
alias lsd='ls -ld'
alias lm='/bin/ls'
alias cdb='cd $OLDPWD'
alias cdt='cd ${PWD%/trunk/*}/trunk'
alias tl='jove ~/.tasks'
alias pwe='openssl enc -aes-256-cbc -salt -in ~/.pw.txt -out ~/.pw.enc && rm ~/.pw.txt'
alias pwc='openssl enc -aes-256-cbc -d -in ~/.pw.enc -out ~/.pw.txt'
alias wn='printf "%(%W)T\n" now'
alias sssh='pssh -i -t8 -x " -q"'
alias ssssh='pssh -i -t8 -x " -q" -x " -tt"'

alias fgw='export COL_NORM=${COL_WHITE}'
alias fgk='export COL_NORM=${COL_BLACK}'
alias fgg='export COL_NORM=${COL_GREY}'
alias fgy='export COL_NORM=${COL_GREEN}'

# Some other useful alises
alias line='grep -n --colour'

# Useful functions
#
function .sh.math.aqr x
{
    (( .sh.value = (( x * x )) ))
}

function .sh.math.fac n
{
    typeset -li f=1 i

    for (( i = 2 ; i <= n ; ++i )); do
	(( f *= i ))
    done

    (( .sh.value = f ))
}

function awsput
{
    typeset _aws_key=${1}
    typeset _aws_app=${2}
    typeset _aws_des=${3}
    
    if [[ -z ${_aws_key} ]] || [[ ${_aws_key} == *(-)h*(elp) ]] \
	   || [[ -z ${_aws_app} ]] || [[ -z ${_aws_des} ]]; then
	print -u2 "usage: awsput <key> <app> <des>"
	print -u2 "       where"
	print -u2 "       <key> is application.zip ID (to be created by aws command)"
	print -u2 "       <app> is CD ApplicationName (from Console)"
	print -u2 "       <des> is application_Version_String (matches directory name_version)"
    else
	aws deploy push --application-name ${_aws_app} --s3-location s3://cashnet-codedeploy/${_aws_key} --source ./${_aws_des} --description ${_aws_des}
    fi
}

function awsget
{
    typeset _aws_key=${1}
    typeset _aws_ver=${2}
    
    if [[ -z ${_aws_key} ]] || [[ ${_aws_key} == *(-)h*(elp) ]] \
	   || [[ -z ${_aws_ver} ]]; then
	print -u2 "usage: awsget <key> <ver>"
	print -u2 "       where"
	print -u2 "       <key> is application.zip ID"
	print -u2 "       <ver> is S3 versionId string"
    else
	aws s3api get-object --bucket cashnet-codedeploy --key ${_aws_key} --version-id ${_aws_ver} ./${_aws_key}
    fi
}

function awslist
{
    typeset -a _aws_list=( $@ )
    typeset -i _aws_idx=0
    
    if (( ${#_aws_list[@]} == 0 )) || [[ ${_aws_list[*]} =~ help ]]; then
	print -u2 "usage: awslist <ApplicationName> <...>"
    else
	for (( _aws_idx = 0 ; _aws_idx < ${#_aws_list[@]} ; ++_aws_idx )); do
	    aws deploy list-application-revisions --application-name ${_aws_list[$_aws_idx]} --sort-by registerTime --sort-order descending --max-items 1
	done
    fi
}

function wb
{
    typeset _wb_dir=${1:-.}

    if [[ -d ${_wb_dir} ]]; then
	( cd ${_wb_dir}; git branch -v )
    else
	print -u2 "wb error: no such directory ${_wb_dir}"
    fi
}

function md5ign
{
    typeset _md5ign_file _md5ign_sign
    
    for _md5ign_file in ${@}; do
	_md5ign_sign=$(egrep -v '#.*' ${_md5ign_file} | LC_ALL=C sort -bdf | tr -d '[:space:]' | ${MD5})
	printf "%s %s\n" "${_md5ign_sign}" "${_md5ign_file}"
    done
}

function md5dir
{
    typeset _md5_dirname
    typeset -i _md5_rcsv
    
    case ${1} in
	-r) (( _md5_rcsv = 1 )); _md5_dirname=${2:-.} ;;
	*) _md5_dirname=${1} ;;
    esac

    if (( _md5_rcsv == 1 )); then
	find ${_md5_dirname} -type f -exec ${MD5} {} \;
    else
	if [[ -d ${_md5_dirname} ]]; then
	    tar -cf - ${_md5_dirname} | ${MD5}
	else
	    print -u2 "md5dir error: ${_md5_dirname} does not exist or is not a directory"
	fi
    fi
}

function man2pdf
{
    typeset -a _m2p_mans=( $@ )
    typeset _m2p_manp

    if (( ${#_m2p_mans[@]} > 0 )); then
	for _m2p_manp in ${_m2p_mans[@]}; do
	    man -t ${_m2p_manp} | ps2pdf - ${_m2p_manp}.pdf
	done
    else
	print "specify one or more manpages for output to PDF"
    fi
}

function enumerate
{
    typeset -i _en_linenum
    typeset _en_line
    typeset _en_readfile

    for _en_readfile in $@; do
	printf "::::::::\nEnumerating %s\n::::::::\n" ${_en_readfile}
	_en_linenum=0
	OLDIFS="$IFS"
	IFS='\'

	while read -r _en_line; do
	    (( _en_linenum++ ))
	    printf "%4d: %s\n" ${_en_linenum} "${_en_line}"
	done < ${_en_readfile} | less
	
	IFS="$OLDIFS"
    done
}

function where {
    typeset _where_string=${1}
    typeset -a _where_lines

    if [[ -z $2 ]]; then
	print "usage: where <string> <file(s)>"
    else
	printf "Searching for occurrences of %s...\n" ${_where_string}
	for filename in ${@:2}; do
	    if [[ -r ${filename} ]]; then
		_where_lines=( $(grep -n ${_where_string} ${filename} | cut -d: -f1) )
		
		printf "%s: %d lines; %s\n" ${filename} $(wc -l < ${filename}) "${_where_lines[*]}"
	    else
		printf "error: unable to read file: %s\n" ${filename}
	    fi
	done
    fi
}

function xdate {
    typeset _x_datestamp _x_datestring _x_datearg;

    if (( ${#} > 0 )); then
	for _x_datearg in ${@}; do
	    if [[ ${_x_datearg} =~ [0-9,a-f,A-F] ]]; then
		if [[ ${_x_datearg} =~ 0x ]]; then
		    _x_datestamp=$(printf "%d" ${_x_datearg})
		else
		    _x_datestamp=$(printf "%d" 0x${_x_datearg})
		fi
		_x_datestring=$(printf '%(%FT%T)T' '#'${_x_datestamp})
	    else
		_x_datestring=$(printf "%X" ${1})
	    fi
	done
    else
	_x_datestring=$(printf "%X" $(printf '%(%s)T' now))
    fi

    print ${_x_datestring}
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

case "${TERM}" in
    xterm*|vt100|screen|eterm-color)
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
	fi
	;;
esac

typeset hn="@${HOSTNAME}";

strata() {
    if [[ -z ${hosttype} ]]; then
	case ${HOSTNAME} in
	    *WALTER*|*DAVIES*|BLOCH|MACNOOBL*) hosttype="Lo";;
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

is_gitrepo() {
    typeset _is_grdir=${PWD}
    
    while [[ ${_is_grdir} != "" ]]; do
	[[ -d ${_is_grdir}/.git ]] && exit 0
	_is_grdir=${_is_grdir%/*}
    done

    exit 1
}

typeset -a VCSINFO=( )

cd() {
    typeset _cd_gs _cd_cwd _vcc _vccpref _vccpost
    typeset -i _cd_gi
    
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
    elif $(is_gitrepo); then
	_vcc=$(git config remote.origin.url)
	_vccpref=${_vcc#http*\/\/}
	_vccpref=${_vcc#git@}
	_vccpost=${_vcc##*/}
	VCSINFO=( ${_vccpref%%/*} ${_vccpost%.git} )
	
	if (( ${#VCSINFO[@]} < 2 )); then
	    CURRDIR="$(printf "%sGit %s%s%s" "${COL_BLUE}" "${COL_YELLOW}" "${PWD##*/}" "${COL_NORM}")"
	else
	    BRANCH=$(git symbolic-ref HEAD)
	    BRANCH=${BRANCH:##*/}
	    _cd_gs="$(git status 2>&1)"
	    _cd_cwd="$(print ${PWD#$HOME/code} | tr -d "[:alnum:]_.-")${PWD##*/}"
	    _cd_gi=$(egrep -c -v '^#' $(git rev-parse --show-toplevel)/.git/info/exclude)
	    
	    if (( _cd_gi > 0 )); then
		_cd_cwd="!!${_cd_cwd}"
	    fi
	    
	    if [[ "${_cd_gs}" =~ "unmerged paths" ]]; then
		BRANCH+='|MERGING'
		SLINE="${COL_GREEN}${_cd_cwd}${COL_NORM}"
	    elif [[ "${_cd_gs}" =~ "modified" ]] || [[ "${_cd_gs}" =~ "Changes to be committed" ]]; then
		SLINE="${COL_RED}${COL_BOLD}${_cd_cwd}${COL_UNBOLD}${COL_NORM}"
	    elif [[ "${_cd_gs}" =~ "Your branch is ahead" ]]; then
		SLINE="${COL_YELLOW}${COL_BOLD}${_cd_cwd}${COL_UNBOLD}${COL_NORM}"
	    elif [[ "${_cd_gs}" =~ "Untracked files" ]]; then
		SLINE="${COL_UBAR}${_cd_cwd}${COL_UNUBAR}${COL_NORM}"
	    else
		SLINE="${COL_WHITE}${_cd_cwd}${COL_NORM}"
	    fi
	    
	    CURRDIR="$(printf "%sGit %s %s%s:%s \"%s\"" "${COL_BLUE}" ${VCSINFO[0]} "${COL_YELLOW}" ${VCSINFO[1]} "${SLINE}" "${BRANCH}")"
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
}

getdirstat() {
    cd .
    print ${CURRDIR}
}

termtitle() {
    printf "\033]0;${TERM_TITLE}\007"
}

PS1='$(termtitle)${COL_NORM}[ ${INFOLINE} $(xdate) $(getdirstat) ]
${COL_NORM}$ ${COL_WHITE}'

[ -r /etc/environment ] && . /etc/environment
[ -r ~/.localenv ] && . ~/.localenv

