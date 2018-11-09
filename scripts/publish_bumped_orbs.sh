#!/bin/bash
set -euo pipefail

for orb in $(ls ./src); do
  ./scripts/publish_orb.sh $orb
done