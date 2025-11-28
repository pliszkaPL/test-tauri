#!/bin/bash
# Create symlink
# Usage: ./create_symlink.sh <source> <destination>

SOURCE="$1"
DESTINATION="$2"

if [ -z "$SOURCE" ] || [ -z "$DESTINATION" ]; then
    echo "Error: Source and destination paths are required"
    echo "Usage: $0 <source> <destination>"
    exit 1
fi

if [ ! -e "$SOURCE" ]; then
    echo "Error: Source path does not exist: $SOURCE"
    exit 1
fi

# Create parent directory if it doesn't exist
PARENT_DIR=$(dirname "$DESTINATION")
if [ ! -d "$PARENT_DIR" ]; then
    mkdir -p "$PARENT_DIR"
fi

# Remove existing symlink if it exists
if [ -L "$DESTINATION" ]; then
    rm "$DESTINATION"
fi

ln -s "$SOURCE" "$DESTINATION"
if [ $? -eq 0 ]; then
    echo "Symlink created: $DESTINATION -> $SOURCE"
else
    echo "Error: Failed to create symlink"
    exit 1
fi
