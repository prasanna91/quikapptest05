#!/bin/bash
set -euo pipefail
trap 'echo "[ERROR] Script failed at line $LINENO"; exit 1' ERR

# Logging function
log() {
  echo "[IOS][$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "Starting iOS-Only workflow (Code Signed IPA)"

# Load dynamic variables
if [ -f "lib/scripts/utils/load_vars.sh" ]; then
  source lib/scripts/utils/load_vars.sh
else
  log "[WARN] Variable loader not found. Using environment variables."
fi

# Validate required variables
REQUIRED_VARS=(APP_ID APP_NAME BUNDLE_ID VERSION_NAME VERSION_CODE OUTPUT_DIR APPLE_TEAM_ID APNS_KEY_ID APNS_AUTH_KEY_URL CERT_PASSWORD PROFILE_URL CERT_CER_URL CERT_KEY_URL EXPORT_PROFILE_TYPE)
for var in "${REQUIRED_VARS[@]}"; do
  if [ -z "${!var:-}" ]; then
    log "[ERROR] Required variable $var is not set."
    exit 1
  fi
done

# Prepare output directory
mkdir -p "$OUTPUT_DIR/ios"

# Clean old IPA files before build
log "Cleaning old IPA files in $OUTPUT_DIR/ios/ ..."
rm -f "$OUTPUT_DIR/ios/"*.ipa || true

# Decode and generate .p12
if [ -f "lib/scripts/ios/signing.sh" ]; then
  log "Generating .p12 for signing..."
  bash lib/scripts/ios/signing.sh
else
  log "[WARN] Signing sub-script not found. Skipping .p12 generation."
fi

# Branding, splash, and icon
if [ -f "lib/scripts/ios/branding.sh" ]; then
  bash lib/scripts/ios/branding.sh
fi

# Firebase (if enabled)
if [ -f "lib/scripts/ios/firebase.sh" ]; then
  bash lib/scripts/ios/firebase.sh
fi

# Permissions
if [ -f "lib/scripts/ios/permissions.sh" ]; then
  bash lib/scripts/ios/permissions.sh
fi

# Dart variable injection
echo "[DART ENV] Generating Dart env file..."
bash lib/scripts/utils/gen_dart_env.sh

# --- Dynamic App Name & Bundle ID Injection (iOS) ---
if [ -n "${APP_NAME:-}" ]; then
  /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $APP_NAME" ios/Runner/Info.plist || true
  /usr/libexec/PlistBuddy -c "Set :CFBundleName $APP_NAME" ios/Runner/Info.plist || true
  sed -i '' "s/PRODUCT_NAME = .*/PRODUCT_NAME = $APP_NAME/" macos/Runner/Configs/AppInfo.xcconfig || true
fi
if [ -n "${BUNDLE_ID:-}" ]; then
  sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = .*/PRODUCT_BUNDLE_IDENTIFIER = $BUNDLE_ID/" macos/Runner/Configs/AppInfo.xcconfig || true
fi

# Build IPA (stub)
log "Building IPA (stub)"
# TODO: Replace with actual build command, e.g., xcodebuild
IPA_PATH="output/ios/app.ipa"
touch "$IPA_PATH"

log "IPA copied to $OUTPUT_DIR/ios/"

# Source email variables
if [ -f "lib/scripts/utils/variables.sh" ]; then
  source lib/scripts/utils/variables.sh
fi

# Function to send notification email
send_notification() {
  local status="$1"
  local ipa_url="$2"
  local log_url="$3"
  local resume_url="$4"
  bash lib/scripts/utils/send_email.sh "$status" "iOS" "" "" "$ipa_url" "$log_url" "$resume_url"
}

trap 'send_notification "Failed" "" "$BUILD_LOG_URL" "$RESUME_URL"; exit 1' ERR

# After successful build, send success notification
IPA_URL=$(find "$OUTPUT_DIR/ios/" -name '*.ipa' | head -n 1)
BUILD_LOG_URL="${BUILD_LOG_URL:-#}"
RESUME_URL="${RESUME_URL:-#}"
send_notification "Success" "$IPA_URL" "$BUILD_LOG_URL" "$RESUME_URL"

log "iOS-Only workflow completed successfully."
exit 0 