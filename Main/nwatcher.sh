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

        # Check if it contains 'stop &&'
        if [[ "$clip" == *"stop &&"* ]]; then
            cmd="${clip#*stop && }"
            echo "Watcher stopped."
            eval "$cmd"
            exit 0
        fi

        # Execute the clipboard command
        eval "$clip"
        echo "✓ Done"

    fi

    sleep 2
done
