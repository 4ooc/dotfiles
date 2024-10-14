#!/usr/bin/env zsh

# NAVIGATION
cd_alias() { builtin alias "${1}"="cd ${2}"; }
cd_alias ".." ".."
cd_alias "..." "../.."
cd_alias "...." "../../.."
cd_alias "....." "../../../.."
cd_alias "h" "$HOME"
cd_alias "/" "/"

alias_array() { for i ("${@[0,-2]}"); do alias $i=${@: -1}; done }
alias_array py python python3
alias_array v vi vim nvim

# fix sudo aliases not working
alias sudo='sudo '
alias grep='grep --color=auto'
alias pip=pip3
alias get-my-ip='curl ifconfig.co'
alias ps-grep="ps aux | grep -v grep | grep -i -e VSZ -e"
alias p=ps-grep
alias get-open-ports='lsof -i -n -P | grep TCP'
alias podman-exec="f(){podman exec -it \$1 /bin/bash;unfunction f};f"
alias walk_gits=" find . -name .git -type d -execdir sh -c '[[ \$PWD != *nvim* ]] && [[ -n \$(git status -s) ]] && echo \"\\033[1;35m\$(dirname \"\$(realpath {})\")\\033[0m\"&&git status --untracked-files=all -s' \\;"
alias fd="fd --hidden --no-ignore"
alias automw="set +m;nohup automw >> /tmp/automw 2>&1 & disown;set -m"
alias ls="eza --sort=type --time-style=relative"
alias ll="ls -lA"
alias l=ll
alias la=ll
alias livecheck="brew livecheck alacritty-preview | awk '\$2!=\$4{print \$4}' | xargs -I {} brew bump-cask-pr --no-audit --write-only --version={} alacritty-preview"

function zshEnv() {
  local temp=$(mktemp -d)
  cd $temp
  env -i HOME=$PWD TERM=$TERM ${TERMINFO:+TERMINFO=$TERMINFO} zsh -d
  cd $HOME
  rm -rf $temp
}

function chezmoi_clean() {
  local target=$(chezmoi target-path)
  for managed in $(chezmoi managed); do
    [[ -f "$target/$managed" ]] && {
      rm -v $target/$managed
    }
  done

  chezmoi purge
}

function sheet_shortcuts {
  echo '
    shortcuts for xterm:
      ctrl+A          ctrl+E    ─┐
      ┌─────────┬──────────┐     │
      │  alt+B  │ alt+F    │     ├─► Moving
      │  ┌──────┼────┐     │     │
      ▼  ▼      │    ▼     ▼    ─┘
    $ cp assets-|files dist/
         ◄────── ────►          ─┐
          ctrl+W alt+D           │
                                 ├─► Erasing
      ◄───────── ──────────►     │
        ctrl+U     ctrl+K       ─┘
        ctrl+/ ──► Undo
  '
}

clearDSAndTrash ()
{
  fd "^.DS_Store$" ~ | xargs -I {} rm -rv "{}"
  fd "^.Trash$" ~ | xargs -I {} sudo rm -rv "{}"
}

u() {
  (( $+commands[brew] )) && brew update
  (( $+functions[zinit] )) && zinit update -p
}
