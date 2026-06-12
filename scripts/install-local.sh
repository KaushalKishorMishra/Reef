#!/usr/bin/env bash
# install-local.sh
# Builds Reef (Debug), installs it to /Applications, and relaunches it.
# Run from the project root: ./scripts/install-local.sh

set -euo pipefail

PROJECT="Reef.xcodeproj"
SCHEME="Reef"
APP_NAME="Reef.app"
INSTALL_PATH="/Applications/${APP_NAME}"
BUILD_DIR="/tmp/reef-local-build"

echo "▶ Building ${SCHEME}..."
xcodebuild build \
  -project "${PROJECT}" \
  -scheme "${SCHEME}" \
  -configuration Debug \
  -derivedDataPath "${BUILD_DIR}" \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  ONLY_ACTIVE_ARCH=YES \
  -quiet

BUILT_APP="${BUILD_DIR}/Build/Products/Debug/${APP_NAME}"

if [ ! -d "${BUILT_APP}" ]; then
  echo "✗ Build output not found at ${BUILT_APP}"
  exit 1
fi

echo "▶ Stopping running Reef (if any)..."
pkill -x "Reef" 2>/dev/null || true
sleep 0.5

echo "▶ Installing to ${INSTALL_PATH}..."
rm -rf "${INSTALL_PATH}"
cp -r "${BUILT_APP}" "${INSTALL_PATH}"

echo "▶ Relaunching Reef..."
open "${INSTALL_PATH}"

echo "✓ Done — Reef is running from ${INSTALL_PATH}"
