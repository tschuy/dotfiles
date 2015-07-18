# If not running interactively, don't do anything
[ -z "$PS1" ] && return

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
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
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

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'


# Set PS1
__git_ps1 ()
{
    local b="$(git symbolic-ref HEAD 2>/dev/null)";
    if [ -n "$b" ]; then
        printf "(%s)" "${b##refs/heads/}";
    fi
}
PS1='\[\033[1;32m\]\u@\h:\[\033[1;34m\](\W)\[\033[00m\]$(__git_ps1) \[\033[0;34m\]→ \[\033[00m\]'


# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ls='ls -ltr --color'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias git-graph='git log --stat --graph'

# keys
keychain --quiet ~/.ssh/fir
keychain --quiet ~/.ssh/id_rsa

# openstack config
if [ -f $HOME/.openstackrc ]; then
    source $HOME/.openstackrc
fi

export EDITOR=vim


function p() {
    if [ "$1" == "start" ]; then
        cd /home/tschuy/projects/
        git clone $2
    elif [ -a ~/.p/$1 ]; then
        source ~/.p/$1
    else
        cd ~/projects/$1
    fi
}

function c() {
    if [ "$1" == "" ]; then
        cd ~/git/chef-repo/
    else
        cd ~/git/chef-repo/osuosl-cookbooks/$1
    fi
}

function fixbrowsers() {
    rm ~/.config/google-chrome/SingletonLock
    rm ~/.mozilla/firefox/*.default/.parentlock
}

if [ "$DISPLAY" ]
then
    feh --bg-fill ~/Desktop/bg5.jpg
fi


export PYTHONSTARTUP=~/.pythonrc
export WWW_HOME="http://duckduckgo.com"


# Set PATH
export PATH=$HOME/.bin:$PATH
export PATH=$HOME/.chefdk/gem/ruby/2.1.0/bin:$PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/projects/ascr:$PATH
export PATH=$HOME/projects/fenestra/npm/stuff/bin:$PATH
export PATH=$PATH:$HOME/.rvm/bin
export PATH=$HOME/Downloads/android-studio/bin:$PATH
export PATH=/usr/local/heroku/bin:$PATH
