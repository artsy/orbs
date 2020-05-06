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

check_for_namespace

# Grab the current git branch
BRANCH=$(git branch | grep "\*" | cut -d ' ' -f2)
ORB="$1"
IS_CHANGED=$(is_orb_changed "$ORB")

if [ "$BRANCH" != "master" ] && [ -z "$IS_CHANGED" ]; then
  echo "$(YELLOW "[skipped]") Publish for $NAMESPACE/$ORB because there are no changes"
  exit 0
fi

echo ""
echo "----- Begin publish of $NAMESPACE/$1 orb -----"
echo ""

# Make sure used variables are defined
DRY_RUN=${DRY_RUN:-""}
CI=${CI:-""}
CIRCLE_PULL_REQUEST=${CIRCLE_PULL_REQUEST:-""}
CIRCLE_SHA1=${CIRCLE_SHA1:-$(git rev-parse HEAD)}
SLACK_WEBHOOK_URL=${SLACK_WEBHOOK_URL:-""}

# Set a dry-run mode
if [ -n "$DRY_RUN" ] || [ -z "$CI" ]; then
  DRY_RUN="true"
  echo "$(YELLOW "[Running in dry-run mode]")"
else
  DRY_RUN=""
fi

# Build CircleCI token argument
TOKEN=""
if [ -n "${CIRCLECI_API_KEY:-}" ]; then
  TOKEN="--token $CIRCLECI_API_KEY"
elif [ -z "$DRY_RUN" ]; then
  echo "$(RED "Must provide CIRCLECI_API_KEY env var")"
  echo ""
  exit 1
fi

# Build the dev version prefix. When not on the master branch this will be
# used to publish a dev version of the orb. That can be pulled in using
# $NAMESPACE/<orb-name>@dev:<version>. This is useful for testing purposes.
#
# This will be referred to as "dev mode" in later comments
DEV=""
VERSION_POSTFIX=""
if [ "$BRANCH" != "master" ]; then
  DEV="dev:"
  echo "$(YELLOW "[Running in dev mode]")"

  # Build the version postfix which should be unique per branch
  VERSION_POSTFIX="$(echo "$BRANCH" | md5sum | awk '{ print $1 }')"
  VERSION_POSTFIX="$VERSION_POSTFIX"
fi

# When in dev mode
if [ -n "$DEV" ]; then
  echo ""
  echo "This will be a dev deployment (prefixed with dev:)"
fi

ORB_PATH=$(get_orb_path "$ORB")
VERSION=$(get_orb_version "$ORB")
IS_PUBLISHED=$(is_orb_published "$ORB")
IS_CREATED=$(is_orb_created "$ORB")

# Ensure the orb is valid
circleci orb validate "$ORB_PATH"

if [ -n "$DEV" ]; then
  FULL_VERSION="$DEV$VERSION_POSTFIX"
else
  FULL_VERSION="$VERSION"
fi

# If the orb has been previously published (i.e. it already exists in circle's registry)
if [ -n "$IS_PUBLISHED" ]; then

  LAST_PUBLISHED=$(get_published_orb_version "$ORB")

  case $(compare_version "$VERSION" "$LAST_PUBLISHED") in
  "=")
    # When not in dev mode
    if [ -z "$DEV" ]; then
      echo "$NAMESPACE/$ORB@$VERSION is the latest, skipping publish"
      exit 0
    fi
    ;;
  "<")
    echo "$(RED "$NAMESPACE/$ORB@$LAST_PUBLISHED is the latest, cannot publish older version $VERSION")"
    echo "$(RED "Please update $ORB_PATH to have a version greater than $LAST_PUBLISHED")"
    exit 1
    ;;
  ">")
    # when not in dev mode
    if [ -z "$DEV" ]; then
      echo "Preparing to bump $NAMESPACE/$ORB from $LAST_PUBLISHED to $VERSION"
    fi
    ;;
  *)
    echo "$(RED "Version comparison for $NAMESPACE/$ORB failed.")"
    echo "$(RED "Current version: $VERSION")"
    echo "$(RED "Published version: $LAST_PUBLISHED")"
    exit 1
    ;;
  esac

elif [ -z "$IS_CREATED" ]; then
  echo "Orb $NAMESPACE/$ORB isn't in the registry. Creating its registry entry..."
  circleci orb create "$NAMESPACE/$ORB" $TOKEN --no-prompt
fi

# Publish to CircleCI (when it's not a dry run)
if [ -z "$DRY_RUN" ]; then
  echo "Preparing to publish dev orb $NAMESPACE/$ORB@$FULL_VERSION"
  circleci orb publish "$ORB_PATH" "$NAMESPACE/$ORB@$FULL_VERSION" "$TOKEN"
else
  echo "$(YELLOW "[skipped]") circleci orb publish $ORB_PATH $NAMESPACE/$ORB@$FULL_VERSION"
fi

# Publish to slack (when it's neither a dry run or dev mode)
if [ -z "$DRY_RUN" ] && [ -z "$DEV" ] && [ -n "$SLACK_WEBHOOK_URL" ]; then
  ./slack \
    -color "good" \
    -title "Circle CI $ORB orb v$VERSION published!" \
    -title_link "${CIRCLE_BUILD_URL:-https://circleci.com/gh/$NAMESPACE/orbs/tree/master}" \
    -user_name "artsyit" \
    -icon_emoji ":crystal_ball:"

elif [ -z "$SLACK_WEBHOOK_URL" ]; then
  echo "$(YELLOW "[skipped]") Post to slack: No SLACK_WEBHOOK_URL environment variable set"

# When it's a dry run but not in dev mode
elif [ -z "$DRY_RUN" ]; then
  echo "$(YELLOW "[skipped]") Post to slack: Circle CI $ORB orb v$VERSION published"
fi

echo ""
echo "----- End publish of $NAMESPACE/$1 orb -----"
echo ""
