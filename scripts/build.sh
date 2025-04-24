#!/bin/bash

# Exit on any error
set -e

# Read version from version.txt
VERSION=$(cat version.txt)
if [ -z "$VERSION" ]; then
    echo "❌ Error: version.txt is empty or not found"
    exit 1
fi

# Configuration
SCHEME="PixelClock"
CONFIGURATION="Debug"  # Debug build for development
PROJECT_PATH="./PixelClock.xcodeproj"
BUILD_PATH="./build"
APP_NAME="PixelClock"

# Parse command line arguments for architecture
ARCH=""
case "$1" in
    "arm64")
        ARCH="arm64"
        ;;
    "x86_64")
        ARCH="x86_64"
        ;;
    "universal")
        ARCH="universal"
        ;;
    *)
        # Default to current architecture if not specified
        ARCH=$(uname -m)
        ;;
esac

echo "🎯 Target architecture: $ARCH"

# Build configuration based on architecture
BUILD_ARGS=()
case "$ARCH" in
    "universal")
        BUILD_ARGS+=(ONLY_ACTIVE_ARCH=NO ARCHS="arm64 x86_64")
        VERSIONED_APP_NAME="${APP_NAME}_v${VERSION}_universal"
        ;;
    *)
        BUILD_ARGS+=(ONLY_ACTIVE_ARCH=YES ARCHS=$ARCH)
        VERSIONED_APP_NAME="${APP_NAME}_v${VERSION}_${ARCH}"
        ;;
esac

# Create build directory if it doesn't exist
mkdir -p "$BUILD_PATH"

echo "🚀 Building ${APP_NAME} version ${VERSION}..."

# Clean and build
xcodebuild clean build \
    -project "$PROJECT_PATH" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -derivedDataPath "$BUILD_PATH" \
    MARKETING_VERSION="${VERSION}" \
    CURRENT_PROJECT_VERSION="${VERSION}" \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    "${BUILD_ARGS[@]}"

# Get the path of the built .app
APP_PATH="$BUILD_PATH/Build/Products/$CONFIGURATION/$APP_NAME.app"
VERSIONED_APP_PATH="$BUILD_PATH/Build/Products/$CONFIGURATION/$VERSIONED_APP_NAME.app"

# Check if build was successful
if [ ! -d "$APP_PATH" ]; then
    echo "❌ Error: Build failed - $APP_PATH not found"
    exit 1
fi

# Rename the .app to include version number and architecture
mv "$APP_PATH" "$VERSIONED_APP_PATH"

echo "✅ Build complete!"
echo "📦 App location: $VERSIONED_APP_PATH"
echo "📝 Version: $VERSION"
echo "💻 Architecture: $ARCH"
