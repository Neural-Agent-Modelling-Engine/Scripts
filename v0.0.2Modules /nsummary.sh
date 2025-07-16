#!/usr/bin/env bash
# nsummary.sh — Step 8: final summary

dir_name="${1:-NAME}"
base_dir="$(pwd)"
root_dir="$base_dir/$dir_name"
build_dir="$root_dir/llama.cpp/build"
models_dir="$root_dir/llama.cpp/models"
config_file="$root_dir/model.conf"

# read the model name for display
if [ -f "$config_file" ]; then
  # shellcheck disable=SC1090
  source "$config_file"
else
  model="(not selected)"
fi

cat <<EOF

Setup Summary for project '$dir_name':

  • Root directory: $root_dir  
  • Built llama.cpp: $build_dir  
  • Model file:      $models_dir/tinyllama-$model.gguf  
  • Extra scripts:   $root_dir/bridge.log, $root_dir/name.sh  

EOF
