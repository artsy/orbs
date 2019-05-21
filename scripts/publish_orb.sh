#!/bin/bash
set -euo pipefail

# This script is called from publish_orbs.sh
#
# Usage:
# publish_orb.sh <orb_name>
#
# When $CI isn't set or $DRY_RUN is set this script will
# skip any actual publishing steps. This means it _shouldn't_
# do any publishing when you're testing locally.

# "import" some utility functions
. ./scripts/orb_utils.sh
. ./scripts/colors.sh


echo ""
echo "Beginning publish of artsy/$1 orb"
echo ""


# Build CircleCI token argument
TOKEN=""
if [ ! -z "${CIRCLECI_API_KEY:-}" ]; then
  TOKEN="--token $CIRCLECI_API_KEY"
fi



# Set a dry-run mode
if [ ! -z "$DRY_RUN" ] || [ -z "$CI" ]; then
  DRY_RUN="true"
  echo $(YELLOW "[Running in dry-run mode]")
fi 


# Grab the current git branch
BRANCH=$(git branch | grep \* | cut -d ' ' -f2)

# Build the dev version prefix. When not on the master branch this will be
# used to publish a dev version of the orb. That can be pulled in using
# artsy/<orb-name>@dev:<version>. This is useful for testing purposes.
#
# This will be referred to as "dev mode" in later comments
DEV=""
if [ "$BRANCH" != "master" ]; then
  DEV="dev:"
  echo $(YELLOW "[Running in dev mode]")
fi

# When in dev mode
if [ ! -z "$DEV" ]; then
  echo ""
  echo "This will be a dev deployment (prefixed with dev:)"
fi


ORB="$1"

# Ensure the orb is valid
./scripts/validate_orb.sh $ORB

ORB_PATH=$(get_orb_path $ORB)
VERSION=$(get_orb_version $ORB)
IS_PUBLISHED=$(is_orb_published $ORB)

# If the orb has been previously published (i.e. it already exists in cicle's registry)
if [ ! -z "$IS_PUBLISHED" ]; then

  LAST_PUBLISHED=$(get_published_orb_version $ORB)

  case $(compare_version $VERSION $LAST_PUBLISHED) in
    "=")
      # When not in dev mode
      if [ -z "$DEV" ]; then
        echo "artsy/$ORB@$VERSION is the latest, skipping publish"
        exit 0
      fi
      ;;
    "<")
      echo $(RED "artsy/$ORB@$LAST_PUBLISHED is the latest, cannot publish older version $VERSION")
      echo $(RED "Please update $ORB_PATH to have a version greater than $LAST_PUBLISHED")
      exit 1
      ;;
    ">")
      # when not in dev mode
      if [ -z "$DEV" ]; then
        echo "Preparing to bump artsy/$ORB from $LAST_PUBLISHED to $VERSION"
      fi
      ;;
    *)
      echo $(RED "Version comparison for artsy/$ORB failed.")
      echo $(RED "Current version: $VERSION")
      echo $(RED "Published version: $LAST_PUBLISHED")
      exit 1
      ;;
  esac

  # When in dev mode
  if [ ! -z "$DEV" ];then
    echo "Preparing to publish dev orb artsy/$ORB@$DEV$VERSION"
  fi

else
  echo "Orb artsy/$ORB isn't in the registry. Creating its registry entry..."
  circleci orb create artsy/$ORB $TOKEN --no-prompt
  echo "Orb created, prepaing to publish artsy/$ORB@$DEV$VERSION"
fi


# Publish to CircleCI (when it's not a dry run)
if [ -z "$DRY_RUN" ]; then
  circleci orb publish $ORB_PATH artsy/$ORB@$DEV$VERSION $TOKEN
else
  echo "$(YELLOW "[skipped]") circleci orb publish $ORB_PATH artsy/$ORB@$DEV$VERSION"
fi


# Publish to slack (when it's neither a dry run or dev mode)
if [ -z "$DRY_RUN" ] && [ -z "$DEV" ]; then
  ./slack \
    -color "good" \
    -title "Circle CI $ORB orb v$VERSION published!" \
    -title_link "${CIRCLE_BUILD_URL:-https://circleci.com/gh/artsy/orbs/tree/master}" \
    -user_name "artsyit" \
    -icon_emoji ":crystal_ball:"

# When it's a dry run but not in dev mode
elif [ -z "$DRY_RUN" ]; then
  echo "[skipped] Post to slack: Circle CI $ORB orb v$VERSION published"
fi
