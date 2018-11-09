#!/bin/bash
set -o pipefail

VERSION_REGEX="[0-9]\.[0-9]\.[0-9]"

for orb in src/**/*.yml; do 
  version_comment=$(head -n 1 $orb)
  version=$(echo $version_comment | grep -o "$VERSION_REGEX")

  if [ -z $version ] || [ ! "${version_comment:0:1}" == "#" ]; then
    echo "Every orb is expected to have a version comment on line 1"
    echo "It should look something like '# Orb Version 1.0.0'"
    exit 1
  fi

  circleci orb validate $orb 
done