#!/bin/bash
# Create directory
# Usage: ./create_dir.sh <dir_path>

DIR_PATH="$1"

if [ -z "$DIR_PATH" ]; then
    echo "Error: Directory path is required"
    echo "Usage: $0 <dir_path>"
    exit 1
fi

if [ -d "$DIR_PATH" ]; then
    echo "Directory already exists: $DIR_PATH"
    exit 0
fi

mkdir -p "$DIR_PATH"
if [ $? -eq 0 ]; then
    echo "Directory created: $DIR_PATH"
else
    echo "Error: Failed to create directory"
    exit 1
fi
