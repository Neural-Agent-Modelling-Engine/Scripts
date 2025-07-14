#!/usr/bin/env bash

BRIDGE="bridge.txt"
MARKER=">>>"

# ensure bridge file exists
touch "$BRIDGE"

echo "Watching $BRIDGE for lines containing '$MARKER'…"

while true; do
  # read the entire file (we expect a single line when you write a new command)
  LINE=$(<"$BRIDGE")

  # if the line contains the marker...
  if [[ "$LINE" == *"$MARKER"* ]]; then
    # extract everything before the first occurrence of the marker
    CMD_PART=${LINE%%"$MARKER"*}
    # trim leading/trailing whitespace
    CMD=$(echo "$CMD_PART" | xargs)

    if [[ -z "$CMD" ]]; then
      printf "Error: empty command\n" > "$BRIDGE"
    else
      # execute and capture both stdout+stderr
      OUT=$(eval "$CMD" 2>&1)
      # overwrite bridge.txt with only the output
      printf "%s\n" "$OUT" > "$BRIDGE"
    fi
  fi

  sleep 1
done

