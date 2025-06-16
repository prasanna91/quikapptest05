#!/bin/bash
set -euo pipefail

log() { echo "[BRANDING][$(date '+%Y-%m-%d %H:%M:%S')] $1"; }

mkdir -p assets

# Download logo and splash images
if [ -n "${LOGO_URL:-}" ]; then
  log "Downloading logo from $LOGO_URL"
  curl -sSL "$LOGO_URL" -o assets/logo.png || log "[WARN] Failed to download logo."
fi
if [ -n "${SPLASH:-}" ]; then
  log "Downloading splash from $SPLASH"
  curl -sSL "$SPLASH" -o assets/splash.png || log "[WARN] Failed to download splash image."
fi

log "Branding and splash assets updated for iOS. (Icon generation handled by Xcode asset catalog.)" 