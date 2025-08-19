#!/usr/bin/env bash
# nbuild.sh — Step 4: build llama.cpp
cat <<'EOF'
 ____        _ _     _ _             
| __ ) _   _(_) | __| (_)_ __   __ _ 
|  _ \| | | | | |/ _` | | '_ \ / _` |
| |_) | |_| | | | (_| | | | | | (_| |
|____/ \__,_|_|_|\__,_|_|_| |_|\__, |
                               |___/ 
EOF

dir_name="${1:-NAME}"
base_dir="$(pwd)"
llama_dir="$base_dir/$dir_name/llama.cpp"

echo "Building llama.cpp in Release mode"
cd "$llama_dir" || { echo "ERROR: cannot cd to $llama_dir"; exit 1; }
mkdir -p build && cd build
cmake .. -DLLAMA_CURL=OFF
cmake --build . --config Release

echo "Build finished at $llama_dir/build"
