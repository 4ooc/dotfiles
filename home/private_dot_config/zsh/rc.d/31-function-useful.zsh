#!/usr/bin/env zsh

__with_pipe() {
  if [ -t 0 ]; then
    echo "Error: This function must be used with a pipe." >&2
    return 1
  fi
}

x() {
  __with_pipe || return 1

  if [ "$1" = "cd" ]; then
    local param=$(command cat)
    local param2=$param
    if [ ! -d "$param2" ]; then
      param2="${param2:h}"
      if [ ! -d "$param2" ] || [ "." = "$param2" ]; then
        echo "Error: 'cd' can't find path \"$param\"" >&2
        return 1
      fi
    fi
    cd "$param2"
  else
    if [[ "$@" == *"{}"* ]]; then
      set -- "-I{}" $@
    fi
    command cat | xargs -n 1 -o $@
  fi
}

s() {
  __with_pipe || return 1
  command cat | tail +$((${1:-1}+1))
}

n() {
  __with_pipe || return 1
  command cat | awk '{print $'$1'}'
}

cz() {
  CHEZMOI_CAN_DECRYPT=$(pass -t &>/dev/null && echo "T") chezmoi "$@"
}

find_file_up() {
  local root_dir="$CODE_SPACE"
  if [[ $PWD != "$root_dir"* ]]; then
    echo "only work in $root_dir"
    return 1
  fi

  local filename="$1"
  local current_dir="$PWD"
  while [[ "$current_dir" != "$root_dir" ]]; do
    if [[ -e "$current_dir/$filename" ]]; then
      echo "$current_dir/$filename"
      return 0
    fi
    current_dir=$(dirname "$current_dir")
  done

  return -1
}

gradle() {
  local gradlew_path="$(find_file_up gradlew)"
  if [ ! -f "$gradlew_path" ]; then
    echo "gradlew not found"
    return 1
  fi
  $gradlew_path -Duser.home=$HOME/.cache -I $HOME/.cache/gradle/init.gradle "$@"
}
alias gradlew=gradle

mvn() {
  local mvnw_path="$(find_file_up mvnw)"
  if [ ! -f "$mvnw_path" ]; then
    echo "mvnw not found"
    return 1
  fi
  $mvnw_path -s $HOME/.config/maven/settings.xml "$@"
}
alias mvnw=mvn

if command -v pass &>/dev/null; then
  totp() {
    local temp exist_code
    temp=$(pass "totp" "$1")
    exist_code=$?
    if [ $exist_code -ne 0 ]; then
      return $exist_code
    fi
    local code=$(oathtool --totp --base32 $temp)
    echo $code

    (( $+commands[pbcopy] )) && echo -n $code | pbcopy || true
    (( $+commands[termux-clipboard-set] )) && termux-clipboard-set $code || true
  }
fi
