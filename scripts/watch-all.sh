#!/bin/bash
# Watch all .livemd files in the notebooks directory
# Watchers start when files are opened in Livebook

NOTEBOOKS_DIR="${1:-/data/notebooks}"

echo "Auto-watcher: Waiting for Livebook to start..."
sleep 10

echo "Auto-watcher: Monitoring $NOTEBOOKS_DIR for .livemd files..."
echo "Auto-watcher: Watchers will connect when files are opened in Livebook"

# Track which files we're watching
declare -A WATCHING

try_start_watcher() {
    local file="$1"
    # Try to start watcher, suppress error output
    livebook_tools watch "$file" 2>/dev/null &
    local pid=$!
    sleep 2
    # Check if the process is still running (connected successfully)
    if kill -0 $pid 2>/dev/null; then
        echo "Auto-watcher: Connected to $file"
        WATCHING[$file]=$pid
        return 0
    else
        return 1
    fi
}

# Continuously check for files that need watching
while true; do
    for file in "$NOTEBOOKS_DIR"/*.livemd; do
        if [[ -f "$file" ]]; then
            # Skip if already watching
            if [[ -n "${WATCHING[$file]}" ]]; then
                # Verify watcher is still running
                if ! kill -0 "${WATCHING[$file]}" 2>/dev/null; then
                    unset WATCHING[$file]
                fi
            fi

            # Try to start watcher if not watching
            if [[ -z "${WATCHING[$file]}" ]]; then
                try_start_watcher "$file"
            fi
        fi
    done
    sleep 5
done
