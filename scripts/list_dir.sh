#!/bin/bash
# List directory with details
# Usage: ./list_dir.sh <dir_path>

DIR_PATH="$1"

if [ -z "$DIR_PATH" ]; then
    echo "Error: Directory path is required"
    echo "Usage: $0 <dir_path>"
    exit 1
fi

if [ ! -d "$DIR_PATH" ]; then
    echo "Error: Directory not found: $DIR_PATH"
    exit 1
fi

ls -la "$DIR_PATH"
