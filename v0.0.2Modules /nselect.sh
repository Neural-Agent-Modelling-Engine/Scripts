#!/usr/bin/env bash
# nmodels.sh — Step 5: select quant and save to config with ASCII banner

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

echo
echo "Select your TinyLLaMA quantization:"
options=("Q2_K (~2.98 GB)" "Q4_K_M (~3.17 GB)" "Q8_0 (~3.67 GB)")

max_attempts=5
attempt=0
while true; do
  echo
  echo "1) ${options[0]}"
  echo "2) ${options[1]}"
  echo "3) ${options[2]}"
  
  # Prompt user from terminal directly
  read -r -p "Choose model (1-3): " choice < /dev/tty

  # Validate input
  if [[ "$choice" =~ ^[1-3]$ ]]; then
    model="${options[choice-1]%% *}"
    url="https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.${model}.gguf"
    break
  else
    echo "Invalid choice. Please enter 1, 2, or 3."
    ((attempt++))
    if [ "$attempt" -ge "$max_attempts" ]; then
      echo "Too many invalid attempts." >&2
      exit 1
    fi
  fi
done

# Save selection
{
  echo "model=$model"
  echo "url=$url"
} > "$config_file"

echo
echo "Saved selection to $config_file ($model)"
