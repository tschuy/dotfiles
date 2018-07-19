# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=
HISTFILESIZE=

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

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

# add kubeconfig and namespace to PS1
__kubernetes_ps1 ()
{
    if [ -n "$KUBECONFIG" ]; then
        bn=`basename $KUBECONFIG`
	printf "(%s" "$bn"
	if [ -n "$NS" ]; then
            printf ":%s" "$NS"
        fi
	printf ") "
    fi
}

# add last two parent directories
# ex: ~/projects/pname -> username/projects
__pwd_ps1 ()
{
    if [ "$HOME" != `pwd` ]; then   
        pwd | rev | awk -F / '{print "",$2,$3}' | rev | sed s_\ _/_g
    fi
}

# get current git branch
__git_ps1 ()
{
    local b="$(git symbolic-ref HEAD 2>/dev/null)";
    if [ -n "$b" ]; then
        printf " (%s)" "${b##refs/heads/}";
    fi
}

# commands to run every line
__do_every_line ()
{
    kcfg=$(basename "$KUBECONFIG")
    [ -z "$kcfg" ] && kcfg='$kcfg |' 
    printf '\001\e]2;%s\a\002' "$kcfg $(basename `pwd`) $(__git_ps1)"
}

# yikes, what a horribly ugly PS1 string
PS1='\[\033[1;36m\]$(__kubernetes_ps1)\[\033[1;32m\]\[\033[1;34m\]$(__pwd_ps1)\[\033[1;32m\]\W\[\033[00m\]$(__git_ps1) \[\033[0;34m\]→ \[\033[00m\]$(__do_every_line)'

### I never use any of these ls or grep aliases
# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ls='ls -ltrh --color=auto'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias git-graph='git log --stat --graph'

export PYTHONSTARTUP=~/.pythonrc
export WWW_HOME="http://duckduckgo.com"
export EDITOR=vim

# Set PATH
export PATH=$HOME/.bin:$PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/.local/go/bin:$PATH
export PATH=$PATH:$HOME/.screenlayout # screen layouts for i3 for work

# GOPATH, because go is special
export GOROOT=$HOME/.local/go
export GOPATH=$HOME/golang
export PATH=$PATH:$GOPATH/bin

# used in some scripts
export INFRA_REPO="/home/tschuy/projects/infra"
export SECURE_REPO="/home/tschuy/projects/secure"

### various handy aliases
# that printf is pastefix, since weechat sets bracketed paste mode on start
alias irc="ssh -t tschuye@flip3.engr.oregonstate.edu /nfs/stak/students/t/tschuye/.bin/irc && printf \"\e[?2004l\""
alias web="python -m SimpleHTTPServer"

alias lock="i3lock -d -c 000000"

alias vi="vim"
alias gpgagentreset="pkill -HUP gpg-agent" # -.-
# for when something enables bracketed paste mode -.-
alias pastefix="printf \"\e[?2004l\""

alias sl='ls | sort -r'
alias open='xdg-open'

alias passwd_please="pwgen -1s 40"

### various Kubernetes/Tectonic nice-to-haves

# short alias that uses chosen namespace
k () {
    ~/.local/bin/kubectl --namespace=${NS:-default} $@
}

# only execute the command if the current cluster is a minikube cluster
minictl () {
	if grep -Fq "minikube" ~/.kube/config
	then
		KUBECONFIG=~/.kube/config kubectl $@
	else
		echo "your ~/.kube/config isn't minikube anymore; aborting"
	fi
}

# open the tectonic console associated with current cluster
cons () {
	console_url=$(k get ingress -n tectonic-system -o=custom-columns=:.spec.rules[0].host | grep -v prometheus | grep -v public | sed -n 2p)
	if [[ -z "${console_url}" ]]; then
		echo "couldn't find console url"
	else
		echo "opening $console_url"
		google-chrome $console_url &>/dev/null
	fi
}

alias clearkube='export KUBECONFIG= && export NS= '

# choose cluster from list, or specify fuzzy name (ex: `c 1472`)
# kubeconfig is in this repo under bin/
alias c="source kubeconfig"

# choose namespace from list with fzf
ns () {
    if [ -z "$1" ]; then
        export NS=`~/.local/bin/kubectl get ns -o=custom-columns=:.metadata.name | fzf --select-1`
    else
        export NS=`~/.local/bin/kubectl get ns -o=custom-columns=:.metadata.name | grep $1 | fzf --select-1`
    fi
}

### startup setups

# set up integrations
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
source /etc/profile.d/bash_completion.sh
export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"

# start gpg-agent if it's not already running
gpg-connect-agent /bye

# make pretty "motd" banner
figlet -d ~/.config -f isometric1.flf CoreOS -w 200 | lolcat
echo ""

# http://rabexc.org/posts/pitfalls-of-ssh-agents
ssh-add -l &>/dev/null
if [ "$?" == 2 ]; then
  test -r ~/.ssh-agent && \
    eval "$(<~/.ssh-agent)" >/dev/null

  ssh-add -l &>/dev/null
  if [ "$?" == 2 ]; then
    (umask 066; ssh-agent > ~/.ssh-agent)
    eval "$(<~/.ssh-agent)" >/dev/null
    ssh-add
  fi
fi


# add primary ssh key to ssh-agent 
if  ssh-add -l | \
    grep -q "$(ssh-keygen -lf ~/.ssh/id_rsa | awk '{print $2}')"; \
	then true;
  else ssh-add ~/.ssh/id_rsa && ssh-add ~/.ssh/prod1472 && ssh-add ~/.ssh/prod-v1507.key;

fi

# set title to reminder
echo -e "\e]2;ctrl+shift+e | ctrl+shift-o | alt+arrow\a"

alias vpn="~/.rhtoken/vpn.sh"

alias path="echo $PATH | sed 's/:/\n/g'"
