#!/bin/bash

if [ -z "$TERM" ] || [ "$TERM" = "dumb" ]; then
  _red="\e[31m"
  _green="\e[32m"
  _yellow="\e[33m"
  _reset="\e[0m"
else
  _red=`tput -T $TERM setaf 1`
  _green=`tput -T $TERM setaf 2`
  _yellow=`tput -T $TERM setaf 3`
  _reset=`tput -T $TERM sgr0`
fi

COLOR() {
  echo "$1$2${_reset}"
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