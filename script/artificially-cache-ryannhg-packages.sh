#!/usr/bin/env bash
set -euo pipefail

target_directory=~/.elm/0.19.1/packages

echo "Checking ryannhg/** packages are cached..."
if [ -d "$target_directory/ryannhg" ]; then
  echo " ryannhg packages are already cached."
  exit 0
else
  echo " ryannhg packages are not cached. Injecting..."
  mkdir -p $target_directory
  tar -xzvf "$(dirname $0)/ryannhg.tar.gz" -C "$target_directory/"
  echo " ryannhg packages are now cached."
fi
