# Symlink Manager

A Tauri + Vue.js desktop application for managing symlinks and project configurations.

## Features

- **Load JSON Config**: Load project configuration files with link definitions
- **Create Directories**: Create directories with a GUI or bash scripts
- **List Directories**: View directory contents (like `ls -la`)
- **Create Symlinks**: Create symbolic links between source and destination paths
- **Delete Symlinks**: Remove symbolic links
- **Process Project Links**: Automatically process all links defined in a project config

## Tech Stack

- **Frontend**: Vue.js 3 + TypeScript + Vite
- **Backend**: Tauri (Rust)
- **Styling**: Tailwind CSS + shadcn-vue
- **Scripting**: Bash scripts for command-line operations

## Project Config Format

Projects are described with JSON files containing link definitions:

```json
{
  "name": "myapp",
  "version": "1.0.0",
  "links": [
    {
      "source": "projects/myapp/.env-prod",
      "destination": "projects-git/myapp/config/{version}/.env",
      "required": true
    },
    {
      "source": "projects/myapp/config.json",
      "destination": "projects-git/myapp/config/{version}/config.json",
      "required": false
    }
  ]
}
```

The `{version}` placeholder in destinations is replaced with the project version.

## Development

### Prerequisites

- Node.js 18+
- Rust 1.77+
- Linux: `libwebkit2gtk-4.1-dev`, `libgtk-3-dev`, `libayatana-appindicator3-dev`, `librsvg2-dev`

### Commands

```bash
# Install dependencies
make install

# Start development server
make dev

# Build for current platform
make build

# Build for Linux
make build-linux

# Build for Windows (cross-compile)
make build-windows

# Clean build artifacts
make clean
```

## Bash Scripts

The `scripts/` directory contains standalone bash scripts:

```bash
# Load JSON config
./scripts/load_config.sh /path/to/config.json

# Create directory
./scripts/create_dir.sh /path/to/directory

# List directory contents
./scripts/list_dir.sh /path/to/directory

# Create symlink
./scripts/create_symlink.sh /source/path /destination/path

# Delete symlink
./scripts/delete_symlink.sh /path/to/symlink

# Process all links from config
./scripts/process_links.sh /path/to/config.json
```

You can also run them via Make:

```bash
make run-load-config CONFIG_PATH=/path/to/config.json
make run-create-dir DIR_PATH=/path/to/directory
make run-list-dir DIR_PATH=/path/to/directory
make run-create-symlink SOURCE=/source DESTINATION=/dest
make run-delete-symlink SYMLINK_PATH=/path/to/symlink
make run-process-links CONFIG_PATH=/path/to/config.json
```

## License

MIT
