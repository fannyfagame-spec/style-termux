[[ $- != *i* ]] && return

shopt -s checkwinsize
shopt -s cmdhist
shopt -s globstar
shopt -s histappend
shopt -s histverify

## Configure bash history.
if [ "$(id -u)" = "0" ]; then
	export HISTFILE="$HOME/.bash_root_history"
else
	export HISTFILE="$HOME/.bash_history"
fi
export HISTSIZE=4096
export HISTFILESIZE=16384
export HISTCONTROL="ignoreboth"

## cursor
printf '\e[4 q'

## loader
. ~/.draw;

## Prompt.
PROMPT_DIRTRIM=2
if [ "$(id -u)" = "0" ]; then
	PS1="\\[\\e[0;31m\\]\\w\\[\\e[0m\\] \\[\\e[0;97m\\]\\$\\[\\e[0m\\] "
else
# --- PS1: ファニーファ Cyber Prompt (dynamic time/date + status) ---
# paste ke ~/.bashrc

# warna (ANSI dengan bracket \[ \] agar Bash aware)
FG_BLUE='\[\e[38;5;27m\]'
FG_CYAN='\[\e[38;5;51m\]'
FG_LBLUE='\[\e[38;5;118m\]'
FG_MAG='\[\e[38;5;171m\]'
FG_GREEN='\[\e[38;5;82m\]'
FG_RED='\[\e[38;5;196m\]'
FG_YEL='\[\e[38;5;220m\]'
FG_WHITE='\[\e[1;37m\]'
RESET='\[\e[0m\]'


  # time & date (dynamic
# End of prompt config

# Tambahkan ke ~/.bashrc
export NAME="FANNYFA"

# Palet warna soft (biru ke ungu pastel, nyaman dilihat)
C1="\[\033[1;38;5;60m\]"     # biru keabu-an (header)
C2="\[\033[1;38;5;111m\]"    # biru muda lembut
C3="\[\033[1;38;5;140m\]"    # ungu pastel lembut
C4="\[\033[1;38;5;189m\]"    # biru keunguan muda
NC="\[\033[0m\]"              # reset

# Prompt elegan dua gradasi
PS1="\n\
${C1}╭─[${C2}${NAME}${C3}@${C4}ファニーファ-開発者${C1}]\n\
${C1}│ ${C2}📂 ${C3}\w\n\
${C1}│ ${C2}🕒 ${C4}\t   ${C2}📅 ${C3}\d\n\
${C1}╰─${C3}『${C2}❯${C4}❯${C3}❯${C3}』${NC} "

fi
PS2='> '
PS3='> '
PS4='+ '
## Terminal title.
case "$TERM" in
	xterm*|rxvt*)
		if [ "$(id -u)" = "0" ]; then
			PS1="\\[\\e]0;termux (root): \\w\\a\\]$PS1"
		else
			PS1="\\[\\e]0;termux: \\w\\a\\]$PS1"
		fi
		;;
	*)
		;;
esac

## Colorful output & useful aliases for 'ls' and 'grep'.
if [ -x "$PREFIX/bin/dircolors" ] && [ -n "$LOCAL_PREFIX" ]; then
	if [ -f "$LOCAL_PREFIX/etc/dircolors.conf" ]; then
		eval "$(dircolors -b "$LOCAL_PREFIX/etc/dircolors.conf")"
	fi
fi

## Colored output.
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto -h'

## Replace 'cat' with 'bat' (if available).
if [ -n "$(command -v bat)" ]; then
	alias cat='bat --color=never --decorations=never --paging=never'
fi

## Replace 'ls' with 'exa' (if available) + some aliases.
if [ -n "$(command -v exa)" ]; then
	alias l='exa'
	alias ls='exa'
	alias l.='exa -d .*'
	alias la='exa -a'
	alias ll='exa -Fhl'
	alias ll.='exa -Fhl -d .*'
else
	alias l='ls --color=auto'
	alias ls='ls --color=auto'
	alias l.='ls --color=auto -d .*'
	alias la='ls --color=auto -a'
	alias ll='ls --color=auto -Fhl'
	alias ll.='ls --color=auto -Fhl -d .*'
fi

## Safety.
alias cp='cp -i'
alias ln='ln -i'
alias mv='mv -i'
alias rm='rm -i'
## PROJEK
alias hapus='clear'
alias fannyfa='cd /storage/emulated/0/SCRIPT/FannyFa&&python run.py'
alias mux='cd /sdcard/script/projek/fa-mux&&bash t-header.sh'
alias spython='cd /sdcard/SCRIPT/"SCRIPT PYTHON"/'
alias gas='cd /sdcard/SCRIPT/gas&&ifconfig&&node index.js'
alias sbash='cd /sdcard/SCRIPT/"SCRIPT BASH"/'
alias shtml='cd /sdcard/SCRIPT/"SCRIPT HTML"/'
alias sbot='cd /sdcard/SCRIPT/"SCRIPT BOT"/'
alias sprojek='cd /sdcard/SCRIPT/PROJEK/'
alias sgithub='cd /sdcard/SCRIPT/GITHUB/'
alias sscript='cd /sdcard/SCRIPT/'
alias apk='cd /sdcard/SCRIPT/"base apk bug"&&npm start'
alias sdcard='cd /sdcard/'
alias tools='bash /sdcard/script/projek/fa-mux/.object/tools/tools.sh'
alias web="cd /sdcard/script/html/fannyfa&&npm start"
alias 4="bash /sdcard/script/projek/fa-mux/.object/tools/tools.sh"
alias 5="ifconfig"
## Proot env
alias nethunter='proot-distro login nethunter'
alias ubuntu='proot-distro login ubuntu'
alias void='proot-distro login void'