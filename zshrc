#!/bin/zsh
# vim: fdm=marker:

setopt extendedglob
autoload is-at-least

if is-at-least 4.3; then
  if [[ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  fi
fi

[ -f ~/.zshrc.before ] && source ~/.zshrc.before

# {{{ Helper functions
command-exist () { whence $1 > /dev/null; }

alias-if-exist () {
  if command-exist $1; then
    alias $2=$1
  fi
}
# }}}
# {{{ umask
# I want my primary group to write to my files
# Why wouldn't I?
umask 002
# }}}
# {{{ TERM
# Gnome Terminal does not allow us to set any other TERM than xterm
if [[ $COLORTERM == gnome-terminal ]]; then
  export TERM=xterm-256color
fi
# }}}
# {{{ ZLE and fzf
# Default:        *?_-.[]~=/&;!#$%^(){}<>
export WORDCHARS='*?[]~&;!#$%^(){}'

bindkey -v

# Load editor support
autoload edit-command-line
zle -N edit-command-line

if is-at-least 4.3; then
  if [[ -f ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh ]]; then
    source ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh
  fi
fi

# Outputs $1 when on insert mode and outputs $2 when on command mode.
# zle_mode_output "when insert" "when command"
function zle_mode_output {
  # Keymap could be empty sometimes; assume insert mode
  case $KEYMAP in
    ("vicmd") echo $2;;
    (*) echo $1
  esac
}

# Reset prompt on mode change
function zle-keymap-select {
  zle reset-prompt
}
zle -N zle-keymap-select

# ^LeftArrow, ^RightArrow
bindkey '[1;5C' forward-word
bindkey '[1;5D' backward-word

# New line
bindkey -M viins '^J' self-insert

# Vim-like bindings
# Stolen from https://github.com/sharat87/zsh-vim-mode/blob/master/zsh-vim-mode.plugin.zsh

# Fix more vim-like bindings (instead of vi)
# vi bindings do not kill beyond the start of Insert mode (e.g. enter insert
# and press backspace and nothing happens)
bindkey "^W" backward-kill-word    # vi-backward-kill-word
bindkey "^H" backward-delete-char  # vi-backward-delete-char
bindkey "^U" backward-kill-line    # vi-kill-line
bindkey "^?" backward-delete-char  # vi-backward-delete-char

# Home key variants
bindkey '\e[1~' vi-beginning-of-line
bindkey '\eOH' vi-beginning-of-line

# End key variants
bindkey '\e[4~' vi-end-of-line
bindkey '\eOF' vi-end-of-line

bindkey -M vicmd 'yy' vi-yank-whole-line
bindkey -M vicmd 'Y' vi-yank-eol

bindkey -M vicmd 'u' undo
bindkey -M vicmd '^r' redo

bindkey -M vicmd 'H' run-help
bindkey -M viins '^h' run-help

bindkey '^n' history-substring-search-up
bindkey '^p' history-substring-search-down

bindkey -M viins '^a' beginning-of-line
bindkey -M viins '^e' end-of-line

bindkey -M vicmd 'v' edit-command-line
bindkey -M viins '^rv' edit-command-line

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Use highlight to preview FZF files under CTRL+T
if command-exist highlight; then
  export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"
fi

# }}}
# {{{ ls (Colors, etc.)
eval $(dircolors -b)

# Files that I don't have to pay attention to
export LS_COLORS="$LS_COLORS:*.nfo=90:*.sfv=90:*.srt=90:*.sub=90"
export ZLS_COLORS="${LS_COLORS}"

alias ls='ls --color=auto'
alias l='ls -l'

# Replace l with k if git is installed
if is-at-least 4.3 && command-exist git; then
  if [[ -f ~/.zsh/k/k.sh ]]; then
    source ~/.zsh/k/k.sh
    alias l='k'
  fi
fi

# }}}
# {{{ EDITOR
try-editor () {
  if command-exist $1; then
    EDITOR="$@"
  fi
}

try-editor nano
try-editor vi
try-editor vim
try-editor nvim

export VISUAL=$EDITOR

unset try-editor
# }}}
# {{{ Completions
# Activate completion system and do some basic settings

zmodload zsh/complist

# Homebrew puts a lot of completions in here
if [ -d /usr/local/share/zsh/site-functions ]; then
  fpath=(/usr/local/share/zsh/site-functions $fpath)
fi

# Use my custom completions too
fpath=(~/.zsh/completion $fpath)

autoload -U compinit && compinit

# Find out what an alias stands for and complete like if it was the original command
# This gives me git completion for my git aliases, for example
setopt nocomplete_aliases

zstyle ':completion:*' cache-path ~/.zsh/completioncache

# Use verbose completions (usually adds descriptions / context to matches)
zstyle ':completion:*' verbose yes

# Approximate when no matches can be found – corrects small errors
zstyle ':completion:*' completer _complete _approximate

# Environments to assume when autocompleting sudo
# In case I didn't already have all the sbin dirs in PATH, I would add them here
zstyle ':complete:sudo:' environ HOME="/root"

#
# Pimpin' format
#

# List completion candidates in groups
zstyle ':completion:*' group-name ''
# Looks of group headings
zstyle ':completion:*:descriptions' format "%B%K{blue}%F{white}>> %d%b%f%k"
# "No match" warning
zstyle ':completion:*:warnings' format "%F{red}no match for: %f%d"

# Colors
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
# }}}
# {{{ Named Directories
# Make certain paths into named directories ("~name" instead of "/path/to/name")

# namedir name [path]
namedir () {
  local target
  if [[ $2 == "" ]]; then
    target=$(pwd)
  else
    target=$2
  fi

  hash -d $1=$target
}

# Give all projects a name
if [ -d ~/Projects ]; then
  for dir in ~/Projects/*(/N); do
    namedir "$(basename $dir)" "$dir"
  done
fi
# }}}
# {{{ Navigation
# Navigation tricks and shortcuts

setopt auto_pushd
setopt pushd_ignore_dups

alias tree='tree -AC -I ".svn|.git|node_modules|bower_components"'
alias t='tree -L 3 --filelimit 50'

# Sort files by size and show human readable
alias fusage='ls -Ssrh'

# Enhanced cd:
#   * cd <path>/<file> go to <path>
cd () {
  if (( $# != 1 )); then
    builtin cd "$@"
  else
    if [[ -f "$1" ]]; then
      builtin cd "$1:h"
    else
      builtin cd "$1"
    fi
  fi
}

# Display contents of current directory when changing directories
function chpwd { ls }
# }}}
# {{{ History
export HISTSIZE=500
export SAVEHIST=500
export HISTFILE=~/.zsh/history

if [ ! -e $HISTFILE ]; then
  touch $HISTFILE
fi

setopt append_history         # don't replace history when process exits
setopt hist_ignore_all_dups   # remove old dups when added again
setopt hist_verify            # verify ! expansions
# }}}
# {{{ Pager
# Pager settings (less, man, etc.)

# This makes man pages look cooler
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# LESS should accept ANSI colors and higlight search results
export LESS="-Rg"

# Use lesspipe if installed
if whence 'lesspipe.sh' > /dev/null; then
  eval `lesspipe.sh`
fi

if [[ -f "/usr/share/source-highlight/src-hilite-lesspipe.sh" ]]; then
  export LESSOPEN="| /usr/share/source-highlight/src-hilite-lesspipe.sh %s"
fi
# }}}
# {{{ Copy/Paste
if command-exist pbcopy; then
  alias copy=pbcopy
  alias paste=pbcopy
else
  alias copy='xsel --clipboard --input'
  alias paste='xsel --clipboard --output'

  # Hard to break some habits
  alias pbcopy=copy
  alias pbpaste=paste
fi

# cat foo.txt bar.txt CP
alias -g CP='| copy'
# }}}
# {{{ Command replacements / aliases for commands with non-standard names
# Colordiff
alias-if-exist colordiff diff

if command-exist ag; then
  # I should not use Ack anymore
  ack() {
    echo "Use Ag, dummy!"
    sleep 1
    ag $@
  }
fi
# }}}
# {{{ Git settings and shortcuts
git_log_format='%C(bold blue)%h%C(reset) %C(yellow)%G?%C(reset) - %C(bold green)%ar%C(reset) - %C(bold black)%an %C(auto)%d%C(reset) %C(magenta)%GS%n''  %s%n'

alias-if-exist hub git

alias checkout='git checkout'
alias master="git checkout master"

alias gadd='git add'
alias gco='git commit -v'
alias gpu='git push'
alias gb="git branch -v"
alias gba="git branch -va"
alias gbm="git branch -v --merged"

alias gm='git merge --no-ff'
alias gmo='git merge --no-ff @{upstream}'
alias gmm='git merge --no-ff master'

alias gro='git rebase @{upstream}'
alias grm='git rebase master'
alias gri='git rebase -i'
alias grim='git rebase -i master'
alias grio='git rebase -i @{upstream}'

alias gf='git fetch --prune'
alias ff='git merge --ff-only'
alias ffm='git merge --ff-only master'
alias ffo='git merge --ff-only @{upstream}'
alias gup='gf && ffo'

alias gl="git log --no-show-signature --graph -n 1000 --format='tformat:$git_log_format'"

alias s="git status --short"
alias gs="git show --show-signature"
alias gd="git diff"
alias gdw="git diff --color-words"
alias staged="gd --cached"

unset git_log_format
# }}}
# {{{ Job control aliases and hacks
alias j='jobs -l'

setopt auto_continue # CONT any disowned commands
setopt auto_resume   # "man" automatically resumes "man command" if in background ("man other" does not)
setopt check_jobs    # print job statuses on exit, and cancel exiting the first time
setopt hup           # HUP any jobs when exiting
# }}}
# {{{ Ruby development with Bundler
alias be='bundle exec'

bundle-exec () {
  if [ -f Gemfile ]; then
    echo "(→ bundle exec $*)"
    bundle exec $@
  else
    $@
  fi
}

for gem in cap cucumber guard rspec spork; do
  alias $gem="bundle-exec $gem"
done

# }}}
# {{{ Autoload functions

autoload zmv

fpath=(~/.zsh/funcs $fpath)

autoload run-changed-specs
autoload run-branch-specs

compdef run-changed-specs=rspec
compdef run-branch-specs=rspec

# }}}
# {{{ Color shortcuts and magic
autoload colors
colors

function is256color() {
  if [[ $TERM == *256* ]]; then
    return true
  else
    return false
  fi
}

function colortest() {
  for code in {000..255}; do print -P -- "%F{$code}$code%f"; done | column -x -s ' '
}
# }}}
# {{{ Prompt settings and configuration

# Make RPROMPT disappear after running a command
setopt transient_rprompt

# From the manpage:
# If  the  PROMPT_SUBST option is set, the prompt string is first subjected to
# parameter expansion, command substitution and arithmetic expansion.
# See zshexpn(1).
setopt prompt_subst

#
# Setup VCS info for the prompt
#
function() {
  if is-at-least 4.3.0; then
    autoload -Uz vcs_info

    # Speed it up by removing systems I'm not using
    zstyle ':vcs_info:*' enable git

    zstyle ':vcs_info:*:prompt:*' use-prompt-escapes true
    zstyle ':vcs_info:*:prompt:*' check-for-changes true

    zstyle ':vcs_info:*:prompt:*' unstagedstr "%1{★%}"
    zstyle ':vcs_info:*:prompt:*' stagedstr "%1{❖%}"

    local branch_format="%F{214}%b" # %b = branch

    if is-at-least 4.3.11; then
      local changes_format="%F{022}%c%F{088}%u"
    else
      # Old version cannot show changes
      local changes_format=""
    fi

    zstyle ':vcs_info:*:prompt:*' formats       "${changes_format}${branch_format}%f" ""
    zstyle ':vcs_info:*:prompt:*' actionformats "${changes_format}${branch_format}%f [%F{cyan}%a%f]" ""

    zstyle ':vcs_info:*:prompt:*' nvcsformats   "" ""

    # Generate VCS info just before rendering prompt
    function precmd {
      vcs_info 'prompt'
    }
  else
    export vcs_info_msg_0_="zsh too old"
  fi
}

# Convenience functions to disable/enable check-for-changes in certain sessions
function disable-check-for-changes() {
  zstyle ':vcs_info:*:prompt:*' check-for-changes false
}

function enable-check-for-changes() {
  zstyle ':vcs_info:*:prompt:*' check-for-changes true
}

#
# Helper functions to be used when building the prompt
#

# Show verbose mode information
function vi_mode_prompt_info {
  zle_mode_output "" "%K{196}%F{000} CMD %f%k"
}

# Treat these characters as having width 1
_prompt_insert_mode_character="%1{›%}"
_prompt_command_mode_character="%1{»%}"

# Show mode information by the last character in the prompt
function prompt_end_character {
  zle_mode_output "$_prompt_insert_mode_character " "%F{196}${_prompt_command_mode_character}%f "
}

#
# Actually set up the PROMPT and RPROMPT variables
#
function {
  if is256color; then
    local current_time="%F{247}%D{%H:%M:%S}"
  else
    local current_time="%F{white}%D{%H:%M:%S}"
  fi

  if [[ -n $SSH_CLIENT ]]; then
    if is256color; then
      local host="%F{241}@%F{60}%4m "
    else
      local host="%f@%F{blue}%4m "
    fi
  else
    local host=""
  fi

  # Don't show user at all if it's expected username
  if [[ $USER == "mange" ]]; then
    local user=""
  else
    # Color user differently if we have a privileged user ("!")
    # %(nx.true.false)
    local user="%(!.%F{196}.%F{072})%n"
  fi

  local dir="%B%F{blue}%4~%b"
  local last_status="%(?.. %F{red}%?)"
  local current_jobs="%(1j.%F{magenta}%B%j%b.)"
  local end='$(prompt_end_character)%f%k%b'

  export RPROMPT='$(vi_mode_prompt_info)$vcs_info_msg_0_'
  export PROMPT="${user}${host}${current_time}${last_status} ${dir} ${current_jobs}${end}"
}
# }}}
# {{{ Misc
# Report command time when it took more than this number of seconds
export REPORTTIME=10

# Disable flow control to allow ctrl-s and ctrl-q in terminal
stty -ixon -ixoff

# Autocompletion for Travis gem
[ -f $HOME/.travis/travis.sh ] && source $HOME/.travis/travis.sh
# }}}

# Chain with true to avoid $? being false
[ -f ~/.zshrc.after ] && source ~/.zshrc.after || true

# {{{ RVM
if [[ -s /usr/local/rvm/scripts/rvm ]]; then
  source /usr/local/rvm/scripts/rvm
elif [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
  source "$HOME/.rvm/scripts/rvm"
fi
# }}}

unset alias-if-exist
