BINARY_NAME = mthesaur
GO_FILE = mthesaur.go

BUILD_DIR = build

# Default target
.PHONY: all
all: build

# Build the Go binary
.PHONY: build
build:
	@echo "Building $(BINARY_NAME)..."
	@mkdir -p $(BUILD_DIR)
	go build -o $(BUILD_DIR)/$(BINARY_NAME) $(GO_FILE)
	@echo "Binary built: $(BUILD_DIR)/$(BINARY_NAME)"

# Cross compile for common platforms
.PHONY: build-all
build-all:
	@echo "Building $(BINARY_NAME) for all platforms..."
	@mkdir -p $(BUILD_DIR)
	GOOS=linux   GOARCH=amd64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-linux-amd64   $(GO_FILE)
	GOOS=linux   GOARCH=arm64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-linux-arm64   $(GO_FILE)
	GOOS=darwin  GOARCH=amd64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-darwin-amd64  $(GO_FILE)
	GOOS=darwin  GOARCH=arm64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-darwin-arm64  $(GO_FILE)
	GOOS=windows GOARCH=amd64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-windows-amd64.exe $(GO_FILE)
	GOOS=windows GOARCH=arm64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-windows-arm64.exe $(GO_FILE)
	@echo "All binaries built in $(BUILD_DIR)"

# Install the binary to /usr/local/bin (requires sudo)
.PHONY: install
install: build
	@echo "Installing $(BINARY_NAME) to /usr/local/bin..."
	sudo cp $(BUILD_DIR)/$(BINARY_NAME) /usr/local/bin/
	@echo "Installation complete"

# Install the binary to user's local bin directory
.PHONY: install-local
install-local: build
	@echo "Installing $(BINARY_NAME) to ~/.local/bin..."
	@mkdir -p ~/.local/bin
	cp $(BUILD_DIR)/$(BINARY_NAME) ~/.local/bin/
	@echo "Local installation complete"

# Test the binary
.PHONY: test
test: build
	@echo "Testing $(BINARY_NAME)..."
	@echo "Testing with 'happy':"
	./$(BUILD_DIR)/$(BINARY_NAME) happy
	@echo ""
	@echo "Testing with 'nonexistent':"
	./$(BUILD_DIR)/$(BINARY_NAME) nonexistent

# Clean build artifacts
.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	rm -rf $(BUILD_DIR)
	@echo "Clean complete"

# Format Go code
.PHONY: fmt
fmt:
	go fmt $(GO_FILE)

# Lint Go code
.PHONY: lint
lint:
	golangci-lint run $(GO_FILE)

# Show help
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  build        - Build the Go binary"
	@echo "  install      - Install binary to /usr/local/bin (requires sudo)"
	@echo "  install-local- Install binary to ~/.local/bin"
	@echo "  test         - Test the binary with sample words"
	@echo "  clean        - Remove build artifacts"
	@echo "  test-go      - Run Go tests"
	@echo "  fmt          - Format Go code"
	@echo "  lint         - Lint Go code"
	@echo "  help         - Show this help message"
