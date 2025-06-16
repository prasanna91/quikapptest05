#!/bin/bash
set -euo pipefail
trap 'echo "[ERROR] Script failed at line $LINENO"; exit 1' ERR

# Logging function
log() {
  echo "[COMBINED][$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "Starting Combined Android & iOS workflow"

# Load dynamic variables
#if [ -f "lib/scripts/utils/load_vars.sh" ]; then
#  source lib/scripts/utils/load_vars.sh
#else
#  log "[WARN] Variable loader not found. Using environment variables."
#fi

# Debug print all key variables for Codemagic verification
log "[DEBUG] APP_NAME: $APP_NAME"
log "[DEBUG] PKG_NAME: $PKG_NAME"
log "[DEBUG] BUNDLE_ID: $BUNDLE_ID"
log "[DEBUG] VERSION_NAME: $VERSION_NAME"
log "[DEBUG] VERSION_CODE: $VERSION_CODE"
log "[DEBUG] ORG_NAME: $ORG_NAME"
log "[DEBUG] WEB_URL: $WEB_URL"
log "[DEBUG] EMAIL_ID: $EMAIL_ID"
log "[DEBUG] PUSH_NOTIFY: $PUSH_NOTIFY"
log "[DEBUG] IS_CHATBOT: $IS_CHATBOT"
log "[DEBUG] IS_DEEPLINK: $IS_DEEPLINK"
log "[DEBUG] IS_SPLASH: $IS_SPLASH"
log "[DEBUG] IS_PULLDOWN: $IS_PULLDOWN"
log "[DEBUG] IS_BOTTOMMENU: $IS_BOTTOMMENU"
log "[DEBUG] IS_LOAD_IND: $IS_LOAD_IND"
log "[DEBUG] IS_CAMERA: $IS_CAMERA"
log "[DEBUG] IS_LOCATION: $IS_LOCATION"
log "[DEBUG] IS_MIC: $IS_MIC"
log "[DEBUG] IS_NOTIFICATION: $IS_NOTIFICATION"
log "[DEBUG] IS_CONTACT: $IS_CONTACT"
log "[DEBUG] IS_BIOMETRIC: $IS_BIOMETRIC"
log "[DEBUG] IS_CALENDAR: $IS_CALENDAR"
log "[DEBUG] IS_STORAGE: $IS_STORAGE"
log "[DEBUG] LOGO_URL: $LOGO_URL"
log "[DEBUG] SPLASH: $SPLASH"
log "[DEBUG] SPLASH_BG: $SPLASH_BG"
log "[DEBUG] SPLASH_BG_COLOR: $SPLASH_BG_COLOR"
log "[DEBUG] SPLASH_TAGLINE: $SPLASH_TAGLINE"
log "[DEBUG] SPLASH_TAGLINE_COLOR: $SPLASH_TAGLINE_COLOR"
log "[DEBUG] SPLASH_ANIMATION: $SPLASH_ANIMATION"
log "[DEBUG] SPLASH_DURATION: $SPLASH_DURATION"
log "[DEBUG] BOTTOMMENU_ITEMS: $BOTTOMMENU_ITEMS"
log "[DEBUG] BOTTOMMENU_BG_COLOR: $BOTTOMMENU_BG_COLOR"
log "[DEBUG] BOTTOMMENU_ICON_COLOR: $BOTTOMMENU_ICON_COLOR"
log "[DEBUG] BOTTOMMENU_TEXT_COLOR: $BOTTOMMENU_TEXT_COLOR"
log "[DEBUG] BOTTOMMENU_FONT: $BOTTOMMENU_FONT"
log "[DEBUG] BOTTOMMENU_FONT_SIZE: $BOTTOMMENU_FONT_SIZE"
log "[DEBUG] BOTTOMMENU_FONT_BOLD: $BOTTOMMENU_FONT_BOLD"
log "[DEBUG] BOTTOMMENU_FONT_ITALIC: $BOTTOMMENU_FONT_ITALIC"
log "[DEBUG] BOTTOMMENU_ACTIVE_TAB_COLOR: $BOTTOMMENU_ACTIVE_TAB_COLOR"
log "[DEBUG] BOTTOMMENU_ICON_POSITION: $BOTTOMMENU_ICON_POSITION"
log "[DEBUG] BOTTOMMENU_VISIBLE_ON: $BOTTOMMENU_VISIBLE_ON"
log "[DEBUG] firebase_config_android: $firebase_config_android"
log "[DEBUG] firebase_config_ios: $firebase_config_ios"
log "[DEBUG] APPLE_TEAM_ID: $APPLE_TEAM_ID"
log "[DEBUG] APNS_KEY_ID: $APNS_KEY_ID"
log "[DEBUG] APNS_AUTH_KEY_URL: $APNS_AUTH_KEY_URL"
log "[DEBUG] CERT_PASSWORD: $CERT_PASSWORD"
log "[DEBUG] PROFILE_URL: $PROFILE_URL"
log "[DEBUG] CERT_CER_URL: $CERT_CER_URL"
log "[DEBUG] CERT_KEY_URL: $CERT_KEY_URL"
log "[DEBUG] APP_STORE_CONNECT_KEY_IDENTIFIER: $APP_STORE_CONNECT_KEY_IDENTIFIER"
log "[DEBUG] KEY_STORE: $KEY_STORE"
log "[DEBUG] CM_KEYSTORE_PASSWORD: $CM_KEYSTORE_PASSWORD"
log "[DEBUG] CM_KEY_ALIAS: $CM_KEY_ALIAS"
log "[DEBUG] CM_KEY_PASSWORD: $CM_KEY_PASSWORD"

# Validate required variables (minimal set for both platforms)
REQUIRED_VARS=(APP_ID APP_NAME PKG_NAME BUNDLE_ID VERSION_NAME VERSION_CODE OUTPUT_DIR)
for var in "${REQUIRED_VARS[@]}"; do
  if [ -z "${!var:-}" ]; then
    log "[ERROR] Required variable $var is not set."
    exit 1
  fi
done

# Clean old APK/AAB/IPA files before build
log "Cleaning old APK/AAB/IPA files in $OUTPUT_DIR/android/ and $OUTPUT_DIR/ios/ ..."
rm -f "$OUTPUT_DIR/android/"*.apk "$OUTPUT_DIR/android/"*.aab "$OUTPUT_DIR/ios/"*.ipa || true

# --- Dynamic App Name & Package/Bundle ID Injection (Combined) ---
if [ -n "${APP_NAME:-}" ]; then
  sed -i '' "s/android:label=\"[^"]*\"/android:label=\"$APP_NAME\"/g" android/app/src/main/AndroidManifest.xml
  /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $APP_NAME" ios/Runner/Info.plist || true
  /usr/libexec/PlistBuddy -c "Set :CFBundleName $APP_NAME" ios/Runner/Info.plist || true
  sed -i '' "s/PRODUCT_NAME = .*/PRODUCT_NAME = $APP_NAME/" macos/Runner/Configs/AppInfo.xcconfig || true
