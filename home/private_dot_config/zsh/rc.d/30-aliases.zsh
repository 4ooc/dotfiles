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
alias grep='grep --color=auto'
alias pip=pip3
alias get-my-ip='curl ifconfig.co'
alias ps-grep="ps aux | grep -v grep | grep -i -e VSZ -e"
alias get-open-ports='lsof -i -n -P | grep TCP'
alias podman-exec="f(){podman exec -it \$1 /bin/bash;unfunction f};f"
alias walk_gits=" find . -name .git -type d -execdir sh -c '[[ \$PWD != *nvim* ]] && [[ -n \$(git status -s) ]] && echo \"\\033[1;35m\$(dirname \"\$(realpath {})\")\\033[0m\"&&git status --untracked-files=all -s' \\;"
alias fd="fd --hidden --no-ignore"
alias automw="set +m;nohup automw >> /tmp/automw 2>&1 & disown;set -m"
alias ll="ls -lA"
alias l=ll
alias la=ll
alias q="qlmanage -p "
alias livecheck="brew livecheck alacritty-preview | awk '\$2!=\$4{print \$4}' | xargs -I {} brew bump-cask-pr --no-aduit --write-only --version={} alacritty-preview"

if command -v chezmoi &>/dev/null; then
  function ej() {
    local temp exist_code
    temp=$(chezmoi execute-template '{{output "sh" "-c" "ej '$@'"}}' 2>&1)
    exist_code=$?
    if [ $exist_code -ne 0 ]; then
      echo $temp | tail -n +2
      return $exist_code
    else
      echo $temp
    fi
  }

  function totp() {
    local temp exist_code
    temp=$(ej "totp/$1")
    exist_code=$?
    if [ $exist_code -ne 0 ]; then
      echo $temp
      return $exist_code
    fi
    local code=$(oathtool --totp --base32 $temp)
    echo $code

    (( $+commands[pbcopy] )) && echo -n $code | pbcopy || true
    (( $+commands[termux-clipboard-set] )) && termux-clipboard-set $code || true
  }
fi

function zshEnv() {
  local temp=$(mktemp -d)
  cd $temp
  env -i HOME=$PWD PATH=$PATH TERM=$TERM ${TERMINFO:+TERMINFO=$TERMINFO} zsh -d
  cd $HOME
  rm -rf $temp
}

function reduce_code_space() {
  if [[ $PWD != "$CODE_SPACE"* ]]; then
    echo "only work in $CODE_SPACE"
    return 1
  fi

  local part_path="${${PWD#$CODE_SPACE}#/}"
  local file_path="$CODE_SPACE"
  while [[ $file_path != $PWD ]]; do
    file_path="$file_path/${part_path%%/*}"
    if [ -f "$file_path/$1" ]; then
      echo "$file_path/$1"
      break
    fi
    part_path=${part_path#*/}
  done
}

function gradle() {
  local gradlew_path="$(reduce_code_space gradlew)"
  if [ ! -f "$gradlew_path" ]; then
    echo "gradlew not found"
    return 1
  fi
  $gradlew_path -Duser.home=$HOME/.cache "$@"
}
alias gradlew=gradle

function mvn() {
  local mvnw_path="$(reduce_code_space mvnw)"
  if [ ! -f "$mvnw_path" ]; then
    echo "mvnw not found"
    return 1
  fi
  $mvnw_path -s $HOME/.config/maven/setting.xml "$@"
}
alias mvnw=mvn

function chezmoi_clean() {
  local target=$(chezmoi target-path)
  local paths=("$target/.ssh")
  for managed in $(chezmoi managed); do
    [[ -f "$target/$managed" ]] && {
      rm -v $target/$managed
    }
  done

  [[ -d "$target/.ssh" ]] && echo "$target/.ssh"
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
