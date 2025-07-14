#!/usr/bin/env bash

# TinyLLaMA Setup Script (ARMv7-Fallback)
# Usage: ./name_setup.sh [target_directory]
# Creates a folder (default "NAME"), installs deps, builds llama.cpp without FP16 intrinsics,
# downloads quantized model, fetches additional scripts, and summarizes.

set -euo pipefail

# Configuration
dir_name="${1:-NAME}"
base_dir="$(pwd)"
root_dir="$base_dir/$dir_name"
llama_dir="$root_dir/llama.cpp"
models_dir="$llama_dir/models"
i=1

echo "Step $i: Creating target directory at $root_dir"
mkdir -p "$models_dir"
((i++))

echo "Step $i: Installing dependencies"
deps=(clang cmake git automake patchelf libexpat openssl libandroid-execinfo ninja protobuf libsodium make wget unzip aria2)
for pkg in "${deps[@]}"; do
  echo -n " - Checking $pkg... "
  if ! command -v "$pkg" &>/dev/null; then
    echo "not found. Installing via Termux..."
    pkg update -y && pkg install -y "$pkg"
  else
    echo "already installed"
  fi
done
((i++))

echo "Step $i: Cloning latest llama.cpp into $llama_dir"
if [ -d "$llama_dir" ]; then
  echo "   Removing previous installation"
  rm -rf "$llama_dir"
fi
git clone --depth 1 https://github.com/ggerganov/llama.cpp.git "$llama_dir"
((i++))

echo "Step $i: Applying ARMv7-friendly patch (remove sgemm)"
# Remove unsupported sgemm.cpp from build
sed -i '/sgemm.cpp/d' "$llama_dir"/ggml/src/ggml-cpu/CMakeLists.txt
((i++))

echo "Step $i: Building llama.cpp (no FP16 intrinsics)"
cd "$llama_dir"
mkdir -p build && cd build
# Use vanilla ARMv7 without neon-fp16
export CFLAGS="-march=armv7-a"
export CXXFLAGS="-march=armv7-a"
cmake .. -DLLAMA_CURL=OFF -DLLAMA_F16C=OFF
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
cd "$models_dir"
if command -v aria2c &>/dev/null; then
  aria2c -c "$url" -o "tinyllama-$model.gguf"
else
  echo "aria2c not found, falling back to wget"
  wget "$url" -O "tinyllama-$model.gguf"
fi
((i++))

echo "Step $i: Fetching additional scripts"
cd "$root_dir"
wget -O bridge.log https://raw.githubusercontent.com/Neural-Agent-Modelling-Engine/Scripts/main/v0.0.2/bridge.log
wget -O name.sh   https://raw.githubusercontent.com/Neural-Agent-Modelling-Engine/Scripts/main/v0.0.2/name.sh
((i++))

echo "Step $i: Setup complete"
echo -e "\nSummary:\nDirectory: $root_dir\nBuild: $llama_dir/build\nModel: $models_dir/tinyllama-$model.gguf\nScripts: $root_dir/bridge.log, $root_dir/name.sh\n"
