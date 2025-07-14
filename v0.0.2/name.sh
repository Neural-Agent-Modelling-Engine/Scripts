#!/usr/bin/env bash

# Resolve base directory (AI folder)
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
BRIDGE="$BASE_DIR/bridge.txt"
LOG="$BASE_DIR/bridge.log"

# Paths to llama build and binary
BUILD_DIR="$BASE_DIR/llama.cpp/build"
LLAMA_BIN="$BUILD_DIR/bin/llama-cli"
LLAMA_MODEL="$BUILD_DIR/../models/tinyllama-Q6_K.gguf"
LLAMA_OPTS="-n 128 -st"
MARKER=">>>"
LAST_HASH=""

# ensure files exist
touch "$BRIDGE" "$LOG"
echo "--- $(date) Starting watcher in $BASE_DIR ---" >> "$LOG"

while true; do
  # detect file changes
  CURRENT_HASH=$(md5sum "$BRIDGE" | awk '{print $1}')
  [[ "$CURRENT_HASH" == "$LAST_HASH" ]] && { sleep 1; continue; }
  LAST_HASH="$CURRENT_HASH"

  # read new line
  LINE=$(<"$BRIDGE")
  echo "$(date) READ: [$LINE]" >> "$LOG"

  # only process if marker present
  if [[ "$LINE" == *"$MARKER" ]]; then
    PROMPT="${LINE%%$MARKER*}"
    PROMPT=$(echo "$PROMPT" | xargs)
    echo "$(date) PROMPT: [$PROMPT]" >> "$LOG"

    if [[ -z "$PROMPT" ]]; then
      echo "Error: empty prompt" > "$BRIDGE"
      echo "$(date) ERROR: empty prompt" >> "$LOG"
    else
      # form full command
      FULL_CMD="$LLAMA_BIN -m \"$LLAMA_MODEL\" -p \"$PROMPT\" $LLAMA_OPTS"
      echo "$(date) CMD: $FULL_CMD" >> "$LOG"

      # run llama-cli
      RAW_OUT=$(eval "$FULL_CMD" 2>&1)
      echo "$(date) RAW_OUT_START" >> "$LOG"
      echo "$RAW_OUT" >> "$LOG"
      echo "$(date) RAW_OUT_END" >> "$LOG"

      # refined extraction
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

