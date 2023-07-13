sdkman_auto_env () {
  if [[ -n $SDKMAN_ENV ]] && [[ ! $PWD =~ ^$SDKMAN_ENV ]] then
    if [[ -e "$SDKMAN_ENV/.sdkmanrc" ]] then
      sdk env clear
    else
      __sdkman_env_restore_default_version java
    fi
    unset SDKMAN_ENV
  fi

  if [[ -n $SDKMAN_ENV ]] && [[ $PWD =~ ^$SDKMAN_ENV ]] then
    return
  fi

  if [[ -f .sdkmanrc ]]; then
    sdk env
  fi

  if [[ ! $PWD =~ ^$HOME/Codespace/ ]]; then
    return
  fi

  local workspace="$HOME/Codespace/${${PWD#$HOME/Codespace/}%%/*}" java_version
  if [[ -f "$workspace/.sdkmanrc" ]]; then
    if [[ $workspace != $PWD ]]; then
      java_version=$(cat "$workspace/.sdkmanrc" | grep ^java= | awk -F= '{print $2}')
      sdk use java $java_version
      SDKMAN_ENV=$workspace
    fi
  elif [[ -f "$workspace/build.gradle" ]]; then
    major_version=$(cat "$workspace/build.gradle" | grep 'sourceCompatibility' | grep -Eo '[0-9.]+' | sed s/^1\\.//)
    java_version=$(sdk list java | awk '{print $2}' | grep -E "^$major_version\.")
    if [[ -n $java_version ]]; then
      sdk use java $java_version
    else
      __sdkman_echo_red "No java $major_version installed"
    fi
    SDKMAN_ENV=$workspace
  fi
}

+autocomplete:recent-directories() {}
