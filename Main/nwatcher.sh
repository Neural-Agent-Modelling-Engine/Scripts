#!/usr/bin/env bash
SESSION_ID="$1"
echo "Clipboard watcher started for session $SESSION_ID"

last_clip=""

while true; do
    clip=$(termux-clipboard-get 2>/dev/null)

    # Only act if clipboard is not empty, has changed, and starts with cd ~/NAME && (flexible)
    if [ -n "$clip" ] && [ "$clip" != "$last_clip" ] && [[ "$clip" =~ ^cd[[:space:]]+~\/NAME[[:space:]]*&& ]]; then
        echo "Executing clipboard command: $clip"
        last_clip="$clip"

        # Execute the clipboard command
        eval "$clip"

        # Launch the Android activity after executing the command
        am start -n tech.bornelabs.name/io.kodular.brianxborne.NAME.Screen1
    fi

    sleep 2
done
