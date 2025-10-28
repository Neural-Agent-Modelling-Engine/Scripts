#!/usr/bin/env bash

BRIDGE="bridge.txt"
MARKER=">>>"

# Ensure bridge file exists
touch "$BRIDGE"

# Open the NAME app using its launcher activity
am start -n tech.bornelabs.name/io.kodular.brianxborne.NAME.Screen1 &

echo "Watching $BRIDGE for lines containing '$MARKER'…"

while true; do
  # Read entire file
  LINE=$(<"$BRIDGE")

  # Handle '>>>'
  if [[ "$LINE" == *"$MARKER"* ]]; then
    # Extract command before '>>>'
    CMD_PART=${LINE%%"$MARKER"*}
    CMD=$(echo "$CMD_PART" | xargs)

    if [[ -z "$CMD" ]]; then
      : > "$BRIDGE"
    else
      # Clear bridge immediately
      : > "$BRIDGE"

      # Export command for name.sh
      export NAME_CMD="$CMD"

      # Run name.sh (ignore output)
      if [[ -x "name.sh" ]]; then
        ./name.sh >/dev/null 2>&1
      else
        bash name.sh >/dev/null 2>&1
      fi

      # Leave bridge.txt empty no matter what
      : > "$BRIDGE"
    fi

  # Handle '>>' (execute and then stop)
  elif [[ "$LINE" == *">>"* ]]; then
    CMD_PART=${LINE%%">>"*}
    CMD=$(echo "$CMD_PART" | xargs)

    if [[ -z "$CMD" ]]; then
      : > "$BRIDGE"
      exit 1
    else
      # Clear bridge immediately
      : > "$BRIDGE"

      # Export and run
      export NAME_CMD="$CMD"

      if [[ -x "name.sh" ]]; then
        ./name.sh >/dev/null 2>&1
      else
        bash name.sh >/dev/null 2>&1
      fi

      # Leave bridge empty and stop script
      : > "$BRIDGE"
      exit 0
    fi
  fi

  sleep 1
done
