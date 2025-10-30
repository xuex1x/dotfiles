# Personal Zsh configuration file. It is strongly recommended to keep all
# shell customization and configuration (including exported environment
# variables such as PATH) in this file or in files sourced from it.
#
# Documentation: https://github.com/romkatv/zsh4humans/blob/v5/README.md.

# Periodic auto-update on Zsh startup: 'ask' or 'no'.
# You can manually run `z4h update` to update everything.
# Set neovim path

zstyle ':z4h:'                  auto-update            no
zstyle ':z4h:'                  auto-update-days       28
zstyle ':z4h:*'                 channel                testing
zstyle ':z4h:autosuggestions'   forward-char           partial-accept
zstyle ':z4h:autosuggestions'   end-of-line            partial-accept
zstyle ':z4h:term-title:ssh'    precmd                 ${${${Z4H_SSH##*:}//\%/%%}:-%m}': %~'
zstyle ':z4h:term-title:ssh'    preexec                ${${${Z4H_SSH##*:}//\%/%%}:-%m}': ${1//\%/%%}'
zstyle ':z4h:command-not-found' to-file                "$TTY"
zstyle ':z4h:'                  term-shell-integration yes
zstyle ':z4h:'                  propagate-cwd          yes
zstyle ':z4h:'                  prompt-height          4

# zstyle ':z4h:direnv'          enable                 yes
# zstyle ':z4h:'                start-tmux             no
# zstyle ':z4h:'                start-tmux             command tmux -u new -A -D -t z4h
zstyle ':z4h:'                start-tmux             command tmux -u new -A -s dev
# zstyle ':z4h:'                term-vresize           top

if [[ -e ~/.ssh/id_rsa ]]; then
  zstyle ':z4h:ssh-agent:' start      yes
  zstyle ':z4h:ssh-agent:' extra-args -t 20h
else
  : ${GITSTATUS_AUTO_INSTALL:=0}
fi

() {
  local var proj dir
  for var proj in P10K powerlevel10k ZSYH zsh-syntax-highlighting ZASUG zsh-autosuggestions; do
    if [[ ${(P)var} == 0 ]]; then
      zstyle ":z4h:$proj" channel none
    elif [[ -e ${dir::=~/$proj} || -e ${dir::=~/zsh4humans/deps/$proj} ]]; then
      zstyle ":z4h:$proj" channel command "zf_ln -s -- ${(q)dir} \$Z4H_PACKAGE_DIR"
    fi
  done
}

if [[ $TERM == xterm-256color && ! -v ZSH_SCRIPT && ! -v ZSH_EXECUTION_STRING &&
      -z $SSH_CONNECTON && P9K_SSH -ne 1 && -e ~/.ssh/id_rsa && -e /proc/uptime &&
      ! (/tmp/wiped-after-boot -nt /proc/uptime) && -r /proc/version &&
      "$(</proc/version)" == *Microsoft* ]]; then
  print -Pr -- "%F{3}zsh%f: wiping %U/tmp%u ..."
  sudo rm -rf -- /tmp/*(ND)
  : >/tmp/wiped-after-boot
fi

z4h install romkatv/archive romkatv/zsh-prompt-benchmark

z4h init || return

setopt glob_dots magic_equal_subst no_multi_os no_local_loops
setopt rm_star_silent rc_quotes glob_star_short

ulimit -c $(((4 << 30) / 512))  # 4GB

path+=(~/.dotnet/tools(-/N) '/mnt/c/Program Files/Microsoft VS Code/bin'(-/N))

fpath=($Z4H/romkatv/archive $fpath)
[[ -d ~/dotfiles/functions ]] && fpath=(~/dotfiles/functions $fpath)

autoload -Uz -- zmv archive lsarchive unarchive ~/dotfiles/functions/[^_]*(N:t)

if [[ -x ~/bin/redit ]]; then
  export VISUAL=~/bin/redit
else
  export VISUAL=${${commands[nano]:t}:-vi}
fi

export EDITOR=$VISUAL
export GPG_TTY=$TTY
export PAGER=less
export GOPATH=$HOME/go
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export HOMEBREW_NO_ANALYTICS=1
export SYSTEMD_LESS=${LESS}S
export HOMEBREW_NO_ENV_HINTS=1
export MANOPT=--no-hyphenation

if (( $+z4h_win_env )); then
  export NO_AT_BRIDGE=1
  export LIBGL_ALWAYS_INDIRECT=1
  [[ -z $SSH_CONNECTON && $P9K_SSH != 1 && -z $DISPLAY ]] && export DISPLAY=localhost:0.0
  (( $+z4h_win_home )) && hash -d w=$z4h_win_home
fi

() {
  local hist
  for hist in ~/.zsh_history*~$HISTFILE(N); do
    fc -RI $hist
  done
}

function md() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }

compdef _directories md
compdef _default     open

zstyle    ':z4h:ssh:*' enable           no
zstyle    ':z4h:ssh:*' ssh-command      command ssh
zstyle    ':z4h:ssh:*' send-extra-files '~/.zshenv-private' '~/.zshrc-private' '~/.config/htop/htoprc'
zstyle -e ':z4h:ssh:*' retrieve-history 'reply=($ZDOTDIR/.zsh_history.${(%):-%m}:$z4h_ssh_host)'

function z4h-ssh-configure() {
  (( z4h_ssh_enable )) || return 0
  local file
  for file in $ZDOTDIR/.zsh_history.*:$z4h_ssh_host(N); do
    (( $+z4h_ssh_send_files[$file] )) && continue
    z4h_ssh_send_files[$file]='"$ZDOTDIR"/'${file:t}
  done
}

[[ -e ~/.ssh/control-master ]] || zf_mkdir -p -m 700 ~/.ssh/control-master

if [[ -e ~/gitstatus/gitstatus.plugin.zsh ]]; then
  : ${GITSTATUS_LOG_LEVEL=DEBUG}
  : ${POWERLEVEL9K_GITSTATUS_DIR=~/gitstatus}
fi

() {
  local key keys=(
    "^B"   "^D"   "^F"   "^N"   "^O"   "^P"   "^Q"   "^S"   "^T"   "^W"
    "^X*"  "^X="  "^X?"  "^XC"  "^XG"  "^Xa"  "^Xc"  "^Xd"  "^Xe"  "^Xg"  "^Xh"  "^Xm"  "^Xn"
    "^Xr"  "^Xs"  "^Xt"  "^Xu"  "^X~"  "^[ "  "^[!"  "^['"  "^[,"  "^[<"  "^[>"  "^[?"
    "^[A"  "^[B"  "^[C"  "^[D"  "^[F"  "^[G"  "^[L"  "^[M"  "^[N"  "^[P"  "^[Q"  "^[S"  "^[T"
    "^[U"  "^[W"  "^[_"  "^[a"  "^[b"  "^[d"  "^[f"  "^[g"  "^[l"  "^[n"  "^[p"  "^[q"  "^[s"
    "^[t"  "^[u"  "^[w"  "^[y"  "^[z"  "^[|"  "^[~"  "^[^I" "^[^J" "^[^_" "^[\"" "^[\$" "^X^B"
    "^X^F" "^X^J" "^X^K" "^X^N" "^X^O" "^X^R" "^X^U" "^X^X" "^[^D" "^[^G")
  for key in $keys; do
    bindkey $key z4h-do-nothing
  done
}

z4h bindkey z4h-accept-line         Enter
z4h bindkey z4h-backward-kill-word  Ctrl+Backspace
z4h bindkey z4h-backward-kill-zword Ctrl+Alt+Backspace
z4h bindkey z4h-cd-back             Alt+Left
z4h bindkey z4h-cd-forward          Alt+Right
z4h bindkey z4h-cd-up               Alt+Up
z4h bindkey z4h-fzf-dir-history     Alt+Down
z4h bindkey z4h-exit                Ctrl+D
z4h bindkey z4h-quote-prev-zword    Alt+Q
z4h bindkey copy-prev-shell-word    Alt+C

function skip-csi-sequence() {
  local key
  while read -sk key && (( $((#key)) < 0x40 || $((#key)) > 0x7E )); do
    # empty body
  done
}

zle -N skip-csi-sequence
bindkey '\e[' skip-csi-sequence

# TODO: When moving this to z4h, condition it on _z4h_zle.
setopt ignore_eof

if (( $+functions[toggle-dotfiles] )); then
  zle -N toggle-dotfiles
  z4h bindkey toggle-dotfiles Ctrl+T
fi

zstyle ':z4h:fzf-dir-history'                fzf-bindings       tab:repeat
zstyle ':z4h:fzf-complete'                   fzf-bindings       tab:repeat
zstyle ':z4h:cd-down'                        fzf-bindings       tab:repeat

zstyle ':zle:up-line-or-beginning-search'    leave-cursor       no
zstyle ':zle:down-line-or-beginning-search'  leave-cursor       no

zstyle ':completion:*'                       sort               false
zstyle ':completion:*:ls:*'                  list-dirs-first    true
zstyle ':completion:*:ssh:argument-1:'       tag-order          hosts users
zstyle ':completion:*:scp:argument-rest:'    tag-order          hosts files users
zstyle ':completion:*:(ssh|scp|rdp):*:hosts' hosts

alias '$'=' '
alias '%'=' '

aliases[=]='noglob arith-eval'

function grep_no_cr() {
  emulate -L zsh -o pipe_fail
  local -a tty base=(grep)
  if [[ ${${:-grep}:c:A:t} != busybox* ]]; then
    base+=(--exclude-dir={.bzr,CVS,.git,.hg,.svn})
    tty+=(--color=auto --line-buffered)
  fi
  if [[ -t 1 ]]; then
    $base $tty "$@" | tr -d "\r"
  else
    $base "$@"
  fi
}
compdef grep_no_cr=grep
alias grep=grep_no_cr

(( $+commands[tree]  )) && alias tree='tree -a -I .git --dirsfirst'
(( $+commands[gedit] )) && alias gedit='gedit &>/dev/null'
(( $+commands[rsync] )) && alias rsync='rsync -rz --info=FLIST,COPY,DEL,REMOVE,SKIP,SYMSAFE,MISC,NAME,PROGRESS,STATS'

if (( $+commands[exa] )); then
  alias l1='exa -1 --group-directories-first --color=auto'
  alias ls='exa --group-directories-first --color=auto'
  alias ll='exa -la --group-directories-first --color=auto'
  alias la='exa -a --group-directories-first --color=auto'
  alias l='exa -l --group-directories-first --color=auto'
  alias lt='exa -T --group-directories-first --color=auto'
  alias lg='exa -la --git --group-directories-first --color=auto'
else
  if ls --version > /dev/null 2>&1; then
    alias ls='ls --color=auto --group-directories-first'
    alias ll='ls -alF --color=auto --group-directories-first'
    alias la='ls -A --color=auto --group-directories-first'
    alias l='ls -lh --color=auto --group-directories-first'
  else
    # BSD/macOS 的 ls：没有 --color=auto，用 -G；也没有 --group-directories-first
    alias ls='ls -G'
    alias ll='ls -lG'
    alias la='ls -laG'
    alias l='ls -lhG'
  fi

  # 树形视图回退：若有 tree 命令就用，否则 lt 退化为长列表
  if (( $+commands[tree] )); then
    alias lt='tree -C'
  else
    alias lt='ls -l'
  fi

  # 没有 exa/eza 时，lg（git 状态列表）退化为普通长列表
  alias lg='ll'
fi


if [[ -v commands[xclip] && -n $DISPLAY ]]; then
  function x() xclip -selection clipboard -in
  function v() xclip -selection clipboard -out
  function c() xclip -selection clipboard -in -filter
elif [[ -v commands[base64] && -w $TTY ]]; then
  function x() {
    emulate -L zsh -o pipe_fail
    {
      print -n '\e]52;c;' && base64 | tr -d '\n' && print -n '\a'
    } >$TTY
  }
  function c() {
    emulate -L zsh -o pipe_fail
    local data
    data=$(tee -- $TTY && print x) || return
    data[-1]=
    print -rn -- $data | x
  }
else
  [[ -v functions[x] ]] && unfunction x
  [[ -v functions[v] ]] && unfunction v
  [[ -v functions[c] ]] && unfunction c
fi

if [[ -v functions[x] ]]; then
  function copy-buffer-to-clipboard() print -rn -- "$PREBUFFER$BUFFER" | x
  zle -N copy-buffer-to-clipboard
  bindkey '^S' copy-buffer-to-clipboard
fi

if [[ -x ~/bin/num-cpus ]]; then
  if (( $+commands[make] )); then
    alias make='make -j "${_my_num_cpus:-${_my_num_cpus::=$(~/bin/num-cpus)}}"'
  fi
  if (( $+commands[cmake] )); then
    alias cmake='cmake -j "${_my_num_cpus:-${_my_num_cpus::=$(~/bin/num-cpus)}}"'
  fi
fi

POSTEDIT=$'\n\n\e[2A'

z4h source -c -- $ZDOTDIR/.zshrc-private
z4h compile -- $ZDOTDIR/{.zshenv,.zprofile,.zshrc,.zlogin,.zlogout}

export PATH="$HOME/.local/bin:$PATH"

alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
bindkey '^F' forward-word
bindkey '^P' up-line-or-history

# * ~/.extra can be used for other settings you don’t want to commit.
if [ -f ~/.extra ]; then
    . ~/.extra
fi

