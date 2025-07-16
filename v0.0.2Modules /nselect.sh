#!/usr/bin/env bash
# nselect.sh — Step 5: select quant and save to config
cat <<'EOF'
 __  __           _      _     
|  \/  | ___   __| | ___| |___ 
| |\/| |/ _ \ / _` |/ _ \ / __|
| |  | | (_) | (_| |  __/ \__ \
|_|  |_|\___/ \__,_|\___|_|___/  
  
EOF

dir_name="${1:-NAME}"
base_dir="$(pwd)"
root_dir="$base_dir/$dir_name"
config_file="$root_dir/model.conf"

options=("Q2_K (~2.98 GB)" "Q4_K_M (~3.17 GB)" "Q8_0 (~3.67 GB)")
PS3="Choose model (1-3): "

echo "Select your TinyLLaMA quantization:"
select opt in "${options[@]}"; do
  case $REPLY in
    1) model="Q2_K"; url="https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q2_K.gguf"; break;;
    2) model="Q4_K_M"; url="https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf"; break;;
    3) model="Q8_0"; url="https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q8_0.gguf"; break;;
    *) echo "Invalid; try again.";;
  esac
done

echo "model=$model"    > "$config_file"
echo "url=$url"       >> "$config_file"
echo "Saved selection to $config_file"
