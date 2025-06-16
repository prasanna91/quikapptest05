#!/bin/bash
set -euo pipefail

log() { echo "[BRANDING][$(date '+%Y-%m-%d %H:%M:%S')] $1"; }

# Create required directories
mkdir -p assets
mkdir -p assets/images
mkdir -p ios/Runner/Assets.xcassets

# Download and setup logo
if [ -n "${LOGO_URL:-}" ]; then
  log "Downloading logo from $LOGO_URL"
  curl -sSL "$LOGO_URL" -o assets/images/logo.png || {
    log "[ERROR] Failed to download logo from $LOGO_URL"
    exit 1
  }
  log "Logo downloaded successfully"
else
  log "[ERROR] LOGO_URL is not set"
  exit 1
fi

# Download and setup splash
if [ -n "${SPLASH:-}" ]; then
  log "Downloading splash from $SPLASH"
  curl -sSL "$SPLASH" -o assets/splash.png || {
    log "[ERROR] Failed to download splash from $SPLASH"
    exit 1
  }
  log "Splash downloaded successfully"
else
  log "[ERROR] SPLASH is not set"
  exit 1
fi

# Download and setup splash background (optional)
if [ -n "${SPLASH_BG:-}" ]; then
  log "Downloading splash background from $SPLASH_BG"
  curl -sSL "$SPLASH_BG" -o assets/splash_bg.png || {
    log "[WARN] Failed to download splash background from $SPLASH_BG"
  }
  log "Splash background downloaded successfully"
fi

# Generate launcher icons
if command -v flutter >/dev/null 2>&1; then
  log "Generating launcher icons..."
  flutter pub run flutter_launcher_icons:main
  log "Launcher icons generated successfully"
else
  log "[ERROR] Flutter not found. Cannot generate launcher icons."
  exit 1
fi

# Update Info.plist with splash screen settings
if [ -n "${SPLASH_DURATION:-}" ]; then
  /usr/libexec/PlistBuddy -c "Set :SplashScreenDuration $SPLASH_DURATION" ios/Runner/Info.plist || true
fi

if [ -n "${SPLASH_ANIMATION:-}" ]; then
  /usr/libexec/PlistBuddy -c "Set :SplashScreenAnimation $SPLASH_ANIMATION" ios/Runner/Info.plist || true
fi

if [ -n "${SPLASH_BG_COLOR:-}" ]; then
  /usr/libexec/PlistBuddy -c "Set :SplashScreenBackgroundColor $SPLASH_BG_COLOR" ios/Runner/Info.plist || true
fi

if [ -n "${SPLASH_TAGLINE:-}" ]; then
  /usr/libexec/PlistBuddy -c "Set :SplashScreenTagline $SPLASH_TAGLINE" ios/Runner/Info.plist || true
fi

if [ -n "${SPLASH_TAGLINE_COLOR:-}" ]; then
  /usr/libexec/PlistBuddy -c "Set :SplashScreenTaglineColor $SPLASH_TAGLINE_COLOR" ios/Runner/Info.plist || true
fi

log "Branding and splash assets updated successfully."
exit 0 