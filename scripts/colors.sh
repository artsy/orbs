#!/bin/bash

if [ -z "$TERM" ] || [ "$TERM" = "dumb" ]; then
  TERM="xterm-256color"
fi

COLORS_ENABLED=$([ -x "$(command -v tput)" ] && echo "true")

_red=`tput -T $TERM setaf 1`
_green=`tput -T $TERM setaf 2`
_yellow=`tput -T $TERM setaf 3`
_reset=`tput -T $TERM sgr0`

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