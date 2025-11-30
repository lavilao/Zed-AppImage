#!/usr/bin/env bash

set -e

APP="zed"
BINARY_NAME="zed"

echo "Creating Zed AppImage using ivan-hc's approach..."

# Create temporary directory
mkdir -p tmp
cd tmp || exit 1

# Download appimagetool
echo "Downloading appimagetool..."
if [ ! -f ./appimagetool ]; then
    curl -L -o appimagetool \
        "https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage"
    chmod +x appimagetool
fi

# Get latest Zed release
echo "Fetching latest Zed release..."
API_RESPONSE=$(curl -s https://api.github.com/repos/zed-industries/zed/releases/latest)
ASSET_URL=$(echo "$API_RESPONSE" | grep -oP '"browser_download_url": "\K[^"]*' | grep -i "x86_64-unknown-linux-musl.tar.gz")
VERSION=$(echo "$API_RESPONSE" | grep -oP '"tag_name": "\K[^"]*' | sed 's/^v//')

if [ -z "$ASSET_URL" ]; then
    echo "Error: Could not find Zed Linux tarball URL"
    exit 1
fi

echo "Downloading Zed version $VERSION..."
curl -L -o zed.tar.gz "$ASSET_URL"

# Create AppDir
mkdir -p "$APP".AppDir

# Extract Zed
echo "Extracting Zed..."
tar fx zed.tar.gz --strip-components=1 -C "$APP".AppDir

# Create desktop file
cat > "$APP".AppDir/zed.desktop << EOF
[Desktop Entry]
Name=Zed
Exec=zed
Icon=zed
Type=Application
Categories=Development;IDE;
Comment=High-performance, multiplayer code editor from the creators of Atom and Tree-sitter.
Terminal=false
MimeType=text/plain;
EOF

# Try to get icon from the extracted files, or download a default one
if [ -f "$APP".AppDir/assets/logo.png ]; then
    cp "$APP".AppDir/assets/logo.png "$APP".AppDir/zed.png
else
    # Download a fallback icon
    curl -L -o "$APP".AppDir/zed.png "https://raw.githubusercontent.com/zed-industries/zed/main/assets/logo.png" 2>/dev/null || \
    # Create a simple fallback icon if download fails
    convert -size 512x512 xc:#4a90e2 -gravity center -pointsize 48 -fill white -annotate 0 "Z" "$APP".AppDir/zed.png 2>/dev/null || \
    touch "$APP".AppDir/zed.png
fi

# Create AppRun script
cat > "$APP".AppDir/AppRun << 'EOF'
#!/bin/bash
HERE="$(dirname "$(readlink -f "${0}")")"
export PATH="${HERE}/usr/bin:${HERE}/usr/lib:${PATH}"
export LD_LIBRARY_PATH="${HERE}/usr/lib:${HERE}/usr/lib64:${LD_LIBRARY_PATH}"
export QT_PLUGIN_PATH="${HERE}/usr/lib/plugins:${QT_PLUGIN_PATH}"
export QML2_IMPORT_PATH="${HERE}/usr/lib/qml:${QML2_IMPORT_PATH}"
export XDG_DATA_DIRS="${HERE}/usr/share:/usr/share:${XDG_DATA_DIRS}"

# Execute Zed with proper paths
exec "${HERE}"/zed "$@"
EOF

chmod +x "$APP".AppDir/AppRun

# Build the AppImage with delta update support
echo "Building AppImage with delta update support..."
APPNAME="Zed"
REPO="Zed-AppImage"
TAG="latest"
UPINFO="gh-releases-zsync|$GITHUB_REPOSITORY_OWNER|$REPO|$TAG|*x86_64.AppImage.zsync"

# Use appimagetool with update info
ARCH=x86_64 ./appimagetool -u "$UPINFO" "$APP".AppDir "$APPNAME"-"$VERSION"-x86_64.AppImage

# Move the result back to parent directory
mv "$APPNAME"-"$VERSION"-x86_64.AppImage .. 2>/dev/null || mv *-x86_64.AppImage .. 2>/dev/null

cd ..
echo "Zed AppImage created successfully!"
ls -la *.AppImage