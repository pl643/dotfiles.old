# inoremap WW <Esc>:w<CR>:silent !tmux select-pane -t :.+<cr>
# nnoremap WW <Esc>:w<CR>:silent !tmux select-pane -t :.+<cr>
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
LPAGER="less -r"
PAGER=$LPAGER
PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '
SUBSHELLCMDS="/tmp/.$USER.subshellcmds"
VISUAL='nvim'
VPAGER="nvim -c 'nnoremap q :q!<cr>'"
PROMPT_COMMAND="test -f $SUBSHELLCMDS && source $SUBSHELLCMDS && rm $SUBSHELLCMDS"
export VISUAL PAGER

alias -- +='set +x'
alias -- -='set -x'
alias WW='tmux select-pane -t :.+'
alias .b='echo source ~/dotfiles/bashrc; source ~/dotfiles/bashrc'
alias ag='clear; alias | grep git'
alias al='clear; alias'
alias b='echo \> pushd \- \; "$AUTOLS"; builtin pushd - > /dev/null; $AUTOLS'
alias bcd='builtin cd'
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
alias gd='clear; git diff --color=always | $LPAGER'
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
alias pl='export PAGER=less'
alias pv='export PAGER=$VPAGER'
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
	builtin pushd "$@" > /dev/null
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
		DIRS="$(sed "s/${HOME//\//\\\/}/~/" $DIRS_HISTORY | sort | uniq)"
	else
		DIRS=$(dirs -p | sort | uniq)
	fi
	if [ -z "$1" ]; then
		clear
		i=1
		#for dir in "$DIRS"; do
		#	if [ ${#dir} -ne 1 ]; then  # skip / and ~
		#		printf "%3d %s\n" $i "$dir"
		#		alias $i="$dir"
		#		let "i++"
		#	fi
		#donellllh
		while IFS= read -r dir; do
			if [ ${#dir} -ne 1 ]; then  # skip / and ~
				printf "%3d %s\n" $i "$dir"
				#eval dir=(echo $dir | sed 's/~/$HOME')
				#echo eval alias $i="\"$dir\"'
				fdir=$(echo "$dir" | sed 's/ /\\ /g')
				eval alias $i='"$fdir"'
				let "i++"
			fi
		done <<< "$DIRS"
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
				set -x
				printf "%3d %s\n" $i $dir
				echo eval alias $i='\"$dir\"'
				eval alias $i='\"$dir\"'
				let "i++"
				#set -x
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
function gac {  # commit without "s
	echo \> git commit -am \"$@\"
	eval git commit -am \"$@\"
}
function gdh {  # git diff head, defaults to 1
	if [ -z $@ ]; then
		head=1
	else
		head=$@
	fi
	clear
	echo \> git diff HEAD@{"$head"}
	git diff HEAD@{"$head"}
}
# 
function command_not_found_handle {
	files=$(/bin/ls -1 |grep ^$1 2> /dev/null)
	match_count=$(echo "$files" | wc -l )
	echo DB: "$files" mc: "$match_count" \$1: $1 \$files $files
	
	if [ $match_count -eq 1 ] && [ "$files" != "" ]; then
		echo DB: line 164 -eq 1 matchcount
		if [ -f "$files" ]; then
			if file "$files" | grep -q text; then
				eval "$PAGER" \"$files\";
				echo eval "$PAGER" "$files";
				return
			else
				echo $files is a binary file
				return
			fi
		fi
		if [ -d $files ]; then
			echo DB: line 172
			echo builtin cd \"\$files\"            >   $SUBSHELLCMDS
			eval echo DB: builtin cd \"\$files\" 
			eval echo echo \> cd \"$files\" \; $AUTOLS  >>  $SUBSHELLCMDS
			echo "$AUTOLS"                         >>  $SUBSHELLCMDS
			return
		fi
	fi
	if [ $match_count -gt 1 ]; then
		echo DB: line 184 -gt 1 matchcount
		i=1
		for file in $files; do
			printf "%3d %s\n" $i $file
			echo alias $i=$file >> $SUBSHELLCMDS
			let "i++"
		done
		return
	fi
	if [ -f "$1" ]; then
		"$PAGER" "$1"
		return
	else
		echo DB: line 198
		#set -x
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
			#echo set -x > $SUBSHELLCMDS
			eval dir=$(echo $MATCH | sed 's/~/$HOME'/)
			echo DB: 216 dir: $dir MATCH $MATCH 
			echo builtin cd \"$dir\"                 >>  $SUBSHELLCMDS
			echo "echo \> cd \"$MATCH\" \; $AUTOLS"  >>  $SUBSHELLCMDS
			echo "$AUTOLS"                           >>  $SUBSHELLCMDS
			#echo set +x                              >>  $SUBSHELLCMDS
			#cat $SUBSHELLCMDS
			return
		fi
		if [ $MATCHCOUNT -gt 1 ]; then
			i=1
			DIRS=$(echo "$DIRS" | grep "$1")
			for dir in $DIRS; do
				printf "%3d %s\n" $i $dir
				fdir=$(echo "$dir" | sed 's/ /\\ /g')
				echo alias $i='"$fdir"' >> $SUBSHELLCMDS
				let "i++"
			done
			return
		fi
		DB: line 235
		#set +x
	fi
 	[ ! -z $DB ] && echo DB: command_not_found_handle \$1: $1
	if [ -x /usr/lib/command-not-found ]; then
		/usr/lib/command-not-found -- "$1";
		return $?;
	else
		echo command_not_found_handle\(\) $1: not found
		return 1
	fi
}
function H {
	history="$(sort $HISTFILE | uniq)"
	match=$(echo "$history" | grep "$1")
	echo "$match"
	#i=1
	#for m in "$match"; do
	#	printf "%3d %s\n" $i $m
	#	let "i++"
	#done
}
