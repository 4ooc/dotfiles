#!/bin/zsh

set -e

_error() { print -P "%F{red}[ERROR]%f %F{white}${1}%f" >&2; }
_info() { print -P "%F{white}[INFO]%f %F{cyan}${1}%f"; }
_has() { command -v "$1" &> /dev/null; }

set -a
XDG_CACHE_HOME="$HOME/.cache"
XDG_CONFIG_HOME="$HOME/.config"
XDG_DATA_HOME="$HOME/.local/share"

ZDOTDIR="$XDG_CONFIG_HOME/zsh"
LESSHISTFILE="$XDG_CACHE_HOME/less/less_history"
EJSON_KEYDIR="$HOME/storage/Keys"
set +a

if ! _has git; then
  _info "Try to install git ..."
  case "$(uname)" in
    Darwin)
      xcode-select --install
      ;;
    *)
      _error "No method to install git"
      ;;
  esac
fi

# use zinit to manage chezmoi and age
ZINIT_PATH="$XDG_DATA_HOME/zinit"
[ ! -d $ZINIT_PATH/zinit.git ] && git clone "https://github.com/zdharma-continuum/zinit.git" "$ZINIT_PATH/zinit.git" --depth=1
[ ! -d $ZINIT_PATH/polaris/bin ] && mkdir -p "$ZINIT_PATH/polaris/bin"

set +e
builtin source "${ZINIT_PATH}/zinit.git/zinit.zsh"

zinit depth'1' for @zdharma-continuum/zinit-annex-binary-symlink
zinit lucid from'gh-r' lbin'!' nocompile for \
  cp'**/chezmoi.zsh -> _chezmoi' \
  @twpayne/chezmoi \
  lbin'!age*' extract'!' \
  @FiloSottile/age
set -e

chezmoi init 4ooc --apply

_info "Script finished"
