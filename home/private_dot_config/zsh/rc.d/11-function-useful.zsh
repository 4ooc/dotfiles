#!/usr/bin/env zsh

__with_pipe() {
  if [ -t 0 ]; then
    echo "${1:-Error}: must be used with a pipe." >&2
    return 1
  fi
}

has() { command -v "$1" >/dev/null; }

x() {
  __with_pipe "x" || return 1

  case "$1" in
    cd)
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
      ;;
    '')
      [[ $ZSH_SUBSHELL -eq 0 ]] || echo "x: must be the last command in a pipeline." >&2

      . <(cat)
      ;;
    *)
      local command="$1"
      shift

      local args=("$@")
      if [[ "$args" != *"{}"* ]]; then
        args+=("{}")
      fi

      local expanded a line
      while read -r line; do
        expanded=()
        for a in "${args[@]}"; do
          expanded+=("${a//\{\}/$line}")
        done
        "$command" "${expanded[@]}"
      done
      ;;
  esac
}

s() {
  __with_pipe "s" || return 1
  command cat | tail +$((${1:-1}+1))
}

for i ({1..9}) alias "s$i"="s $i"

n() {
  __with_pipe "n" || return 1
  command cat | awk '{print $'$1'}'
}

for i ({1..9}) alias "n$i"="n $i"

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
  $gradlew_path -Duser.home=$XDG_CACHE_HOME -I $GRADLE_USER_HOME/init.gradle "$@"
}
alias gradlew=gradle

mvn() {
  local mvnw_path="$(find_file_up mvnw)"
  if [ ! -f "$mvnw_path" ]; then
    echo "mvnw not found"
    return 1
  fi
  $mvnw_path  -Dmaven.repo.local=$MAVEN_USER_HOME -s $MAVEN_USER_HOME/settings.xml "$@"
}
alias mvnw=mvn

wrap_mods() {
  local name="$1"
  local role="${2:-default}"
  shift
  shift
  local cont=""
  local cache_path="$TMPDIR/mods_${name}"
  local cached=$(cat "$cache_path" 2>/dev/null)
  if (( $# > 0 )); then
    if [[ -n "$cached" ]]; then
      cont="-c"
    fi
    mods $cont $cached --role $role $@
    if (( $? == 0 )) && [[ -z "$cached" ]]; then
      mods --list | head -n 1 | n 1 >"$cache_path"
    fi
  else
    echo > "$cache_path"
    if [[ -n "$cached" ]]; then
      local cached_msg=$(mods --show $cached | awk '/Assistant/{print $2}')
      if [[ "$(echo "$cached_msg" | wc -l)" -eq 1 ]]; then
        eval "$cached_msg"
      else
        echo "Clear session"
      fi
    fi
  fi
}

ai() {
  wrap_mods "ai" "shell" $@
}

chat() {
  wrap_mods "chat" "default" $@
}

fixzsh() {
  rm -rf ~/.cache/zsh/*;
}
