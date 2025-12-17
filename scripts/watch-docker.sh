#!/bin/bash
# Watch a livebook file for changes and sync to Livebook in Docker
# Usage: ./watch-docker.sh <file_path>

exec docker exec -i livebook livebook_tools watch "$1"
