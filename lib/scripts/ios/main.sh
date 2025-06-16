#!/bin/bash
set -euo pipefail
trap 'echo "[ERROR] Script failed at line $LINENO"; exit 1' ERR

# Source local environment variables if available (for local development/testing)
if [ -f "lib/config/env.sh" ]; then
  set -a  # automatically export all variables
  source lib/config/env.sh
  set +a  # stop automatically exporting
else
  # In Codemagic, variables are provided via CM_ENV
  log "Using Codemagic environment variables (CM_ENV)"
  # No need to source anything as CM_ENV is already available
fi

# Source common variables with defaults for local/dev builds
source lib/scripts/utils/variables.sh

# Logging function
log() {
  echo "[IOS][$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "Starting iOS-Only workflow (Code Signed IPA)"

# Validate required variables
REQUIRED_VARS=(
  "APP_NAME"
  "BUNDLE_ID"
  "VERSION_NAME"
  "VERSION_CODE"
  "ORG_NAME"
  "WEB_URL"
  "EMAIL_ID"
  "CERT_CER_URL"
  "CERT_KEY_URL"
  "PROFILE_URL"
  "CERT_PASSWORD"
)

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

# --- Code Signing Setup ---
log "Setting up code signing..."
if [ -f "lib/scripts/ios/signing.sh" ]; then
  log "Generating .p12 for signing..."
  bash lib/scripts/ios/signing.sh
else
  log "[WARN] Signing sub-script not found. Skipping .p12 generation."
  exit 1
fi

# --- Branding and Assets ---
log "Setting up branding and assets..."
if [ -f "lib/scripts/ios/branding.sh" ]; then
  bash lib/scripts/ios/branding.sh
else
  log "[WARN] Branding sub-script not found. Skipping branding setup."
  exit 1
fi

# --- Firebase Setup (if enabled) ---
if [ "${PUSH_NOTIFY:-false}" = "true" ]; then
  log "Setting up Firebase..."
  if [ -f "lib/scripts/ios/firebase.sh" ]; then
    bash lib/scripts/ios/firebase.sh
  else
    log "[WARN] Firebase sub-script not found. Skipping Firebase setup."
    exit 1
  fi
else
  log "PUSH_NOTIFY is false; skipping Firebase setup."
fi

# --- Permissions Setup ---
log "Setting up permissions..."
if [ -f "lib/scripts/ios/permissions.sh" ]; then
  bash lib/scripts/ios/permissions.sh
else
  log "[WARN] Permissions sub-script not found. Skipping permissions setup."
fi

# --- Dart Environment Variables ---
log "Generating Dart environment variables..."
echo "[DART ENV] Generating Dart env file..."
bash lib/scripts/utils/gen_dart_env.sh

# --- Dynamic App Name & Bundle ID Injection ---
log "Updating app name and bundle ID..."
if [ -n "${APP_NAME:-}" ]; then
  /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $APP_NAME" ios/Runner/Info.plist || true
  /usr/libexec/PlistBuddy -c "Set :CFBundleName $APP_NAME" ios/Runner/Info.plist || true
  sed -i '' "s/PRODUCT_NAME = .*/PRODUCT_NAME = \"$APP_NAME\"/" macos/Runner/Configs/AppInfo.xcconfig || true
fi
if [ -n "${BUNDLE_ID:-}" ]; then
  sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = .*/PRODUCT_BUNDLE_IDENTIFIER = \"$BUNDLE_ID\"/" macos/Runner/Configs/AppInfo.xcconfig || true
fi

# --- Flutter Launcher Icons ---
log "Generating launcher icons..."
if command -v flutter >/dev/null 2>&1; then
  flutter pub run flutter_launcher_icons:main
else
  log "[WARN] Flutter not found. Skipping launcher icon generation."
fi

# --- Flutter Build ---
log "Building Flutter iOS app..."
flutter build ios --release --no-codesign

# --- Xcode Build and Export ---
log "Building and exporting IPA..."
# Archive the app
xcodebuild -workspace ios/Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -archivePath "$OUTPUT_DIR/ios/App.xcarchive" \
  CODE_SIGN_IDENTITY="Apple Distribution" \
  PROVISIONING_PROFILE_SPECIFIER="Garbcode_App_Store" \
  archive

# Export IPA
xcodebuild -exportArchive \
  -archivePath "$OUTPUT_DIR/ios/App.xcarchive" \
  -exportOptionsPlist ios/ExportOptions.plist \
  -exportPath "$OUTPUT_DIR/ios/"

# Find the generated IPA
IPA_PATH=$(find "$OUTPUT_DIR/ios/" -name '*.ipa' | head -n 1)
if [ -z "$IPA_PATH" ]; then
  log "[ERROR] No IPA file found after build."
  exit 1
fi

log "IPA built successfully at: $IPA_PATH"

# --- Send Notification ---
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

# After successful build, send success notification
IPA_URL="$IPA_PATH"
BUILD_LOG_URL="${BUILD_LOG_URL:-#}"
RESUME_URL="${RESUME_URL:-#}"
send_notification "Success" "$IPA_URL" "$BUILD_LOG_URL" "$RESUME_URL"

log "iOS-Only workflow completed successfully."
exit 0 