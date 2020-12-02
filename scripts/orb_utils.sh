#!/bin/bash

VERSION_REGEX="[0-9]*\.[0-9]*\.[0-9]*"

check_for_namespace() {
  NAMESPACE=${NAMESPACE:-""}
  if [ -z "$NAMESPACE" ]; then
    echo "An env variable NAMESPACE must be provided that matches your CircleCI orb namespace"
    exit 1
  fi
}

get_orb_path() {
  local ORB="$1"
  local YML_PATH="./src/$ORB/$ORB.yml"
  echo "$YML_PATH"
}

get_orb_from_path() {
  local filename="$(basename "$1")"
  echo "${filename%.*}"
}

get_orb_version() {
  local YML_PATH=$(get_orb_path "$1")

  VERSION_COMMENT=$(head -n 1 "$YML_PATH")
  VERSION=$(echo "$VERSION_COMMENT" | grep -o "$VERSION_REGEX")

  echo "$VERSION"
}

is_orb_changed() {
  check_for_namespace

  local ORB="$1"
  local ORB_PATH="$(get_orb_path "$ORB")"
  local CHANGED="$(git diff --name-only origin/master "$ORB_PATH")"

  if [ -n "$CHANGED" ]; then
    echo "true"
  fi
}

is_orb_created() {
  check_for_namespace
  local CREATED=$(circleci orb list "$NAMESPACE" | grep -w "$NAMESPACE/$1")
  if [ -n "$CREATED" ]; then
    echo "true"
  fi
}

is_orb_published() {
  check_for_namespace
  local PUBLISHED=$(
    circleci orb info "$NAMESPACE/$1" >/dev/null 2>&1
    echo $?
  )
  if [ "$PUBLISHED" -eq "0" ]; then
    echo "true"
  fi
}

get_published_orb_version() {
  check_for_namespace
  local LAST_PUBLISHED=$(circleci orb info "$NAMESPACE/$1" | grep -i latest | grep -o "$VERSION_REGEX")
  echo "$LAST_PUBLISHED"
}

compare_version() {
  local GREATER=">"
  local LESS="<"
  local EQUAL="="

  IFS='.' read -ra VERSION1 <<<"$1"
  IFS='.' read -ra VERSION2 <<<"$2"

  for ((i = 0; i < ${#VERSION1[@]}; ++i)); do
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
