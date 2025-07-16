#!/usr/bin/env bash
# nmodels.sh — Step 5: select quant and save to config with ASCII banner

# ASCII Title
cat <<'EOF'
 __  __           _      _
|  \/  | ___   __| | ___| |___
| |\/| |/ _ \\ / _\` |/ _ \\ / __|
| |  | | (_) | (_| |  __/ \\__ \\
|_|  |_|\\___/ \\__,_|\\___|_|___/
EOF

# Configuration
dir_name="${1:-NAME}"
base_dir="$(pwd)"
root_dir="$base_dir/$dir_name"
config_file="$root_dir/model.conf"

# Ensure project root exists
mkdir -p "$root_dir"

echo "Select your TinyLLaMA quantization:"
options=("Q2_K (~2.98 GB)" "Q4_K_M (~3.17 GB)" "Q8_0 (~3.67 GB)")

# Prompt until valid selection; read from terminal
while true; do
  echo "1) ${options[0]}"
  echo "2) ${options[1]}"
  echo "3) ${options[2]}"
  read -r -p "Choose model (1-3): " choice

  case "$choice" in
    1)
      model="Q2_K"
      url="https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q2_K.gguf"
      break
      ;;
    2)
      model="Q4_K_M"
      url="https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf"
      break
      ;;
    3)
      model="Q8_0"
      url="https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q8_0.gguf"
      break
      ;;
    *)
      echo "Invalid choice. Please enter 1, 2, or 3."
      ;;
  esac
  echo

done

echo "model=$model" > "$config_file"
echo "url=$url"   >> "$config_file"

echo "Saved selection to $config_file ($model)"
