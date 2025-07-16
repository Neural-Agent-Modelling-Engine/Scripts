#!/usr/bin/env bash
# nsetup.sh — Step 1: create directories with ASCII banner

# Display TinyLLaMA banner
cat <<'EOF'
 ___           _        _ _ _             
|_ _|_ __  ___| |_ __ _| | (_)_ __   __ _ 
 | || '_ \/ __| __/ _` | | | | '_ \ / _` |
 | || | | \__ \ || (_| | | | | | | | (_| |
|___|_| |_|___/\__\__,_|_|_|_|_| |_|\__, |
                                    |___/ 
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
