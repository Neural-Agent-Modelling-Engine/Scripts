#!/usr/bin/env bash
# ndownload.sh — Step 6: download model

cat <<'EOF'
 ____                      _                 _ _             
|  _ \  _____      ___ __ | | ___   __ _  __| (_)_ __   __ _ 
| | | |/ _ \ \ /\ / / '_ \| |/ _ \ / _` |/ _` | | '_ \ / _` |
| |_| | (_) \ V  V /| | | | | (_) | (_| | (_| | | | | | (_| |
|____/ \___/ \_/\_/ |_| |_|_|\___/ \__,_|\__,_|_|_| |_|\__, |
                                                       |___/  
EOF

dir_name="${1:-NAME}"
base_dir="$(pwd)"
root_dir="$base_dir/$dir_name"
models_dir="$root_dir/llama.cpp/models"
config_file="$root_dir/model.conf"

if [ ! -f "$config_file" ]; then
  echo "ERROR: no config found—run nselect.sh first." >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$config_file"

echo "Downloading TinyLLaMA model $model into $models_dir"
cd "$models_dir" || exit 1

filename="tinyllama-$model.gguf"

# Try aria2c, fallback to wget, then curl
if command -v aria2c >/dev/null 2>&1; then
  echo "Using aria2c..."
  aria2c -c "$url" -o "$filename" || {
    echo "aria2c failed. Trying wget..."
    if command -v wget >/dev/null 2>&1; then
      wget -O "$filename" "$url" || {
        echo "wget also failed. Trying curl..."
        if command -v curl >/dev/null 2>&1; then
          curl -L "$url" -o "$filename" || {
            echo "ERROR: All download methods failed." >&2
            exit 1
          }
        else
          echo "curl not installed. Cannot continue." >&2
          exit 1
        fi
      }
    else
      echo "wget not installed. Cannot continue." >&2
      exit 1
    fi
  }
elif command -v wget >/dev/null 2>&1; then
  echo "Using wget..."
  wget -O "$filename" "$url" || {
    echo "wget failed. Trying curl..."
    if command -v curl >/dev/null 2>&1; then
      curl -L "$url" -o "$filename" || {
        echo "ERROR: All download methods failed." >&2
        exit 1
      }
    else
      echo "curl not installed. Cannot continue." >&2
      exit 1
    fi
  }
elif command -v curl >/dev/null 2>&1; then
  echo "Using curl..."
  curl -L "$url" -o "$filename" || {
    echo "ERROR: curl failed to download the file." >&2
    exit 1
  }
else
  echo "ERROR: No downloader (aria2c, wget, or curl) is available." >&2
  exit 1
fi

echo "Model download complete."
