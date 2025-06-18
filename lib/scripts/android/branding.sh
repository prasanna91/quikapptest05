#!/bin/bash
set -euo pipefail

log() { echo "[BRANDING][$(date '+%Y-%m-%d %H:%M:%S')] $1"; }

# Debug: Show environment variables
log "Debug: SPLASH_URL='${SPLASH_URL:-[NOT SET]}'"
log "Debug: SPLASH='${SPLASH:-[NOT SET]}'"

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
    # Check if flutter_launcher_icons is available
    if flutter pub deps | grep -q "flutter_launcher_icons"; then
      flutter pub run flutter_launcher_icons:main || log "[WARN] flutter_launcher_icons failed."
    else
      log "[WARN] flutter_launcher_icons not found in dependencies. Skipping icon generation."
    fi
  else
    log "[WARN] Flutter not available. Skipping icon generation."
  fi
fi

# Properly resolve SPLASH_URL - handle case where SPLASH_URL contains variable expression
if [[ "${SPLASH_URL:-}" == *'${SPLASH'* ]]; then
  # SPLASH_URL contains a variable expression, use SPLASH instead
  SPLASH_URL_RESOLVED="${SPLASH:-https://raw.githubusercontent.com/prasanna91/QuikApp/main/logo-gc.png}"
else
  # SPLASH_URL is a direct value
  SPLASH_URL_RESOLVED="${SPLASH_URL:-${SPLASH:-https://raw.githubusercontent.com/prasanna91/QuikApp/main/logo-gc.png}}"
fi
log "Debug: SPLASH_URL_RESOLVED='$SPLASH_URL_RESOLVED'"
if [ -n "$SPLASH_URL_RESOLVED" ]; then
  log "Downloading splash from $SPLASH_URL_RESOLVED"
  curl -sSL "$SPLASH_URL_RESOLVED" -o assets/splash.png || log "[WARN] Failed to download splash image."
fi

log "Branding and splash assets updated." 