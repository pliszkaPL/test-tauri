.PHONY: dev build-linux build-windows install clean help

# Default target
all: help

# Install dependencies
install:
	npm install
	cd src-tauri && cargo fetch

# Development mode - starts Vite dev server and Tauri in dev mode
dev:
	@echo "Starting development server..."
	npm run dev &
	@sleep 3
	cd src-tauri && cargo tauri dev

# Build for Linux
build-linux:
	@echo "Building for Linux..."
	npm run build
	cd src-tauri && cargo tauri build --target x86_64-unknown-linux-gnu

# Build for Windows (cross-compile from Linux)
build-windows:
	@echo "Building for Windows..."
	npm run build
	cd src-tauri && cargo tauri build --target x86_64-pc-windows-msvc

# Build for current platform
build:
	@echo "Building for current platform..."
	npm run build
	cd src-tauri && cargo tauri build

# Run type checking
typecheck:
	npm run build

# Clean build artifacts
clean:
	rm -rf dist
	rm -rf node_modules
	cd src-tauri && cargo clean

# Run bash scripts
run-load-config:
	@echo "Usage: make run-load-config CONFIG_PATH=<path>"
	@if [ -n "$(CONFIG_PATH)" ]; then ./scripts/load_config.sh $(CONFIG_PATH); fi

run-create-dir:
	@echo "Usage: make run-create-dir DIR_PATH=<path>"
	@if [ -n "$(DIR_PATH)" ]; then ./scripts/create_dir.sh $(DIR_PATH); fi

run-list-dir:
	@echo "Usage: make run-list-dir DIR_PATH=<path>"
	@if [ -n "$(DIR_PATH)" ]; then ./scripts/list_dir.sh $(DIR_PATH); fi

run-create-symlink:
	@echo "Usage: make run-create-symlink SOURCE=<source> DESTINATION=<dest>"
	@if [ -n "$(SOURCE)" ] && [ -n "$(DESTINATION)" ]; then ./scripts/create_symlink.sh $(SOURCE) $(DESTINATION); fi

run-delete-symlink:
	@echo "Usage: make run-delete-symlink SYMLINK_PATH=<path>"
	@if [ -n "$(SYMLINK_PATH)" ]; then ./scripts/delete_symlink.sh $(SYMLINK_PATH); fi

run-process-links:
	@echo "Usage: make run-process-links CONFIG_PATH=<path>"
	@if [ -n "$(CONFIG_PATH)" ]; then ./scripts/process_links.sh $(CONFIG_PATH); fi

# Help
help:
	@echo "Available targets:"
	@echo "  dev           - Start development server with hot reload"
	@echo "  build         - Build for current platform"
	@echo "  build-linux   - Build for Linux"
	@echo "  build-windows - Build for Windows"
	@echo "  install       - Install dependencies"
	@echo "  typecheck     - Run TypeScript type checking"
	@echo "  clean         - Clean build artifacts"
	@echo ""
	@echo "Script runners:"
	@echo "  run-load-config CONFIG_PATH=<path>       - Load JSON config"
	@echo "  run-create-dir DIR_PATH=<path>           - Create directory"
	@echo "  run-list-dir DIR_PATH=<path>             - List directory"
	@echo "  run-create-symlink SOURCE=<s> DEST=<d>   - Create symlink"
	@echo "  run-delete-symlink SYMLINK_PATH=<path>   - Delete symlink"
	@echo "  run-process-links CONFIG_PATH=<path>     - Process project links"
