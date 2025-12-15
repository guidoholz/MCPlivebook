#!/bin/bash
# Watch a livebook file for changes and sync to Livebook in Docker
# Usage: ./watch-docker.sh <file_path>

if [ -z "$1" ]; then
  echo "Usage: $0 <file_path_in_container>"
  echo "Example: $0 /data/notebooks/bjoern.livemd"
  exit 1
fi

exec docker exec -i livebook livebook_tools watch "$1"
