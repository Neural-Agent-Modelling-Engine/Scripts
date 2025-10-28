#!/usr/bin/env bash

BRIDGE="bridge.txt"
MARKER=">>>"

# Ensure bridge file exists
touch "$BRIDGE"

# Open the NAME app using its launcher activity
am start -n tech.bornelabs.name/io.kodular.brianxborne.NAME.Screen1 &

echo "Watching $BRIDGE for lines containing '$MARKER'…"

while true; do
  # Read the entire file (expecting a single line when a new command is written)
  LINE=$(<"$BRIDGE")

  # If the line contains the type 1 marker...
  if [[ "$LINE" == *"$MARKER"* ]]; then
    # Extract everything before the first occurrence of the marker
    CMD_PART=${LINE%%"$MARKER"*}
    # Trim leading/trailing whitespace
    CMD=$(echo "$CMD_PART" | xargs)

    if [[ -z "$CMD" ]]; then
      printf "Error: empty command\n" > "$BRIDGE"
    else
      # Execute and capture both stdout+stderr
      OUT=$(eval "$CMD" 2>&1)
      # Overwrite bridge.txt with only the output
      printf "%s\n" "$OUT" > "$BRIDGE"
    fi

  # If the line contains the type 2 marker '>>'
  elif [[ "$LINE" == *">>"* ]]; then
    # Extract everything before the first occurrence of '>>'
    CMD_PART=${LINE%%">>"*}
    # Trim leading/trailing whitespace
    CMD=$(echo "$CMD_PART" | xargs)

    if [[ -n "$CMD" ]]; then
      # Clear bridge.txt immediately
      : > "$BRIDGE"
      # Execute command silently (output discarded)
      eval "$CMD" >/dev/null 2>&1
      # Ensure bridge.txt stays empty
      : > "$BRIDGE"
    else
      # Empty command — clear bridge.txt
      : > "$BRIDGE"
    fi
  fi

  sleep 1
done
