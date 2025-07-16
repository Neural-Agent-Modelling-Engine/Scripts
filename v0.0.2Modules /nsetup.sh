#!/usr/bin/env bash
# nsetup.sh — Step 1: create directories

dir_name="${1:-NAME}"
base_dir="$(pwd)"
root_dir="$base_dir/$dir_name"
models_dir="$root_dir/llama.cpp/models"

echo "Creating target directory at $root_dir"
mkdir -p "$models_dir"
echo "Done."
