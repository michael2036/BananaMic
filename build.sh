#!/bin/bash

APP_NAME="ToolbarApp"
APP_DIR="${APP_NAME}.app"
CONTENTS_DIR="${APP_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"

RESOURCES_DIR="${CONTENTS_DIR}/Resources"

# Clean previous build
rm -rf "${APP_DIR}"

# Create directories
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

# Create Info.plist
cat > "${CONTENTS_DIR}/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.michael.${APP_NAME}</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSMicrophoneUsageDescription</key>
    <string>ToolbarApp requires microphone access to record audio.</string>
</dict>
</plist>
EOF

# Compile Swift code
swiftc main.swift -o "${MACOS_DIR}/${APP_NAME}"

# Ensure it's executable
chmod +x "${MACOS_DIR}/${APP_NAME}"

# Copy App Icon
cp AppIcon.icns "${RESOURCES_DIR}/"

# Add PkgInfo to help macOS recognize it as an App
echo "APPL????" > "${CONTENTS_DIR}/PkgInfo"

# Invalidate Finder cache and remove quarantine attributes so it launches cleanly
touch "${APP_DIR}"
xattr -cr "${APP_DIR}" 2>/dev/null || true

echo "Build complete. App created at ${APP_DIR}"
