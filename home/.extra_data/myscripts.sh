#!/bin/env sh

# !path/file  include path/* but execlude path/file
#   path/file
# path/file   execlude path/* but include path/file
#   !path/file
#   path/*
parseProfile() {
  profile=$1
  results=""
  while read -r pattern; do
    prefix="@"
    if [ "$(printf %c "${pattern}")" = "!" ]; then
      prefix=""
      pattern="${pattern:1}"
    fi
    
    while true; do
      parent=$(dirname "$pattern")

      if [ "$parent" != "." ] || [ "$prefix" != "" ]; then
        results="$results ${prefix:+!}$pattern"
      fi
      
      if [ "$parent" = "." ] || [ "$parent" = "*" ]; then
        break
      fi 
      pattern="$parent"

      parent=$(dirname "$parent")
      if [ "$parent" != "." ] || [ "$prefix" != "" ]; then
        prefix2=${prefix:-!}
        results="$results ${prefix2%@}$pattern${prefix:+/*}"
      fi 
    done
  done < "$profile"

  echo "$results" | tr ' ' '\n' | sed '/^\s*$/d' | sort | uniq
}
