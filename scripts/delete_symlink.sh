#!/bin/bash
# Delete symlink
# Usage: ./delete_symlink.sh <symlink_path>

SYMLINK_PATH="$1"

if [ -z "$SYMLINK_PATH" ]; then
    echo "Error: Symlink path is required"
    echo "Usage: $0 <symlink_path>"
    exit 1
fi

if [ ! -L "$SYMLINK_PATH" ]; then
    echo "Error: Path is not a symlink: $SYMLINK_PATH"
    exit 1
fi

rm "$SYMLINK_PATH"
if [ $? -eq 0 ]; then
    echo "Symlink deleted: $SYMLINK_PATH"
else
    echo "Error: Failed to delete symlink"
    exit 1
fi
