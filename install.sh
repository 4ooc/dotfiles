#!/bin/sh

RED='\033[0;31m'
GREEN='\033[0;32m'
RESET='\033[0m'
package_command=""

_error() { echo "${RED}[ERROR]${RESET} ${1}"; }
_info() { echo "${GREEN}[INFO]${RESET} ${1}"; }
_has() { command -v "$1" > /dev/null; }
_install_command() {
  ! _has "$1" && {
    test -z "$package_command" && {
      _error "Need to install $1"
      return
    }

    _info "installing $1"
    $package_command install $1
  }
}

case "$(uname -o)" in
  Darwin)
    _info "macOS start"

    if [ ! -e /opt/homebrew ]; then
      _info "Preparing to install Homebrew"
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    eval "$(/opt/homebrew/bin/brew shellenv)"

    package_command="brew"
    ;;
  Android)
    _info "Android start"

    if [ ! -e $HOME/storage ]; then
      termux-setup-storage
    fi

    package_command="pkg"
    ;;
  *)
    _error "Unknow OS"
    ;;
esac

for cmd in age git chezmoi; do
  _install_command $cmd
done

chezmoi init 4ooc --apply && {
  _info "Script finished"
} || {
  _error "Script failed"
}