fi
if [ -n "${PKG_NAME:-}" ]; then
  sed -i '' "s/applicationId = \"[^"]*\"/applicationId = \"$PKG_NAME\"/g" android/app/build.gradle.kts
  sed -i '' "s/namespace = \"[^"]*\"/namespace = \"$PKG_NAME\"/g" android/app/build.gradle.kts
  PKG_PATH=$(echo $PKG_NAME | tr '.' '/')
  if [ -d "android/app/src/main/kotlin" ]; then
    find android/app/src/main/kotlin -type f -name '*.kt' -exec sed -i '' "s/^package .*/package $PKG_NAME/g" {} +
  fi
fi
if [ -n "${BUNDLE_ID:-}" ]; then
  sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = .*/PRODUCT_BUNDLE_IDENTIFIER = $BUNDLE_ID/" macos/Runner/Configs/AppInfo.xcconfig || true
fi

# 1. Android logic
log "Running Android logic..."
bash lib/scripts/android/main.sh

# 2. iOS logic
log "Running iOS logic..."
bash lib/scripts/ios/main.sh

log "Combined workflow completed. Artifacts in output/android/ and output/ios/"

# Source email variables
if [ -f "lib/scripts/utils/variables.sh" ]; then
  source lib/scripts/utils/variables.sh
fi

# Function to send notification email
send_notification() {
  local status="$1"
  local apk_url="$2"
  local aab_url="$3"
  local ipa_url="$4"
  local log_url="$5"
  local resume_url="$6"
  bash lib/scripts/utils/send_email.sh "$status" "Combined" "$apk_url" "$aab_url" "$ipa_url" "$log_url" "$resume_url"
}

trap 'send_notification "Failed" "" "" "" "$BUILD_LOG_URL" "$RESUME_URL"; exit 1' ERR

# After successful build, send success notification
APK_URL=$(find "$OUTPUT_DIR/android/" -name '*.apk' | head -n 1)
AAB_URL=$(find "$OUTPUT_DIR/android/" -name '*.aab' | head -n 1)
IPA_URL=$(find "$OUTPUT_DIR/ios/" -name '*.ipa' | head -n 1)
BUILD_LOG_URL="${BUILD_LOG_URL:-#}"
RESUME_URL="${RESUME_URL:-#}"
send_notification "Success" "$APK_URL" "$AAB_URL" "$IPA_URL" "$BUILD_LOG_URL" "$RESUME_URL"

exit 0 