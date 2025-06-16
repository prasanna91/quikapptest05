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
if [ -f "lib/scripts/utils/load_vars.sh" ]; then
  source lib/scripts/utils/load_vars.sh
else
  log "[WARN] Variable loader not found. Using environment variables."
fi

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

# Detect workflow type
WORKFLOW_ID_LOWER=$(echo "${WORKFLOW_ID:-android-free}" | tr '[:upper:]' '[:lower:]')

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