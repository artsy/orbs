#!/bin/bash
set -euo pipefail

VERSION_REGEX="[0-9]\.[0-9]\.[0-9]"
RED="\x1B[31m"

print() {
  reset="\x1B[0m"
  color=$1
  echo "$color$2$reset"
}

echo ""
echo "Running publish for orb $1..."

ORB="$1"
YML_PATH="./src/$ORB/$ORB.yml"

if [ ! -f "$YML_PATH" ]; then
  echo "No orb exists at $YML_PATH"
  exit 1
fi

VERSION_COMMENT=$(head -n 1 $YML_PATH)
VERSION=$(echo $VERSION_COMMENT | grep -o "$VERSION_REGEX")

# Ensure the version is defined and that the version comment actually is a comment...
if [ -z $VERSION ] || [ ! "${VERSION_COMMENT:0:1}" == "#" ]; then
  echo ""
  print $RED "Orb at $YML_PATH does not have a version comment"
  print $RED "Add something like '# Orb Version 1.0.0' at the top of the file"
  print $RED "That version will be used as the published version"
  exit 1
fi


LAST_PUBLISHED=$(circleci orb info artsy/$ORB | grep -i latest | grep -o "$VERSION_REGEX")

# TODO: Fail if $LAST_PUBLISHED > $VERSION
if [ $VERSION == $LAST_PUBLISHED ]; then
  echo "artsy/$ORB@$VERSION is the latest, skipping publish"
  exit 0
fi

echo "Ensuring orb is valid..."
circleci orb validate $YML_PATH

echo "Trying to publish $VERSION, last known publish version $LAST_PUBLISHED"

circleci orb publish $YML_PATH artsy/$ORB@$VERSION