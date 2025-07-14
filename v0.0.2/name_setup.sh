#!/usr/bin/env bash

# TinyLLaMA Setup Script (Fixed & Updated)
# Usage: ./name_setup.sh [target_directory]
# Creates a folder (default "NAME"), installs deps, builds llama.cpp,
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
 deps=(build-essential cmake git automake patchelf libexpat openssl libandroid-execinfo ninja protobuf libsodium clang make wget unzip)
 for pkg in "${deps[@]}"; do
   echo -n " - Checking $pkg... "
   if ! command -v "$pkg" &>/dev/null; then
     echo "not found. Installing..."
     if command -v apt-get &>/dev/null; then
       sudo apt-get update -y && sudo apt-get install -y "$pkg"
     elif command -v yum &>/dev/null; then
       sudo yum install -y "$pkg"
     elif command -v dnf &>/dev/null; then
       sudo dnf install -y "$pkg"
     elif command -v pkg &>/dev/null && [[ "$(uname -o 2>/dev/null || echo)" == *Android* ]]; then
       pkg update && pkg install "$pkg"
     else
       echo "ERROR: cannot install $pkg" >&2
       exit 1
     fi
   else
     echo "already installed"
   fi
 done

# Install aria2 (provides aria2c)
 echo -n " - Checking aria2c... "
 if ! command -v aria2c &>/dev/null; then
   echo "not found. Installing aria2..."
   if command -v apt-get &>/dev/null; then
     sudo apt-get install -y aria2
   elif command -v yum &>/dev/null; then
     sudo yum install -y aria2
   elif command -v dnf &>/dev/null; then
     sudo dnf install -y aria2
   elif command -v pkg &>/dev/null && [[ "$(uname -o 2>/dev/null || echo)" == *Android* ]]; then
     pkg install aria2
   else
     echo "ERROR: cannot install aria2" >&2
     exit 1
   fi
 else
   echo "already installed"
 fi
 ((i++))

echo "Step $i: Cloning latest llama.cpp into $llama_dir"
 if [ -d "$llama_dir" ]; then
   echo "   Removing previous installation"
   rm -rf "$llama_dir"
 fi
 git clone --depth 1 https://github.com/ggerganov/llama.cpp.git "$llama_dir"
 ((i++))

# Patch: Remove custom vcvtnq_s32_f32 to avoid clash with <arm_neon.h>
impl_file="$llama_dir/ggml/src/ggml-cpu/ggml-cpu-impl.h"
echo "Removing custom vcvtnq_s32_f32 implementation to prevent redefinition"
sed -i '/inline static int32x4_t vcvtnq_s32_f32/,/^}/d' "$impl_file"
# No need for ARM rounding guard now
file="$llama_dir/ggml/src/ggml-cpu/ggml-cpu-impl.h"
 if ! grep -q '#if !defined(__ARM_NEON)' "$impl_file"; then
   echo "Guarding custom vcvtnq_s32_f32 definition against __ARM_NEON"
   # Insert guard before function
   sed -i '/inline static int32x4_t vcvtnq_s32_f32(float32x4_t v) {/i #if !defined(__ARM_NEON)' "$impl_file"
   # Close guard after the function's closing brace
   sed -i '/inline static int32x4_t vcvtnq_s32_f32(float32x4_t v) {/,/}/ s|}$|}\n#endif|' "$impl_file"
 fi

echo "Step $i: Building llama.cpp"
 cd "$llama_dir"
 mkdir -p build && cd build
 export CFLAGS="-mfpu=neon -march=armv7-a"
 export CXXFLAGS="-mfpu=neon -march=armv7-a"
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
