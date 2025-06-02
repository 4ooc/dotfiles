#!/bin/sh

RED='\033[0;31m'
GREEN='\033[0;32m'
RESET='\033[0m'
package_command=""

_error() { echo "${RED}[ERROR]${RESET} ${1}"; }
_info() { echo "${GREEN}[INFO]${RESET} ${1}"; }
_has() { command -v "$1" >/dev/null; }
_install_command() {
	! _has "$1" && {
		test -z "$package_command" && {
			_error "Need to install $1"
			return
		}

		_info "installing ${2:-$1}"
		$package_command install "${2:-$1}"
	}
}

case "$(uname -o)" in
Darwin)
	_info "macOS config start"

	if [ ! -e /opt/homebrew ]; then
		_info "Preparing to install Homebrew"
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi
	eval "$(/opt/homebrew/bin/brew shellenv)"

	package_command="brew"
	;;
Android)
	_info "android config start"

	if [ ! -e "$HOME/storage" ]; then
		_info "Preparing to setup storage"
		termux-setup-storage
	fi

	package_command="pkg"
	;;
*)
	_error "unknow OS abort"
	;;
esac

for cmd in age chezmoi git; do
	read -r command package <<EOF
  $(echo "$cmd" | sed 's/#/ /')
EOF
	_install_command "$command" "$package"
done

if ! ssh -n -o BatchMode=yes -o ConnectTimeout=3 -T vault.x exit 2>/dev/null; then
	if [ "$(uname -o)" != "android" ]; then
		printf "Input termux host: "
		read -r termux_host </dev/tty
		export TERMUX_HOST="$termux_host"
	fi
fi

_info "chezmoi init starting..."
if chezmoi init 4ooc --apply; then
	_info "chezmoi apply finished"
else
	_error "chezmoi apply failed"
fi

env -i zsh -il
