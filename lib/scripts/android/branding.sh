#!/bin/bash
set -euo pipefail

log() { echo "[BRANDING][$(date '+%Y-%m-%d %H:%M:%S')] $1"; }

mkdir -p assets
mkdir -p assets/images

# Download logo and splash images
if [ -n "${LOGO_URL:-}" ]; then
  log "Downloading logo from $LOGO_URL"
  curl -sSL "$LOGO_URL" -o assets/images/logo.png || log "[WARN] Failed to download logo."
  # Generate launcher icons using flutter_launcher_icons
  if command -v flutter >/dev/null 2>&1; then
    log "Generating launcher icons from logo..."
    flutter pub run flutter_launcher_icons:main || log "[WARN] flutter_launcher_icons failed."
  else
    log "[WARN] flutter_launcher_icons not available. Skipping icon generation."
  fi
fi
if [ -n "${SPLASH:-}" ]; then
  log "Downloading splash from $SPLASH"
  curl -sSL "$SPLASH" -o assets/splash.png || log "[WARN] Failed to download splash image."
fi



log "Branding and splash assets updated." 