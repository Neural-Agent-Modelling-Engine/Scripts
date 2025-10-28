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

  # First handle the existing marker '>>>'
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

  # New behavior: a line containing '>>' (but NOT handled above as '>>>')
  elif [[ "$LINE" == *">>"* ]]; then
    # Extract everything before the first occurrence of '>>'
    CMD_PART=${LINE%%">>"*}
    # Trim leading/trailing whitespace
    CMD=$(echo "$CMD_PART" | xargs)

    if [[ -z "$CMD" ]]; then
      # Write error and then exit the script
      printf "Error: empty command\n" > "$BRIDGE"
      exit 1
    else
      # Execute the command, capture output, write it to bridge (so caller can read),
      # then stop the script as requested.
      OUT=$(eval "$CMD" 2>&1)
      printf "%s\n" "$OUT" > "$BRIDGE"
      # Stop the script after executing the command
      exit 0
    fi
  fi

  sleep 1
done
