#!/usr/bin/env bash
set -euo pipefail

# nmodel.sh — automatic model switcher (supports 6 main models)
# Usage: ./nmodel.sh <model-name>
# Example: ./nmodel.sh tinyllama-1.1b-chat-v1.0.Q6_K

# ---------- 1) Parse & validate input ----------
if [ "${1:-}" = "" ] || [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  cat <<EOF
Usage: $0 <model-name>
Available models (lightweight, suitable for low-RAM systems):
  1. tinyllama-1.1b-chat-v1.0.Q6_K
     https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF
  2. Falcon3-3B-Instruct-Q4_K_M
     https://huggingface.co/bartowski/Falcon3-3B-Instruct-GGUF
  3. KobbleTinyV2-1.1B
     https://huggingface.co/concedo/KobbleTinyV2-1.1B-GGUF
  4. pygmalion-1.3b-i1
     https://huggingface.co/mradermacher/pygmalion-1.3b-i1-GGUF
  5. Curio-1.1b-i1
     https://huggingface.co/mradermacher/Curio-1.1b-i1-GGUF
  6. teenytinyllama-460m-chat
     https://huggingface.co/afrideva/TeenyTinyLlama-460m-Chat-GGUF

Notes:
  - Omit the ".gguf" extension when typing; script will append it automatically.
  - If a repo uses a different filename than the simple model key above,
    pass the exact filename (without .gguf) or edit the case block.
EOF
  exit 0
fi

model_arg="$1"
model_arg="${model_arg%.gguf}"   # strip optional .gguf
filename="${model_arg}.gguf"

# ---------- 2) Map model -> URL ----------
case "$model_arg" in
  tinyllama-1.1b-chat-v1.0.Q6_K)
    full_model_name="tinyllama-1.1b-chat-v1.0.Q6_K"
    url="https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/$filename"
    ;;
  Falcon3-3B-Instruct-Q4_K_M)
    full_model_name="Falcon3-3B-Instruct-Q4_K_M"
    url="https://huggingface.co/bartowski/Falcon3-3B-Instruct-GGUF/resolve/main/$filename"
    ;;
  KobbleTinyV2-1.1B)
    full_model_name="KobbleTinyV2-1.1B"
    url="https://huggingface.co/concedo/KobbleTinyV2-1.1B-GGUF/resolve/main/$filename"
    ;;
  pygmalion-1.3b-i1)
    full_model_name="pygmalion-1.3b-i1"
    url="https://huggingface.co/mradermacher/pygmalion-1.3b-i1-GGUF/resolve/main/$filename"
    ;;
  Curio-1.1b-i1)
    full_model_name="Curio-1.1b-i1"
    url="https://huggingface.co/mradermacher/Curio-1.1b-i1-GGUF/resolve/main/$filename"
    ;;
  teenytinyllama-460m-chat)
    full_model_name="teenytinyllama-460m-chat"
    url="https://huggingface.co/afrideva/TeenyTinyLlama-460m-Chat-GGUF/resolve/main/$filename"
    ;;
  *)
    echo "ERROR: Unsupported model: $model_arg" >&2
    echo "Run with -h for the list of supported models."
    exit 1
    ;;
esac

# ---------- 3) Paths & constants ----------
root_dir="$(pwd)"                                  # project root = current dir
models_dir="$root_dir/llama.cpp/models"
archive_dir="$models_dir/archive"
config_file="$root_dir/model.conf"
model_txt="$root_dir/model.txt"

mkdir -p "$models_dir" "$archive_dir"

echo "Project root: $root_dir"
echo "Models dir:   $models_dir"
echo "Archive dir:  $archive_dir"
echo "Target model: $full_model_name"
echo "Remote file:  $filename"
echo "Download URL: $url"
echo

# ---------- 4) Helpers ----------
safe_archive_model() {
  local model_name="$1"
  local dest="$archive_dir/$model_name"
  mkdir -p "$dest"
  shopt -s nullglob
  local moved=false
  for f in "$models_dir/${model_name}"*; do
    if [ -e "$f" ]; then
      echo "Archiving $f -> $dest/"
      mv -v -- "$f" "$dest/"
      moved=true
    fi
  done
  shopt -u nullglob
  if ! $moved; then
    echo "No files to archive for model: $model_name"
  fi
}

restore_archived_model() {
  local model_name="$1"
  local src="$archive_dir/$model_name"
  local backup="$archive_dir/onrestore-backups-$(date -u +%Y%m%dT%H%M%SZ)"
  mkdir -p "$backup"

  shopt -s nullglob
  for f in "$src/"*; do
    local fname
    fname="$(basename "$f")"
    if [ -e "$models_dir/$fname" ]; then
      echo "Conflict: $models_dir/$fname exists — moving it to $backup/"
      mv -v -- "$models_dir/$fname" "$backup/"
    fi
    mv -v -- "$f" "$models_dir/"
  done
  shopt -u nullglob

  rmdir --ignore-fail-on-non-empty "$src" 2>/dev/null || true
}

write_config_and_note() {
  cat > "$config_file" <<EOF
model=$full_model_name
url=$url
EOF
  echo "$full_model_name" > "$model_txt"
  echo "Updated $config_file and $model_txt."
}

download_model() {
  echo "Downloading $filename into $models_dir ..."
  ( cd "$models_dir"
    if command -v aria2c >/dev/null 2>&1; then
      echo "Using aria2c..."
      aria2c -c "$url" -o "$filename"
    elif command -v wget >/dev/null 2>&1; then
      echo "Using wget..."
      wget -O "$filename" "$url"
    elif command -v curl >/dev/null 2>&1; then
      echo "Using curl..."
      curl -L --fail -o "$filename" "$url"
    else
      echo "ERROR: no downloader available (aria2c, wget, or curl)." >&2
      exit 1
    fi

    if [ ! -s "$filename" ]; then
      echo "ERROR: download failed or file is empty: $models_dir/$filename" >&2
      exit 1
    fi
  )
  echo "Download successful: $models_dir/$filename"
}

# ---------- 5) Detect current model ----------
current_model=""
if [ -f "$model_txt" ]; then
  current_model="$(<"$model_txt")"
  current_model="${current_model%%$'\n'*}"
fi

if [ "$current_model" = "$full_model_name" ] && [ -e "$models_dir/$filename" ]; then
  echo "Current model already set to $current_model and file present. Refreshing config..."
  write_config_and_note
  exit 0
fi

# ---------- 6) Main logic ----------
if [ -e "$models_dir/$filename" ]; then
  echo "Target model exists in models directory."
  if [ -n "$current_model" ] && [ "$current_model" != "$full_model_name" ]; then
    echo "Archiving current model: $current_model"
    safe_archive_model "$current_model"
  fi
  write_config_and_note
  exit 0
fi

if [ -d "$archive_dir/$full_model_name" ]; then
  echo "Target model found in archive. Restoring..."
  if [ -n "$current_model" ] && [ "$current_model" != "$full_model_name" ]; then
    echo "Archiving current model: $current_model"
    safe_archive_model "$current_model"
  fi
  restore_archived_model "$full_model_name"
  write_config_and_note
  exit 0
fi

echo "Target model not found locally. Archiving current model (if any) and downloading target..."
if [ -n "$current_model" ] && [ "$current_model" != "$full_model_name" ]; then
  echo "Archiving current model: $current_model"
  safe_archive_model "$current_model"
fi

download_model
write_config_and_note
echo "Done."
