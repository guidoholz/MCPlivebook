#!/bin/bash
set -e

# Start epmd in daemon mode (required for Erlang distribution)
epmd -daemon

case "$1" in
  livebook)
    echo "Starting auto-watcher in background..."
    /usr/local/bin/watch-all.sh /data/notebooks &

    echo "Starting Livebook..."
    exec livebook server \
      --name "${LIVEBOOK_NODE:-livebook@127.0.0.1}" \
      --cookie "${LIVEBOOK_COOKIE:-secret}"
    ;;
  mcp_server)
    echo "Starting MCP server..."
    exec livebook_tools mcp_server
    ;;
  watch)
    if [ -z "$2" ]; then
      echo "Usage: docker-entrypoint.sh watch <file_path>"
      exit 1
    fi
    echo "Starting file watcher for $2..."
    exec livebook_tools watch "$2"
    ;;
  *)
    exec "$@"
    ;;
esac
