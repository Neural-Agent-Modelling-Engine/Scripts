#!/usr/bin/env bash

# Print ASCII art banner on startup
cat << 'EOF'

  Bornelabs SAS.6 v0.0.2
 _   _    _    __  __ _____ 
| \ | |  / \  |  \/  | ____|
|  \| | / _ \ | |\/| |  _|  
| |\  |/ ___ \| |  | | |___ 
|_| \_/_/   \_\_|  |_|_____|

         Running...
        
EOF

# 1. Resolve base directory (AI folder)
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
BRIDGE="$BASE_DIR/bridge.txt"
LOG="$BASE_DIR/bridge.log"

# 2. Paths to llama build and binary
BUILD_DIR="$BASE_DIR/llama.cpp/build"
LLAMA_BIN="$BUILD_DIR/bin/llama-cli"

# 3. Automatically discover a valid .gguf model (excluding vocab-only files)
LLAMA_MODEL=$(find "$BUILD_DIR/../models" -maxdepth 1 -type f -name "*.gguf" \
                 ! -name "ggml-vocab-*.gguf" | head -n 1)

# Detect max context size automatically, or default to 512
MODEL_INFO=$("$LLAMA_BIN" -m "$LLAMA_MODEL" --info 2>/dev/null)
MAX_TOKENS=$(echo "$MODEL_INFO" | grep -i 'context length' | grep -o '[0-9]\+')
[[ -z "$MAX_TOKENS" ]] && MAX_TOKENS=5000

LLAMA_OPTS="-n $MAX_TOKENS -st"

# 4. Marker and temp variables
MARKER=">>>"
LAST_HASH=""

# 5. Ensure existence of bridge and log files; log startup
touch "$BRIDGE" "$LOG"
echo "--- $(date) Starting watcher in $BASE_DIR ---" >> "$LOG"

# 6. Check that a model was found and is valid
if [[ -z "$LLAMA_MODEL" || ! -f "$LLAMA_MODEL" ]]; then
  echo "Error: No valid GGUF model found in models directory." > "$BRIDGE"
  echo "$(date) ERROR: No valid GGUF model found (LLAMA_MODEL=$LLAMA_MODEL)" >> "$LOG"
  exit 1
fi

echo "$(date) Using model: $LLAMA_MODEL" >> "$LOG"

# 7. Launch the NAME app on startup
echo "$(date) Launching NAME app..." >> "$LOG"
am start -n tech.bornelabs.name/io.kodular.brianxborne.NAME.Screen1 &

# 8. Main watcher loop
while true; do
  CURRENT_HASH=$(md5sum "$BRIDGE" | awk '{print $1}')
  [[ "$CURRENT_HASH" == "$LAST_HASH" ]] && { sleep 1; continue; }
  LAST_HASH="$CURRENT_HASH"

  LINE=$(<"$BRIDGE")
  echo "$(date) READ: [$LINE]" >> "$LOG"

  if [[ "$LINE" == *"$MARKER"* ]]; then
    PROMPT="${LINE%%$MARKER*}"
    PROMPT=$(echo "$PROMPT" | xargs)
    echo "$(date) PROMPT: [$PROMPT]" >> "$LOG"

    if [[ -z "$PROMPT" ]]; then
      echo "Error: empty prompt" > "$BRIDGE"
      echo "$(date) ERROR: empty prompt" >> "$LOG"
    else
      FULL_CMD="$LLAMA_BIN -m \"$LLAMA_MODEL\" -p \"$PROMPT\" $LLAMA_OPTS"
      echo "$(date) CMD: $FULL_CMD" >> "$LOG"

      RAW_OUT=$(eval "$FULL_CMD" 2>&1)
      echo "$(date) RAW_OUT_START" >> "$LOG"
      echo "$RAW_OUT" >> "$LOG"
      echo "$(date) RAW_OUT_END" >> "$LOG"

      TMP=${RAW_OUT##*'<|assistant|>'}
      TMP=${TMP%%llama_perf*}
      TMP=${TMP%%system_info*}
      TMP=${TMP%%'[end of text]'*}
      TMP=${TMP%%'<|user|>'*}
      TMP=$(echo "$TMP" | sed '/^[[:space:]]*$/d')
      RESPONSE=$(echo "$TMP" | sed -e 's/^[[:space:]]*//;s/[[:space:]]*$//')
      echo "$(date) RESPONSE: [$RESPONSE]" >> "$LOG"

      if [[ -z "$RESPONSE" ]]; then
        echo "Error: no response" > "$BRIDGE"
        echo "$(date) ERROR: no response" >> "$LOG"
      else
        echo "$RESPONSE" > "$BRIDGE"
        echo "$(date) WROTE RESPONSE to bridge.txt" >> "$LOG"
      fi
    fi
  fi

  sleep 1
done
