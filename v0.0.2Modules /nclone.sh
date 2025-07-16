#!/usr/bin/env bash
# nclone.sh — Step 3: clone llama.cpp

dir_name="${1:-NAME}"
base_dir="$(pwd)"
root_dir="$base_dir/$dir_name"
llama_dir="$root_dir/llama.cpp"

echo "Cloning llama.cpp into $llama_dir"
if [ -d "$llama_dir" ]; then
  echo " → Removing existing directory"
  rm -rf "$llama_dir"
fi

git clone https://github.com/ggerganov/llama.cpp.git "$llama_dir"
echo "Clone complete."
