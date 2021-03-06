if [ $TERM = xterm -o $TERM = rxvt-unicode-256color ]
then
  export TERM=xterm-256color
elif [ $TERM = screen ]
then
  export TERM=screen-256color
elif [ $TERM = linux ]
then
  ~/.dotfiles/solarized-linux-console.sh
fi

alias ta='tmux attach'
alias grep='grep --color=auto'
alias ls='ls --color=auto'
alias la='ls -A'
alias ll='la -lh'
alias git="noglob git" # zsh likes to swallow ^ characters
alias gca="git commit -a --amend -C HEAD"
alias ipython="ipython --no-confirm-exit"
alias ipython3="ipython3 --no-confirm-exit"
alias open="xdg-open"

# disable ctrl-s/crtl-q flow control
stty stop undef

eval `dircolors ~/.dotfiles/dir_colors`
export EDITOR=vim
export PATH=$PATH:~/bin

# add emacs keybindings on top of vi mode
bindkey -e
binds=`bindkey -L`
bindkey -v
for bind in ${(@f)binds}; do eval $bind; done
unset binds
# and drop into vim with v
autoload -U edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

# get shared history all working properly
HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=$HISTSIZE
setopt extended_history
setopt hist_ignore_dups
setopt hist_ignore_space
setopt inc_append_history
setopt share_history

autoload -U compinit && compinit
setopt complete_in_word
zstyle ':completion:*' menu select
# LS_COLORS set by dircolors above
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
# case-insensitive (lower only), partial-word, and substring completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

setopt notify # immediate job notifications
setopt extendedglob # crazy file globbing
setopt autocd # cd without 'cd'
setopt autopushd # cd works like pushd
autoload -U zmv

# Load settings specific to this machine.
local_zshrc=~/.zshrc.local
if [ -e "$local_zshrc" ]
then
  source "$local_zshrc"
fi

setopt prompt_subst
export PROMPT='%(?..%F{red}%? )%F{cyan}%m %F{blue}%~ %F{yellow}$(__git_prompt)%f'

__git_prompt() {
  if git rev-parse --git-dir > /dev/null 2>&1; then
    echo "$(__git_branch)$(__git_mode) "
  fi
}

__git_mode() {
  g=`git rev-parse --git-dir 2> /dev/null`
  if [ $? != 0 ]; then
    return
  fi

  mode=""
  if [ -f "$g/rebase-merge/interactive" ]; then
    mode="|REBASE-i"
  elif [ -d "$g/rebase-merge" ]; then
    mode="|REBASE-m"
  elif [ -d "$g/rebase-apply" ]; then
    if [ -f "$g/rebase-apply/rebasing" ]; then
      mode="|REBASE"
    elif [ -f "$g/rebase-apply/applying" ]; then
      mode="|AM"
    else
      mode="|AM/REBASE"
    fi
  elif [ -f "$g/MERGE_HEAD" ]; then
    mode="|MERGING"
  elif [ -f "$g/CHERRY_PICK_HEAD" ]; then
    mode="|CHERRY-PICKING"
  elif [ -f "$g/BISECT_LOG" ]; then
    mode="|BISECTING"
  fi

  echo $mode
}

__git_branch() {
  name=`git rev-parse --abbrev-ref HEAD 2> /dev/null`
  if [ $? != 0 ]; then
    return
  fi

  if [ $name = HEAD ]; then # if no branch, get the hash
    name=`git rev-parse --short HEAD`
  fi

  echo $name
}
