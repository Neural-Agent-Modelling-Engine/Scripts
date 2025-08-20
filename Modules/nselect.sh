#!/usr/bin/env bash
# nmodels.sh — automatically select tinyllama-1.1b-chat-v1.0.Q6_K and save to config

# ASCII Title
cat <<'EOF'
 __  __           _      _
|  \/  | ___   __| | ___| |___
| |\/| |/ _ \ / _` |/ _ \ / __|
| |  | | (_) | (_| |  __/ \__ \
|_|  |_|\___/ \__,_|\___|_|___/
EOF

# Configuration
dir_name="${1:-NAME}"
base_dir="$(pwd)"
root_dir="$base_dir/$dir_name"
config_file="$root_dir/model.conf"

# Ensure project root exists
mkdir -p "$root_dir"

# Automatically select the model
model="Q6_K"
full_model_name="tinyllama-1.1b-chat-v1.0.$model"
url="https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/${full_model_name}.gguf"

# Save selection to config
{
  echo "model=$full_model_name"
  echo "url=$url"
} > "$config_file"

echo
echo "Automatically selected model: $full_model_name"
echo "Saved configuration to $config_file"
