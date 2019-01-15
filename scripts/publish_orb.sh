#!/bin/bash
set -euo pipefail

. ./scripts/orb_utils.sh

TOKEN=""
if [ ! -z "${CIRCLECI_API_KEY:-}" ]; then
  TOKEN="--token $CIRCLECI_API_KEY"
fi

echo ""
echo "Beginning publish of artsy/$1 orb"

ORB="$1"

# Ensuring orb is valid
./scripts/validate_orb.sh $ORB

ORB_PATH=$(get_orb_path $ORB)
VERSION=$(get_orb_version $ORB)
LAST_PUBLISHED=$(get_published_orb_version $ORB)

case $(compare_version $VERSION $LAST_PUBLISHED) in
  "=")
    echo "artsy/$ORB@$VERSION is the latest, skipping publish"
    exit 0
    ;;
  "<")
    echo "artsy/$ORB@$LAST_PUBLISHED is the latest, cannot publish older version $VERSION"
    echo "Please update $ORB_PATH to have a version greater than $LAST_PUBLISHED"
    exit 1
    ;;
  ">")
    echo "Preparing to bump artsy/$ORB from $LAST_PUBLISHED to $VERSION"
    ;;
  *)
    echo "Version comparison for artsy/$ORB failed."
    echo "Current version: $VERSION"
    echo "Published version: $LAST_PUBLISHED"
    exit 1
    ;;
esac

circleci orb publish $ORB_PATH artsy/$ORB@$VERSION $TOKEN

./slack \
  -color "good" \
  -title "Circle CI $ORB orb v$VERSION published!" \
  -title_link "${CIRCLE_BUILD_URL:-https://circleci.com/gh/artsy/orbs/tree/master}" \
  -user_name "artsyit" \
  -icon_emoji ":crystal_ball:"
