#!/usr/bin/env bash
SESSION_ID="$1"

echo "Clipboard watcher started for session $SESSION_ID"

last_clip=""

while true; do
    clip=$(termux-clipboard-get 2>/dev/null)

    # Only act if clipboard is not empty and has changed
    if [ -n "$clip" ] && [ "$clip" != "$last_clip" ]; then
        echo "Clipboard: $clip"
        last_clip="$clip"

        # Execute the command and show its output
        eval "$clip"
    fi

    sleep 2
done
