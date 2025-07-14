#!/usr/bin/env bash

# TinyLLaMA Setup Script
# Usage: ./name_setup.sh [target_directory]
# Creates a folder (default "NAME") in current dir, installs deps, builds llama.cpp,
# downloads quantized model, fetches additional scripts, and summarizes.

# Configuration
dir_name="${1:-NAME}"
base_dir="$(pwd)"
root_dir="$base_dir/$dir_name"
llama_dir="$root_dir/llama.cpp"
models_dir="$llama_dir/models"

# Step counter
i=1

echo "Step $i: Creating target directory at $root_dir"
mkdir -p "$models_dir"
((i++))

echo "Step $i: Installing dependencies"
for pkg in git cmake clang make wget unzip aria2c; do
  echo " - Checking $pkg"
  if ! command -v "$pkg" &>/dev/null; then
    echo "   Installing $pkg..."
    if command -v apt-get &>/dev/null; then
      sudo apt-get update -y && sudo apt-get install -y "$pkg"
    elif command -v yum &>/dev/null; then
      sudo yum install -y "$pkg"
    elif command -v dnf &>/dev/null; then
      sudo dnf install -y "$pkg"
    elif command -v pkg &>/dev/null; then
      pkg update && pkg install "$pkg"
    else
      echo "   ERROR: cannot install $pkg" >&2
      exit 1
    fi
  else
    echo "   $pkg already installed"
  fi
done
((i++))

echo "Step $i: Cloning llama.cpp into $llama_dir"
if [ -d "$llama_dir" ]; then
  echo "   Removing previous installation of llama.cpp"
  rm -rf "$llama_dir"
fi

# Clone fresh copy
git clone https://github.com/ggerganov/llama.cpp.git "$llama_dir"
((i++))

echo "Step $i: Building llama.cpp"
cd "$llama_dir" || exit
mkdir -p build && cd build || exit
cmake .. -DLLAMA_CURL=OFF
cmake --build . --config Release
((i++))

echo "Step $i: Select your model"
options=("Q2_K (~2.98 GB)" "Q4_K_M (~3.17 GB)" "Q8_0 (~3.67 GB)")
PS3="Choose model (1-3): "
select opt in "${options[@]}"; do
  case $REPLY in
    1) model="Q2_K"; url="https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q2_K.gguf"; break;;
    2) model="Q4_K_M"; url="https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf"; break;;
    3) model="Q8_0"; url="https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q8_0.gguf"; break;;
    *) echo "Invalid choice";;
  esac
done
((i++))

echo "Step $i: Downloading model $model"
cd "$models_dir" || exit
aria2c -c "$url" -o "tinyllama-$model.gguf"
((i++))

echo "Step $i: Fetching additional scripts"
cd "$root_dir" || exit
wget -O bridge.log https://raw.githubusercontent.com/Neural-Agent-Modelling-Engine/Scripts/main/v0.0.2/bridge.log
wget -O name.sh   https://raw.githubusercontent.com/Neural-Agent-Modelling-Engine/Scripts/main/v0.0.2/name.sh
((i++))

echo "Step $i: Setup complete"
echo -e "\nSummary:
Directory: $root_dir
Build: $llama_dir/build
Model: $models_dir/tinyllama-$model.gguf
Scripts: $root_dir/bridge.log, $root_dir/name.sh
"

