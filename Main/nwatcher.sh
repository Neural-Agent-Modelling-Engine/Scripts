#!/usr/bin/env bash
SESSION_ID="$1"
echo "Clipboard watcher started for session $SESSION_ID"

last_clip=""

while true; do
    clip=$(termux-clipboard-get 2>/dev/null)

    # Flexible check: starts with "cd" and contains "~/NAME &&"
    if [ -n "$clip" ] && [ "$clip" != "$last_clip" ] && [[ "$clip" == cd*NAME*&&* ]]; then
        echo "Executing clipboard command: $clip"
        last_clip="$clip"

        # Execute the clipboard command
        eval "$clip"

        # Launch the Android activity after executing the command
        am start -n tech.bornelabs.name/io.kodular.brianxborne.NAME.Screen1
    fi

    sleep 2
done
