# Documentation: https://github.com/romkatv/zsh4humans/blob/v5/README.md.
#
# Do not modify this file unless you know exactly what you are doing.
# It is strongly recommended to keep all shell customization and configuration
# (including exported environment variables such as PATH) in ~/.zshrc or in
# files sourced from ~/.zshrc. If you are certain that you must export some
# environment variables in ~/.zshenv, do it where indicated by comments below.

if [ -n "${ZSH_VERSION-}" ]; then
  : ${ZDOTDIR:=~}
  setopt no_global_rcs
  [[ ! -e ~/.zshenv-private ]] || source ~/.zshenv-private
  if [[ -o no_interactive && -z "${Z4H_BOOTSTRAPPING-}" ]]; then
    return
  fi
  setopt no_rcs
  unset Z4H_BOOTSTRAPPING
  [[ -n "${Z4H_SSH-}" ]] || HISTFILE="$ZDOTDIR/.zsh_history.${(%):-%m}"
fi

Z4H_URL="https://raw.githubusercontent.com/romkatv/zsh4humans/v5"
: "${Z4H:=${XDG_CACHE_HOME:-$HOME/.cache}/zsh4humans/v5}"
[ -d ~/zsh4humans/main ] && Z4H_BOOTSTRAP_COMMAND='ln -s ~/zsh4humans/main "$Z4H_PACKAGE_DIR"'

umask 002

if [ ! -e "$Z4H"/z4h.zsh ]; then
  mkdir -p -- "$Z4H" || return
  >&2 printf '\033[33mz4h\033[0m: fetching \033[4mz4h.zsh\033[0m\n'
  if [ -e ~/zsh4humans/main/z4h.zsh ]; then
    ln -s -- ~/zsh4humans/main/z4h.zsh "$Z4H"/z4h.zsh || return
  else
    if command -v curl >/dev/null 2>&1; then
      curl -fsSL -- "$Z4H_URL"/z4h.zsh >"$Z4H"/z4h.zsh.$$ || return
    elif command -v wget >/dev/null 2>&1; then
      wget -O-   -- "$Z4H_URL"/z4h.zsh >"$Z4H"/z4h.zsh.$$ || return
    else
      >&2 printf '\033[33mz4h\033[0m: please install \033[32mcurl\033[0m or \033[32mwget\033[0m\n'
      return 1
    fi
    mv -- "$Z4H"/z4h.zsh.$$ "$Z4H"/z4h.zsh || return
  fi
fi

. "$Z4H"/z4h.zsh || return

setopt rcs