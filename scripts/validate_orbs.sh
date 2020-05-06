#!/bin/bash
set -euo pipefail

# shellcheck disable=SC2045
for orb in $(ls ./src); do
  ./scripts/validate_orb.sh "$orb"
done
