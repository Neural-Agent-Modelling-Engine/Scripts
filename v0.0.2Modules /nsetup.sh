#!/usr/bin/env bash
# nsetup.sh — Step 1: create directories with ASCII banner

# Display TinyLLaMA banner
cat <<'EOF'
 __
_(\    |@@|
(__/\__ \--/ __
   \___|----|  |   __
       \ }{ /\ )_ / _\
       /\__/\ \__O ( (__
      (--/\--)    \__/
      _)(  )(_
     `---''---`
EOF

# Determine project directory

# Accept optional target directory arg, default to "NAME"
dir_name="${1:-NAME}"
base_dir="$(pwd)"
root_dir="$base_dir/$dir_name"
models_dir="$root_dir/llama.cpp/models"

# Create folders
echo "Creating target directory at $root_dir"
mkdir -p "$models_dir"
echo "Done."
