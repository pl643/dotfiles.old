AUTOLS='ls -F'
DIRS_HISTORY="/tmp/.$USER.dirhistory"
EDITOR='nvim'
GIT_PS1_DESCRIBE_STYLE='contains'
GIT_PS1_SHOWCOLORHINTS='y'
GIT_PS1_SHOWDIRTYSTATE='y'
GIT_PS1_SHOWSTASHSTATE='y'
GIT_PS1_SHOWUNTRACKEDFILES='y'
GIT_PS1_SHOWUPSTREAM='auto'
LESS='-r'
PAGER='less'
PROMPT_COMMAND="test -f $SUBSHELLCMDS && source $SUBSHELLCMDS && rm $SUBSHELLCMDS"
PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '
SUBSHELLCMDS='/tmp/.subshellcmds'
VISUAL='nvim'

alias -- +='set +x'
alias -- -='set -x'
alias .b='echo source ~/dotfiles/bashrc; source ~/dotfiles/bashrc'
alias ag='clear; alias | grep git'
alias al='clear; alias'
alias b='echo \> pushd \- \; "$AUTOLS"; builtin pushd - > /dev/null; $AUTOLS'
alias d2f="echo dirs -p \>\>$DIRS_HISTORY; dirs -p >> $DIRS_HISTORY"
alias g='git'
alias ga='git add'
alias gb='git branch'
alias gc='git commit'
alias gcm='git commit -m'
alias gco='echo git checkout ; git checkout'
alias gcob='echo git checkout -b; git checkout -b'
alias gd1='clear; git diff HEAD~1'
alias gd2='clear; git diff HEAD~2'
alias gd='clear; git diff'
alias gg='clear; git log --pretty="%C(Yellow)%h  (%C(Green)%cr%C(reset))%x09 %C(Cyan)%an: %C(reset)%s" -7'
alias ggd='clear; git log --pretty="%C(Yellow)%h %C(reset)%ad (%C(Green)%cr%C(reset))%x09 %C(Cyan)%an: %C(reset)%s" -7'
alias ggg='clear; git log --graph --oneline --decorate'
alias gh='git push'
alias git='git'
alias gl='git pull'
alias gs='git status'
alias h='~'
alias hi='history'
alias l='ls -lF '
alias la='clear; ls -laF '
alias le='less'
alias ls='ls --color=always'
alias s='ls -F '
alias sa='ls -aF '
alias sd='echo redo: sudo $(history -p \!\!); sudo $(history -p \!\!)'
alias u='..'
bind 'TAB':menu-complete
bind 'set show-mode-in-prompt on'
bind -m vi-insert 'Control-k: clear-screen'
bind -m vi-insert 'Control-l: clear-screen'
bind -m vi-insert 'Control-u: clear-screen'
set -o vi
shopt -s autocd cdable_vars checkwinsize
touch $DIRS_HISTORY
 
function cd {
	[ ! -z $DB ] && echo DB:  cd\(\) \$1: $1
	#if [ -d $1 ] && pushd 
	builtin pushd "$2" > /dev/null
	if [ -f $DIRS_HISTORY ]; then
		pwd >> $DIRS_HISTORY
	fi
	echo \> "$AUTOLS"
	LSOUT=$($AUTOLS)
	if [ ${#LSOUT} -gt 0 ]; then
		ls -F
	else
		echo "  <no files>"
	fi
}
function d {
	[ ! -z $DB ] && echo DB: d \$@: $@ \$1 $1
	if [ -f $DIRS_HISTORY ]; then
		DIRS=$(sed "s/${HOME//\//\\\/}/~/" $DIRS_HISTORY | sort | uniq)
	else
		DIRS=$(dirs -p | sort | uniq)
	fi
	if [ -z "$1" ]; then
		clear
		i=1
		for dir in $DIRS; do
			if [ ${#dir} -ne 1 ]; then  # skip / and ~
				printf "%3d %s\n" $i $dir
				alias $i=$dir
				let "i++"
			fi
		done
		echo
	else
		MATCH=$(echo "$DIRS" | grep "$1")
		if [ "$MATCH" = "" ]; then 
			MATCHCOUNT=0
		else
			MATCHCOUNT=$(echo "$MATCH" | wc -l)
		fi
		if [ $MATCHCOUNT -eq 0 ]; then
			echo NOTE: no match found for $1 in $DIRS_HISTORY	
		fi
		if [ $MATCHCOUNT -eq 1 ]; then
			echo "cd $MATCH" > /tmp/.cd
			echo \> pushd "$MATCH" \; ls -F
			eval pushd $MATCH > /dev/null
			eval $AUTOLS
			return
		fi
		if [ $MATCHCOUNT -gt 1 ]; then
			i=1
			DIRS=$(echo "$DIRS" | grep "$1")
			for dir in $DIRS; do
				printf "%3d %s\n" $i $dir
				alias $i=$dir
				let "i++"
			done
			return
		fi
	fi
	[ ! -z $DB ] && echo DB: d \$@: $@
}
function gma {
	echo git commit --amend -m \"$@\"
	eval git commit --amend -m \"$@\"
}
function gac {
	echo git add . \; git commit -m \"$@\"
	git add .
	eval git commit -m \"$@\"
}
function gdh {
	if [ -z $@ ]; then
		head=1
	else
		head=$@
	fi
	clear
	echo \> git diff HEAD@{"$head"}
	git diff HEAD@{"$head"}
}
function command_not_found_handle {
	if [ -f "$1" ]; then
		"$PAGER" "$1"
		return
	else
		if [ -f $DIRS_HISTORY ]; then
			DIRS=$(sed "s/${HOME//\//\\\/}/~/" $DIRS_HISTORY | sort | uniq)
		else
			DIRS=$(dirs -p | sort | uniq)
		fi
		MATCH=$(echo "$DIRS" | grep "$1")
		if [ "$MATCH" = "" ]; then 
			MATCHCOUNT=0
		else
			MATCHCOUNT=$(echo "$MATCH" | wc -l)
		fi
		#if [ $MATCHCOUNT -eq 0 ]; then
		#	echo NOTE: no match found for $1 in $DIRS_HISTORY	
		#fi
		if [ $MATCHCOUNT -eq 1 ]; then
			echo builtin cd "$MATCH"  >  $SUBSHELLCMDS
			echo "echo \> $AUTOLS"   >>  $SUBSHELLCMDS
			echo "$AUTOLS"           >>  $SUBSHELLCMDS
			return
		fi
		if [ $MATCHCOUNT -gt 1 ]; then
			i=1
			DIRS=$(echo "$DIRS" | grep "$1")
			for dir in $DIRS; do
				printf "%3d %s\n" $i $dir
				echo alias $i=$dir >> $SUBSHELLCMDS
				let "i++"
			done
			return
		fi
	fi
	[ ! -z $DB ] && echo DB: command_not_found_handle \$1: $1
	echo command_not_found_handle\(\) $1: not found
}
