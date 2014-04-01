# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi



#export SVN_EDITOR="gvim --nofork"
# MacOSX Lion
#export ARCHFLAGS="-arch x86_64"
#export MACOSX_DEPLOYMENT_TARGET="10.7"
export SVN_EDITOR="subl -w"
export LANG=en_US.UTF-8
export LC_MESSAGES=en_US.UTF-8
export COPYFILE_DISABLE=1 #Remove resource forks from tar files
export PYTHONSTARTUP=~/.pythonrc.py
#export PYTHONPATH="~/Desenvolvimento/google_appengine:$PYTHONPATH"
#export PATH="~/Simples/Produtos/buildout.development/bin:~/Desenvolvimento/google_appengine:/Developer/usr/bin/:/opt/local/bin:/opt/local/sbin:~/bin/:~/bin/scripts:$PATH"
shopt -s histappend 
export PROMPT_COMMAND='history -a' 
# Don't put duplicate lines in the history 
#export HISTCONTROL=ignoreboth 
#export HISTSIZE=50000

# GIT Magic
c_cyan=`tput setaf 6`
c_red=`tput setaf 1`
c_green=`tput setaf 2`
c_sgr0=`tput sgr0`
 
#Get git information
parse_git_branch () {
        git name-rev HEAD 2>/dev/null | sed 's#HEAD\ \(.*\)#(git::\1)#'
}

#Should we push?
parse_git_push () {
        git st 2>/dev/null|sed -ne "s/#\ Your\ branch\ is\ ahead\ of\ '.*' by \([0-9]*\)\ commits\{0,1\}./ +\1/p"
}

#Get svn information
##Get svn url
parse_svn_url() {
        svn info 2>/dev/null | sed -ne 's#^URL: ##p'
}

##Get svn repository root
parse_svn_repository_root() {
        svn info 2>/dev/null | sed -ne 's#^Repository Root: ##p'
}
##Get svn revision
parse_svn_current_revision() {
        svn info 2>/dev/null | sed -ne 's#^Revision: ##p'
}
##Parse everything and return the svn general info
parse_svn_branch_revision() {
    parse_svn_url | sed -e 's#^'"$(parse_svn_repository_root)"'##g' | awk -F / '{print $1 "/" $2 }' | awk '{print "(svn::_@" $1 ")" } ' | sed -e 's#_@#'"$(parse_svn_current_revision)"':#g'
}

branch_color ()
{
        if [ `parse_git_branch|grep -c 'git'` -gt 0 ]
        then
                color=""
                if git diff --quiet 2>/dev/null >&2 
                then
					if [ `git st -s --untracked-files=no 2>/dev/null|wc -l` -gt 0 ]
					then 
                        color="${c_cyan}"
					else
						color="${c_green}"
					fi
                else
                        color=${c_red}
                fi
        else
                if [ `parse_svn_branch_revision|grep -c 'svn'` -gt 0 ] 
                then	
						color=''
						##Parse st response
                        if [ `svn st -q|wc -l` -eq 0 ]
                        then
                                color="${c_green}"
                        else
                                color=${c_red}
                        fi
                else
                    return 0
                fi
        fi
        echo -ne $color
}

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# user@server, relative path, current time 
export PS1='\[\e[32m\][\u@\h] \[\e[33m\w\] [\[$(branch_color)\]$(parse_git_branch)$(parse_git_push)$(parse_svn_branch_revision)\[${c_sgr0}\]\e[33m] \n\[\e[1;34m\][\t]\[\e[0m\] \$ '


