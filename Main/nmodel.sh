#!/usr/bin/env bash
set -euo pipefail

# nmodel.sh — automatic model switcher (single-arg), archive instead of delete
# Usage: ./nmodel.sh tinyllama-1.1b-chat-v1.0.Q8_0

# ---------- 1) Parse & validate input ----------
if [ "${1:-}" = "" ] || [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  cat <<EOF
Usage: $0 <full-model-name>
Example:
  $0 tinyllama-1.1b-chat-v1.0.Q8_0
Notes:
  - Provide the FULL model name (optionally with .gguf), e.g. tinyllama-1.1b-chat-v1.0.Q8_0
  - Script uses the current directory as the project root.
EOF
  exit 0
fi

model_arg="$1"

# strip optional .gguf
if [[ "$model_arg" == *.gguf ]]; then
  model_arg="${model_arg%.gguf}"
fi

# enforce full TinyLLaMA name to keep URL formation correct
if [[ "$model_arg" != tinyllama-* ]]; then
  echo "ERROR: supply the full TinyLLaMA model name, e.g. tinyllama-1.1b-chat-v1.0.Q8_0" >&2
  exit 1
fi

# ---------- 2) Paths & constants ----------
root_dir="$(pwd)"                                  # project root = current dir
models_dir="$root_dir/llama.cpp/models"
archive_dir="$models_dir/archive"
config_file="$root_dir/model.conf"
model_txt="$root_dir/model.txt"

mkdir -p "$models_dir" "$archive_dir"

full_model_name="$model_arg"
filename="${full_model_name}.gguf"
suffix="${full_model_name##*.}"
url="https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/${filename}"

echo "Project root: $root_dir"
echo "Models dir:   $models_dir"
echo "Archive dir:  $archive_dir"
echo "Target model: $full_model_name"
echo "Remote file:  $filename"
echo

# ---------- 3) Helpers ----------
# Archive any files that START with the given model name into archive/<model_name>/
safe_archive_model() {
  local model_name="$1"                       # e.g. tinyllama-1.1b-chat-v1.0.Q8_0
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

# Move all files from archive/<model_name>/ back into models_dir.
# If a file exists, move the conflicting existing file into a timestamped backup folder.
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

  # remove archive subdir if now empty
  rmdir --ignore-fail-on-non-empty "$src" 2>/dev/null || true
}

write_config_and_note() {
  cat > "$config_file" <<EOF
model=$suffix
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

# ---------- 4) Detect current model (if any) ----------
current_model=""
if [ -f "$model_txt" ]; then
  # single line, no trailing newline
  current_model="$(<"$model_txt")"
  current_model="${current_model%%$'\n'*}"
fi

# If the current model is already the target and the file is present, just ensure config is correct.
if [ "$current_model" = "$full_model_name" ] && [ -e "$models_dir/$filename" ]; then
  echo "Current model already set to $current_model and file present. Refreshing config..."
  write_config_and_note
  exit 0
fi

# ---------- 5) Main logic: present in models? archived? else download ----------
if [ -e "$models_dir/$filename" ]; then
  echo "Target model exists in models directory."
  # Archive current model first (if it differs and exists)
  if [ -n "$current_model" ] && [ "$current_model" != "$full_model_name" ]; then
    echo "Archiving current model: $current_model"
    safe_archive_model "$current_model"
  fi
  write_config_and_note
  exit 0
fi

if [ -d "$archive_dir/$full_model_name" ]; then
  echo "Target model found in archive. Restoring..."
  # Archive current model (if any and different)
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
