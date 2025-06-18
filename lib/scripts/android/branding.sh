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
    # First ensure dependencies are available
    flutter pub get >/dev/null 2>&1 || true
    # Then try to run the icon generator
    flutter pub run flutter_launcher_icons:main || log "[WARN] flutter_launcher_icons failed."
  else
    log "[WARN] Flutter not available. Skipping icon generation."
  fi
fi

if [ -n "${SPLASH_URL:-}" ]; then
  log "Downloading splash from $SPLASH_URL"
  curl -sSL "$SPLASH_URL" -o assets/splash.png || log "[WARN] Failed to download splash image."
fi

log "Branding and splash assets updated." 