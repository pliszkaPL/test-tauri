#!/bin/bash
# Load JSON config from path
# Usage: ./load_config.sh <config_path>

CONFIG_PATH="$1"

if [ -z "$CONFIG_PATH" ]; then
    echo "Error: Config path is required"
    echo "Usage: $0 <config_path>"
    exit 1
fi

if [ ! -f "$CONFIG_PATH" ]; then
    echo "Error: Config file not found: $CONFIG_PATH"
    exit 1
fi

# Validate JSON
if ! jq empty "$CONFIG_PATH" 2>/dev/null; then
    echo "Error: Invalid JSON in config file"
    exit 1
fi

# Output the JSON content
cat "$CONFIG_PATH"
