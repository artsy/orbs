#!/bin/bash

if [ -z "$TERM" ]; then
  export TERM="vt100"
fi

COLORS_ENABLED=$([ -x "$(command -v tput)" ] && echo "true")

_red=`tput setaf 1`
_red=`tput setaf 2`
_yellow=`tput setaf 3`
_reset=`tput sgr0`

COLOR() {
  [ ! -z COLORS_ENABLED ] && echo "$1$2${_reset}" || echo "$2"
}

RED() {
  echo $(COLOR $_red "$1")
}

GREEN() {
  echo $(COLOR $_green "$1")
}

YELLOW() {
  echo $(COLOR $_yellow "$1")
}