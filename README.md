# Zed AppImage

This repository contains an AppImage build for [Zed](https://zed.dev/), a high-performance, multiplayer code editor.

## About

This AppImage is built using an approach inspired by [ivan-hc's AppImage building techniques](https://github.com/ivan-hc), focusing on:

- Direct download of official Zed releases
- Delta update support via zsync for efficient updates
- Minimal dependencies and maximum portability
- Reproducible builds for better delta update efficiency

## Usage

1. Download the latest AppImage from the releases page
2. Make it executable: `chmod +x Zed-*.AppImage`
3. Run it: `./Zed-*.AppImage`

## Delta Updates

This AppImage supports delta updates via zsync. To update your AppImage:

```bash
zsync -u Zed-*.AppImage.zsync
```

Or use AppImageUpdate if you have it installed.

## Building

To build the AppImage locally:

```bash
chmod +x build_zed_appimage.sh
./build_zed_appimage.sh
```

## Approach

This build script follows ivan-hc's pattern:
1. Downloads the official Zed tar.gz release
2. Creates an AppDir with proper desktop integration
3. Builds the AppImage with delta update support using the `-u` flag
4. Maintains consistent build parameters for reproducible builds