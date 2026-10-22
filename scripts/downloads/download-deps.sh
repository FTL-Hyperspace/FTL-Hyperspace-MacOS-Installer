#!/bin/bash
set -e

# Source dependency versions from root (default)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$REPO_ROOT/.deps-versions"

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../" && pwd)"
source "$SCRIPTS_DIR/utils/utils.sh"
source "$SCRIPTS_DIR/utils/github-utils.sh"

# Parse arguments
ARCH=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --arch)
      ARCH="$2"
      shift 2
      ;;
    --hyperspace-version)
      HYPERSPACE_VERSION="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Default arch if not provided
ARCH="${ARCH:-x86_64}"

# Resolve "latest" to a concrete upstream tag (no-op for explicit versions)
HYPERSPACE_VERSION=$("$SCRIPTS_DIR/utils/resolve-hyperspace-version.sh" "$HYPERSPACE_VERSION")

# Map arm64 to aarch64 for ftlman filename
FTLMAN_ARCH="$ARCH"
if [ "$ARCH" = "arm64" ]; then
  FTLMAN_ARCH="aarch64"
fi



# Display header
info "Downloading Dependencies"
echo ""
echo "Dependency versions:"
echo "  ftlman: $FTLMAN_VERSION"
echo "  FTL-Hyperspace: $HYPERSPACE_VERSION"
echo ""

# Create external directory
mkdir -p "$EXTERNAL_DIR"

# Download ftlman for target architecture
step "Downloading ftlman-$FTLMAN_ARCH@$FTLMAN_VERSION..."
download_and_extract "afishhh/ftlman" "$FTLMAN_VERSION" "ftlman-$FTLMAN_ARCH-apple-darwin.tar.gz" "$EXTERNAL_DIR"

# Flatten directory structure if needed
if [ -d "$EXTERNAL_DIR/ftlman" ] && [ -f "$EXTERNAL_DIR/ftlman/ftlman" ]; then
    mv "$EXTERNAL_DIR/ftlman/ftlman" "$EXTERNAL_DIR/ftlman.tmp"
    rm -rf "$EXTERNAL_DIR/ftlman"
    mv "$EXTERNAL_DIR/ftlman.tmp" "$EXTERNAL_DIR/ftlman"
fi

chmod +x "$EXTERNAL_DIR/ftlman"
echo ""

# Download FTL-Hyperspace (MacOS build)
step "Downloading FTL-Hyperspace@$HYPERSPACE_VERSION..."
download_and_extract "FTL-Hyperspace/FTL-Hyperspace" "$HYPERSPACE_VERSION" "*-MacOS.zip" "$EXTERNAL_DIR"
echo ""

# Download license files bundled into the app
step "Downloading license files..."
download_repo_file "afishhh/ftlman" "$FTLMAN_VERSION" "LICENSE" "$EXTERNAL_DIR/licenses/LICENSE-ftlman" \
    || error "Failed to download ftlman LICENSE"
success "Downloaded ftlman LICENSE"

# Older Hyperspace tags predate COPYRIGHT.md, so fall back to the default branch
download_repo_file "FTL-Hyperspace/FTL-Hyperspace" "$HYPERSPACE_VERSION" "COPYRIGHT.md" "$EXTERNAL_DIR/licenses/COPYRIGHT.md" 2>/dev/null \
    || download_repo_file "FTL-Hyperspace/FTL-Hyperspace" "" "COPYRIGHT.md" "$EXTERNAL_DIR/licenses/COPYRIGHT.md" \
    || error "Failed to download Hyperspace COPYRIGHT.md"
success "Downloaded Hyperspace COPYRIGHT.md"
echo ""

# Verify downloads
step "Verifying downloaded files..."
require_file "$EXTERNAL_DIR/ftlman" "ftlman"
success "ftlman verified"

# Check for Hyperspace files
if ls "$EXTERNAL_DIR"/Hyperspace* &> /dev/null; then
    success "Hyperspace files verified"
else
    echo "  Note: Checking for Hyperspace files..."
    ls -la "$EXTERNAL_DIR" | grep -i hyperspace || true
fi

# Store downloaded versions for downstream use
cat > "$EXTERNAL_DIR/.downloaded-versions" <<EOF
FTLMAN_VERSION="$FTLMAN_VERSION"
HYPERSPACE_VERSION="$HYPERSPACE_VERSION"
EOF

echo ""
echo -e "${GREEN}=== Dependencies Downloaded Successfully ===${NC}"
echo ""
