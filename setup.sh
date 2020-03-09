#!/bin/bash

# Sets up development dependencies

echo -n "Checking for cicleci... "
if ! [ -x "$(command -v circleci)" ]; then
  echo "not found, installing"
  brew install circleci
  echo "You'll need to create a personal circle api key to use the cli. Opening that page now..."
  sleep 2
  open https://circleci.com/account/api
  echo "Once your done creating a token, finish the circle setup..."
  sleep 3
  circleci setup
else
  echo "found, skipping."
fi

echo -n "Checking for lefthook... "
if ! [ -x "$(command -v lefthook)" ]; then
  echo "not found, installing"
  brew install Arkweid/lefthook/lefthook
  lefthook install
else
  echo "found, skipping."
fi

echo -n "Checking for spellcheck... "
if ! [ -x "$(command -v shellcheck)" ]; then
  echo "not found, installing"
  brew install shellcheck
else
  echo "found, skipping."
fi
