#!/bin/bash

VERSION_REGEX="[0-9]\.[0-9]\.[0-9]"

get_orb_path() {
  local ORB="$1"
  local YML_PATH="./src/$ORB/$ORB.yml"
  echo $YML_PATH
}

get_orb_version() {
  local YML_PATH=$(get_orb_path $1)

  VERSION_COMMENT=$(head -n 1 $YML_PATH)
  VERSION=$(echo $VERSION_COMMENT | grep -o "$VERSION_REGEX")

  echo $VERSION
}

compare_version() {
  local GREATER=">"
  local LESS="<"
  local EQUAL="="

  IFS='.' read -ra VERSION1 <<< "$1"
  IFS='.' read -ra VERSION2 <<< "$2"

  for ((i=0; i<${#VERSION1[@]}; ++i)); do
    if [ "${VERSION1[i]}" -gt "${VERSION2[i]}" ]; then
      echo $GREATER
      return
    elif [ "${VERSION1[i]}" -lt "${VERSION2[i]}" ]; then
      echo $LESS
      return
    fi
  done

  echo $EQUAL
}