#!/usr/bin/env zsh

alias -g NO="1>/dev/null"
alias -g NE="2>/dev/null"
alias -g NA=">/dev/null 2>&1"

# NAVIGATION
+ᴀʟᴀɪꜱ_array() for i ("$@[2,-1]") alias $i=$1
+ᴀʟᴀɪꜱ_cd_dots() alias "${(l:$1::.:)}"="cd ${(l:3*$1-4::/..:)}"

alias h="cd $HOME"
alias "/"="cd /"
for i ({2..5}) +ᴀʟᴀɪꜱ_cd_dots $i

+ᴀʟᴀɪꜱ_array python3 py python
+ᴀʟᴀɪꜱ_array nvim v vi vim

if has eza; then
  alias ls='eza --icons --git --group-directories-first --sort=type'
  alias ll='ls --all --long --group --time-style=iso'
  +ᴀʟᴀɪꜱ_array ll l la
fi

alias cz="command chezmoi"
alias grep='grep --color=auto'
alias get-my-ip='curl -s cip.cc'
alias ps-grep="ps aux | grep -v grep | grep -i -e VSZ -e"
alias p=ps-grep
alias get-open-ports='lsof -i -n -P | grep TCP'
alias podman-exec="f(){podman exec -it \$1 /bin/bash;unfunction f};f"
alias walk_gits='find . -name .git -type d -execdir sh -c '\''case "$PWD" in *nvim*) exit 0;; esac; if git rev-parse --is-inside-work-tree >/dev/null 2>&1 && [ -n "$(git status -s)" ]; then printf "\033[1;35m%s\033[0m\n" "$PWD"; git status --untracked-files=all -s; fi'\'' \;'
alias fd="fd --hidden --no-ignore"
alias livecheck="f(){brew livecheck \$1 | awk '\$2!=\$4{print \$4}' | xargs -I {} brew bump-cask-pr --no-audit --write-only --version={} \$1};f"

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
