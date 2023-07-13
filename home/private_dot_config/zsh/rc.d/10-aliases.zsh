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

# fix sudo aliases not effect
alias sudo='sudo '
alias sed='gsed'
alias grep='grep --color=auto'
alias pip=pip3
alias get-my-ip='curl ifconfig.co'
alias ps-grep="ps aux | grep -v grep | grep -i -e VSZ -e"
alias get-open-ports='lsof -i -n -P | grep TCP'
alias podman-exec="f(){podman exec -it \$1 /bin/bash;unfunction f};f"
alias walk_gits=" find . -name .git -type d -execdir sh -c '[[ \$PWD != *nvim* ]] && [[ -n \$(git status -s) ]] && echo \"\\033[1;35m\$(dirname \"\$(realpath {})\")\\033[0m\"&&git status --untracked-files=all -s' \\;"
alias fd="fd --hidden --no-ignore"
alias automw="automw >> /tmp/automw 2>&1 &"
alias ll="ls -lA"
alias l=ll
alias la=ll
alias q="qlmanage -p "
alias livecheck="brew livecheck alacritty-preview | awk '\$2!=\$4{print \$4}' | xargs -I {} brew bump-cask-pr --write-only --version={} alacritty-preview"

function zshEnv() {
  local temp=$(mktemp -d)
  cd $temp
  env -i HOME=$PWD PATH=$PATH TERM=$TERM ${TERMINFO:+TERMINFO=$TERMINFO} zsh -d
  cd $HOME
  rm -rf $temp
}

function gradle() {
  local workspace="$HOME/Codespace"
  local gradlew_path="$workspace/${${PWD#$workspace/}%%/*}/gradlew"
  if [ ! -f "$gradlew_path" ]; then
    echo "gradlew not found"
    return 1
  fi
  $gradlew_path -Duser.home=$HOME/.cache "$@"
}
functions -c gradle gradlew

function mvn() {
  local workspace="$HOME/Codespace"
  local mvnw_path="$workspace/${${PWD#$workspace/}%%/*}/mvnw"
  if [ ! -f "$mvnw_path" ]; then
    echo "mvnw not found"
    return 1
  fi
  $mvnw_path -s $HOME/.config/maven/setting.xml "$@"
}
functions -c mvn mvnw

function sheet:shortcuts {
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
