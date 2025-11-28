#!/bin/bash
# Process project links from JSON config
# Usage: ./process_links.sh <config_path>

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

# Get project name and version
PROJECT_NAME=$(jq -r '.name' "$CONFIG_PATH")
PROJECT_VERSION=$(jq -r '.version' "$CONFIG_PATH")

echo "Processing project: $PROJECT_NAME (v$PROJECT_VERSION)"
echo "----------------------------------------"

# Process each link
LINKS_COUNT=$(jq '.links | length' "$CONFIG_PATH")

for i in $(seq 0 $((LINKS_COUNT - 1))); do
    SOURCE=$(jq -r ".links[$i].source" "$CONFIG_PATH")
    DESTINATION=$(jq -r ".links[$i].destination" "$CONFIG_PATH")
    REQUIRED=$(jq -r ".links[$i].required" "$CONFIG_PATH")
    
    # Replace {version} placeholder in destination
    DESTINATION=$(echo "$DESTINATION" | sed "s/{version}/$PROJECT_VERSION/g")
    
    echo "Creating link: $DESTINATION -> $SOURCE"
    
    # Check if source exists
    if [ ! -e "$SOURCE" ]; then
        if [ "$REQUIRED" = "true" ]; then
            echo "Error: Required source does not exist: $SOURCE"
            exit 1
        else
            echo "Warning: Optional source does not exist: $SOURCE"
            continue
        fi
    fi
    
    # Create parent directory
    PARENT_DIR=$(dirname "$DESTINATION")
    mkdir -p "$PARENT_DIR"
    
    # Remove existing symlink
    if [ -L "$DESTINATION" ]; then
        rm "$DESTINATION"
    fi
    
    # Create symlink
    ln -s "$(realpath "$SOURCE")" "$DESTINATION"
    if [ $? -eq 0 ]; then
        echo "  ✓ Success"
    else
        if [ "$REQUIRED" = "true" ]; then
            echo "  ✗ Failed to create required link"
            exit 1
        else
            echo "  ✗ Failed to create optional link"
        fi
    fi
done

echo "----------------------------------------"
echo "All links processed successfully!"
