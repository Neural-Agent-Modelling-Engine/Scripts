#!/data/data/com.termux/files/usr/bin/bash
# nwatcher.sh — Clipboard auto-executor for Termux
# Requires: termux-api

LAST=""

echo "Clipboard watcher started. Auto-executing new clipboard content..."
echo "Press Ctrl+C to stop."

while true; do
    CLIP=$(termux-clipboard-get 2>/dev/null)

    if [ -n "$CLIP" ] && [ "$CLIP" != "$LAST" ]; then
        echo "Running clipboard command: $CLIP"
        eval "$CLIP"
        LAST="$CLIP"
    fi

    sleep 2
done
