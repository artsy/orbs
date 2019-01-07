#!/bin/bash
set -euo pipefail

for orb in $(ls ./src); do
  ./scripts/validate_orb.sh $orb
done