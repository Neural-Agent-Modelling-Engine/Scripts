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

  # If the line contains the marker...
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
  fi

  sleep 1
done
