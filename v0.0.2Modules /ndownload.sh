#!/usr/bin/env bash
# ndownload.sh — Step 6: download model

dir_name="${1:-NAME}"
base_dir="$(pwd)"
root_dir="$base_dir/$dir_name"
models_dir="$root_dir/llama.cpp/models"
config_file="$root_dir/model.conf"

if [ ! -f "$config_file" ]; then
  echo "ERROR: no config found—run nselect.sh first." >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$config_file"

echo "Downloading TinyLLaMA model $model into $models_dir"
cd "$models_dir" || exit
aria2c -c "$url" -o "tinyllama-$model.gguf"

echo "Model download complete."
