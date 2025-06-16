#!/bin/bash
set -euo pipefail
trap 'echo "[ERROR] Script failed at line $LINENO"; exit 1' ERR

# Logging function
log() {
  echo "[ANDROID][$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "Starting Android-Free workflow (no Firebase, no Keystore)"

# Load dynamic variables (from API or admin config)
# Example: source lib/scripts/utils/load_vars.sh
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

# Validate required variables
REQUIRED_VARS=(APP_ID APP_NAME PKG_NAME VERSION_NAME VERSION_CODE OUTPUT_DIR)
for var in "${REQUIRED_VARS[@]}"; do
  if [ -z "${!var:-}" ]; then
    log "[ERROR] Required variable $var is not set."
    exit 1
  fi
done

# Prepare output directory
mkdir -p "$OUTPUT_DIR/android"

# Clean old APK/AAB files before build
log "Cleaning old APK/AAB files in $OUTPUT_DIR/android/ ..."
rm -f "$OUTPUT_DIR/android/"*.apk "$OUTPUT_DIR/android/"*.aab || true

# Branding, splash, and icon
if [ -f "lib/scripts/android/branding.sh" ]; then
  bash lib/scripts/android/branding.sh
fi

# Firebase (if enabled)
if [ -f "lib/scripts/android/firebase.sh" ]; then
  bash lib/scripts/android/firebase.sh
fi

# Permissions
if [ -f "lib/scripts/android/permissions.sh" ]; then
  bash lib/scripts/android/permissions.sh
fi

# Dart variable injection
echo "[DART ENV] Generating Dart env file..."
bash lib/scripts/utils/gen_dart_env.sh

# Determine workflow based on PUSH_NOTIFY and KEY_STORE
WORKFLOW_ID_LOWER=""
if [[ "${PUSH_NOTIFY,,}" == "true" && -z "${KEY_STORE}" ]]; then
  WORKFLOW_ID_LOWER="android-paid"
elif [[ "${PUSH_NOTIFY,,}" == "true" && -n "${KEY_STORE}" ]]; then
  WORKFLOW_ID_LOWER="android-publish"
elif [[ "${PUSH_NOTIFY,,}" != "true" && -z "${KEY_STORE}" ]]; then
  WORKFLOW_ID_LOWER="android-free"
else
  WORKFLOW_ID_LOWER="android-free"
fi

if [[ "$WORKFLOW_ID_LOWER" == "android-paid" ]]; then
  log "Android-Paid workflow: Firebase enabled, Keystore disabled."
  # Load Firebase config
  if [ -f "lib/scripts/android/firebase.sh" ]; then
    log "Injecting Firebase config..."
    bash lib/scripts/android/firebase.sh
  else
    log "[WARN] Firebase sub-script not found. Skipping Firebase injection."
  fi
fi

# Function to send keystore guidance email
send_keystore_guidance() {
  bash lib/scripts/utils/send_email.sh "Keystore Error" "Android-Publish" "" "" "" "#" "#" "keystore_guidance"
}

if [[ "$WORKFLOW_ID_LOWER" == "android-publish" ]]; then
  log "Android-Publish workflow: Firebase and Keystore enabled."
  # Load Firebase config
  if [ -f "lib/scripts/android/firebase.sh" ]; then
    log "Injecting Firebase config..."
    bash lib/scripts/android/firebase.sh
  else
    log "[WARN] Firebase sub-script not found. Skipping Firebase injection."
  fi
  # Load Keystore only if KEY_STORE is set and looks like a URL or file
  if [ -n "${KEY_STORE:-}" ]; then
    if [[ "$KEY_STORE" =~ ^https?:// ]] || [[ -f "$KEY_STORE" ]]; then
      if [ -f "lib/scripts/android/keystore.sh" ]; then
        log "Injecting Keystore..."
        if ! bash lib/scripts/android/keystore.sh; then
          log "[ERROR] Keystore injection failed. Sending guidance email."
          send_keystore_guidance
          exit 1
        fi
      else
        log "[WARN] Keystore sub-script not found. Skipping Keystore injection."
      fi
    else
      log "[ERROR] KEY_STORE is set but not a valid URL or file. Sending guidance email."
      send_keystore_guidance
      exit 1
    fi
  else
    log "[ERROR] KEY_STORE is not set. Sending guidance email."
    send_keystore_guidance
    exit 1
  fi
  # Build APK and AAB
  log "Building APK (release mode, signed)"
  cd android
  ./gradlew assembleRelease
  log "Building AAB (release mode, signed)"
  ./gradlew bundleRelease
  cd ..
  # Copy APK and AAB to output directory
  APK_PATH=$(find android/app/build/outputs/apk/release -name '*.apk' | head -n 1)
  AAB_PATH=$(find android/app/build/outputs/bundle/release -name '*.aab' | head -n 1)
  if [ -f "$APK_PATH" ]; then
    cp "$APK_PATH" "$OUTPUT_DIR/android/"
    log "APK copied to $OUTPUT_DIR/android/"
  else
    log "[ERROR] APK not found after build."
    exit 1
  fi
  if [ -f "$AAB_PATH" ]; then
    cp "$AAB_PATH" "$OUTPUT_DIR/android/"
    log "AAB copied to $OUTPUT_DIR/android/"
  else
    log "[ERROR] AAB not found after build."
    exit 1
  fi
  log "Android-Publish workflow completed successfully."
  exit 0
fi

# Build APK (no Firebase, no Keystore)
log "Building APK (debug mode, unsigned)"
cd android
./gradlew assembleDebug
cd ..

# Copy APK to output directory
APK_PATH=""
if [ -f "build/app/outputs/flutter-apk/app-debug.apk" ]; then
  APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"
elif [ -f "android/app/build/outputs/apk/debug/app-debug.apk" ]; then
  APK_PATH="android/app/build/outputs/apk/debug/app-debug.apk"
fi
if [ -n "$APK_PATH" ] && [ -f "$APK_PATH" ]; then
  cp "$APK_PATH" "$OUTPUT_DIR/android/"
  log "APK copied to $OUTPUT_DIR/android/"
else
  log "[ERROR] APK not found after build."
  exit 1
fi

# Source email variables
if [ -f "lib/scripts/utils/variables.sh" ]; then
  source lib/scripts/utils/variables.sh
fi

# Function to send notification email
send_notification() {
  local status="$1"
  local apk_url="$2"
  local aab_url="$3"
  local log_url="$4"
  local resume_url="$5"
  bash lib/scripts/utils/send_email.sh "$status" "Android" "$apk_url" "$aab_url" "" "$log_url" "$resume_url"
}

trap 'send_notification "Failed" "" "" "$BUILD_LOG_URL" "$RESUME_URL"; exit 1' ERR

# After successful build, send success notification
APK_URL=$(find "$OUTPUT_DIR/android/" -name '*.apk' | head -n 1)
AAB_URL=$(find "$OUTPUT_DIR/android/" -name '*.aab' | head -n 1)
BUILD_LOG_URL="${BUILD_LOG_URL:-#}"
RESUME_URL="${RESUME_URL:-#}"
send_notification "Success" "$APK_URL" "$AAB_URL" "$BUILD_LOG_URL" "$RESUME_URL"

# --- Dynamic App Name & Package ID Injection (Android) ---
if [ -n "${APP_NAME:-}" ]; then
  sed -i '' "s/android:label=\"[^"]*\"/android:label=\"$APP_NAME\"/g" android/app/src/main/AndroidManifest.xml
fi
if [ -n "${PKG_NAME:-}" ]; then
  sed -i '' "s/applicationId = \"[^"]*\"/applicationId = \"$PKG_NAME\"/g" android/app/build.gradle.kts
  sed -i '' "s/namespace = \"[^"]*\"/namespace = \"$PKG_NAME\"/g" android/app/build.gradle.kts
  # Update package in MainActivity.kt if needed
  PKG_PATH=$(echo $PKG_NAME | tr '.' '/')
  if [ -d "android/app/src/main/kotlin" ]; then
    find android/app/src/main/kotlin -type f -name '*.kt' -exec sed -i '' "s/^package .*/package $PKG_NAME/g" {} +
  fi
fi

log "Android-Free workflow completed successfully."
exit 0 