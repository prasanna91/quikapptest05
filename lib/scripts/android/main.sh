#!/bin/bash
set -euo pipefail
trap 'echo "[ERROR] Script failed at line $LINENO"; exit 1' ERR

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export SCRIPT_DIR
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../../.." && pwd )"
export PROJECT_ROOT
UTILS_DIR="$PROJECT_ROOT/lib/scripts/utils"
export UTILS_DIR

# Define a log file for the entire build process
export BUILD_LOG_FILE="$PROJECT_ROOT/build_android_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$BUILD_LOG_FILE") 2>&1 # Redirect all stdout and stderr to the log file, and also to console

# Log the paths for debugging
echo "SCRIPT_DIR: $SCRIPT_DIR"
echo "PROJECT_ROOT: $PROJECT_ROOT"
echo "UTILS_DIR: $UTILS_DIR"

# Source common variables and utilities from config.sh
if [ -f "$UTILS_DIR/config.sh" ]; then
  echo "Found config.sh at $UTILS_DIR/config.sh"
  source "$UTILS_DIR/config.sh"
else
  echo "Error: config.sh not found at $UTILS_DIR/config.sh"
  ls -la "$UTILS_DIR"
  exit 1
fi

# Trap for errors to send failure notification
trap 'send_email_notification "failure" "Android build failed at line $LINENO." "$BUILD_LOG_FILE"' ERR

# Logging function
log() {
  echo "[ANDROID][$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Source local environment variables if available (for local development/testing)
# These will override defaults from config.sh
if [ -f "$PROJECT_ROOT/lib/config/env.sh" ]; then
  log "Sourcing local environment variables from lib/config/env.sh"
  source "$PROJECT_ROOT/lib/config/env.sh"
else
  log "lib/config/env.sh not found. Using Codemagic environment variables."
fi

# Export all variables needed by sub-scripts if not already exported
export APP_NAME
export PKG_NAME
export VERSION_NAME
export VERSION_CODE
export ORG_NAME
export WEB_URL
export EMAIL_ID
export PUSH_NOTIFY
export IS_CHATBOT
export IS_DEEPLINK
export IS_SPLASH
export IS_PULLDOWN
export IS_BOTTOMMENU
export IS_LOAD_IND
export IS_CAMERA
export IS_LOCATION
export IS_MIC
export IS_NOTIFICATION
export IS_CONTACT
export IS_BIOMETRIC
export IS_CALENDAR
export IS_STORAGE
export LOGO_URL
export SPLASH
export SPLASH_BG
export SPLASH_BG_COLOR
export SPLASH_TAGLINE
export SPLASH_TAGLINE_COLOR
export SPLASH_ANIMATION
export SPLASH_DURATION
export BOTTOMMENU_ITEMS
export BOTTOMMENU_BG_COLOR
export BOTTOMMENU_ICON_COLOR
export BOTTOMMENU_TEXT_COLOR
export BOTTOMMENU_FONT
export BOTTOMMENU_FONT_SIZE
export BOTTOMMENU_FONT_BOLD
export BOTTOMMENU_FONT_ITALIC
export BOTTOMMENU_ACTIVE_TAB_COLOR
export BOTTOMMENU_ICON_POSITION
export BOTTOMMENU_VISIBLE_ON
export firebase_config_android
export firebase_config_ios
export KEY_STORE
export CM_KEYSTORE_PASSWORD
export CM_KEY_ALIAS
export CM_KEY_PASSWORD
export USE_KEYSTORE
export BUILD_AAB
export EMAIL_SMTP_SERVER
export EMAIL_SMTP_PORT
export EMAIL_SMTP_USER
export EMAIL_SMTP_PASS
export PROJECT_ROOT
export ANDROID_ROOT
export ASSETS_DIR
export OUTPUT_DIR
export TEMP_DIR
export ANDROID_MANIFEST_PATH
export ANDROID_BUILD_GRADLE_PATH
export ANDROID_KEY_PROPERTIES_PATH
export ANDROID_FIREBASE_CONFIG_PATH
export ANDROID_MIPMAP_DIR
export ANDROID_DRAWABLE_DIR
export APK_OUTPUT_PATH
export AAB_OUTPUT_PATH

# Debug: Display important environment variables
log "=== Environment Variables Debug ==="
log "App Info:"
log "  APP_NAME: ${APP_NAME:-[NOT SET]}"
log "  VERSION_NAME: ${VERSION_NAME:-[NOT SET]}"
log "  VERSION_CODE: ${VERSION_CODE:-[NOT SET]}"
log "  PKG_NAME: ${PKG_NAME:-[NOT SET]}"
log "  BUNDLE_ID: ${BUNDLE_ID:-[NOT SET]}"

log "Organization:"
log "  ORG_NAME: ${ORG_NAME:-[NOT SET]}"
log "  WEB_URL: ${WEB_URL:-[NOT SET]}"
log "  EMAIL_ID: ${EMAIL_ID:-[NOT SET]}"

log "Feature Flags:"
log "  PUSH_NOTIFY: ${PUSH_NOTIFY:-[NOT SET]}"
log "  IS_CHATBOT: ${IS_CHATBOT:-[NOT SET]}"
log "  IS_DEEPLINK: ${IS_DEEPLINK:-[NOT SET]}"
log "  IS_SPLASH: ${IS_SPLASH:-[NOT SET]}"
log "  IS_PULLDOWN: ${IS_PULLDOWN:-[NOT SET]}"
log "  IS_BOTTOMMENU: ${IS_BOTTOMMENU:-[NOT SET]}"
log "  IS_LOAD_IND: ${IS_LOAD_IND:-[NOT SET]}"

log "Permissions:"
log "  IS_CAMERA: ${IS_CAMERA:-[NOT SET]}"
log "  IS_LOCATION: ${IS_LOCATION:-[NOT SET]}"
log "  IS_MIC: ${IS_MIC:-[NOT SET]}"
log "  IS_NOTIFICATION: ${IS_NOTIFICATION:-[NOT SET]}"
log "  IS_CONTACT: ${IS_CONTACT:-[NOT SET]}"
log "  IS_BIOMETRIC: ${IS_BIOMETRIC:-[NOT SET]}"
log "  IS_CALENDAR: ${IS_CALENDAR:-[NOT SET]}"
log "  IS_STORAGE: ${IS_STORAGE:-[NOT SET]}"

log "UI/Branding:"
log "  LOGO_URL: ${LOGO_URL:-[NOT SET]}"
log "  SPLASH_URL: ${SPLASH_URL:-[NOT SET]}"
log "  SPLASH_BG: ${SPLASH_BG:-[NOT SET]}"
log "  SPLASH_BG_COLOR: ${SPLASH_BG_COLOR:-[NOT SET]}"
log "  SPLASH_TAGLINE: ${SPLASH_TAGLINE:-[NOT SET]}"
log "  SPLASH_TAGLINE_COLOR: ${SPLASH_TAGLINE_COLOR:-[NOT SET]}"
log "  SPLASH_ANIMATION: ${SPLASH_ANIMATION:-[NOT SET]}"
log "  SPLASH_DURATION: ${SPLASH_DURATION:-[NOT SET]}"

if [ "${IS_BOTTOMMENU:-}" = "true" ]; then
  log "Bottom Menu Config:"
  log "  BOTTOMMENU_ITEMS: ${BOTTOMMENU_ITEMS:-[NOT SET]}"
  log "  BOTTOMMENU_BG_COLOR: ${BOTTOMMENU_BG_COLOR:-[NOT SET]}"
  log "  BOTTOMMENU_ICON_COLOR: ${BOTTOMMENU_ICON_COLOR:-[NOT SET]}"
  log "  BOTTOMMENU_TEXT_COLOR: ${BOTTOMMENU_TEXT_COLOR:-[NOT SET]}"
  log "  BOTTOMMENU_FONT: ${BOTTOMMENU_FONT:-[NOT SET]}"
  log "  BOTTOMMENU_FONT_SIZE: ${BOTTOMMENU_FONT_SIZE:-[NOT SET]}"
  log "  BOTTOMMENU_FONT_BOLD: ${BOTTOMMENU_FONT_BOLD:-[NOT SET]}"
  log "  BOTTOMMENU_FONT_ITALIC: ${BOTTOMMENU_FONT_ITALIC:-[NOT SET]}"
  log "  BOTTOMMENU_ACTIVE_TAB_COLOR: ${BOTTOMMENU_ACTIVE_TAB_COLOR:-[NOT SET]}"
  log "  BOTTOMMENU_ICON_POSITION: ${BOTTOMMENU_ICON_POSITION:-[NOT SET]}"
  log "  BOTTOMMENU_VISIBLE_ON: ${BOTTOMMENU_VISIBLE_ON:-[NOT SET]}"
fi

log "Firebase Config:"
log "  FIREBASE_CONFIG_ANDROID: ${FIREBASE_CONFIG_ANDROID:-[NOT SET]}"
log "  FIREBASE_CONFIG_IOS: ${FIREBASE_CONFIG_IOS:-[NOT SET]}"

log "iOS Signing:"
log "  APPLE_TEAM_ID: ${APPLE_TEAM_ID:-[NOT SET]}"
log "  APNS_KEY_ID: ${APNS_KEY_ID:-[NOT SET]}"
log "  APNS_AUTH_KEY_URL: ${APNS_AUTH_KEY_URL:-[NOT SET]}"
log "  CERT_PASSWORD: ${CERT_PASSWORD:-[NOT SET]}"
log "  PROFILE_URL: ${PROFILE_URL:-[NOT SET]}"
log "  CERT_CER_URL: ${CERT_CER_URL:-[NOT SET]}"
log "  CERT_KEY_URL: ${CERT_KEY_URL:-[NOT SET]}"
log "  APP_STORE_CONNECT_KEY_IDENTIFIER: ${APP_STORE_CONNECT_KEY_IDENTIFIER:-[NOT SET]}"

log "Android Keystore:"
log "  KEY_STORE: ${KEY_STORE:-[NOT SET]}"
log "  CM_KEYSTORE_PASSWORD: ${CM_KEYSTORE_PASSWORD:-[NOT SET]}"
log "  CM_KEY_ALIAS: ${CM_KEY_ALIAS:-[NOT SET]}"
log "  CM_KEY_PASSWORD: ${CM_KEY_PASSWORD:-[NOT SET]}"
log "=== End Environment Variables Debug ==="

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to validate Flutter environment
validate_flutter_env() {
  log "Validating Flutter environment..."
  
  # Check if Flutter is installed
  if ! command_exists flutter; then
    log "Flutter is not installed or not in PATH"
    log "Please install Flutter from https://flutter.dev/docs/get-started/install"
    log "After installation, make sure to add Flutter to your PATH"
    exit 1
  fi
  
  # Check Flutter version
  local flutter_version
  flutter_version=$(flutter --version 2>/dev/null | grep -o "Flutter [0-9]\+\.[0-9]\+\.[0-9]\+" | cut -d' ' -f2)
  if [ -z "$flutter_version" ]; then
    log "Failed to get Flutter version"
    exit 1
  fi
  
  log "Flutter version: $flutter_version"
  
  # Check if Flutter is properly configured
  if ! flutter doctor >/dev/null 2>&1; then
    log "Flutter is not properly configured. Please run 'flutter doctor' for details"
    exit 1
  fi
  
  log "Flutter environment validation completed successfully"
}

# Function to check Flutter version
check_flutter_version() {
  log "Checking Flutter version..."
  flutter --version
}

# Function to prepare Flutter project
prepare_flutter_project() {
  log "Preparing Flutter project..."
  
  # Check if pubspec.yaml exists
  if [ ! -f "$PROJECT_ROOT/pubspec.yaml" ]; then
    log "pubspec.yaml not found. Creating new Flutter project..."
    cd "$PROJECT_ROOT"
    flutter create . --platforms=android
  fi
  
  # Update version in pubspec.yaml
  log "Updating version in pubspec.yaml..."
  local version_string="${VERSION_NAME}+${VERSION_CODE}"
  sed -i.bak "s/^version: .*/version: $version_string/" "$PROJECT_ROOT/pubspec.yaml"
  rm -f "$PROJECT_ROOT/pubspec.yaml.bak"
  
  # Get dependencies
  log "Getting Flutter dependencies..."
  flutter pub get
  
  # Clean the project
  log "Cleaning Flutter project..."
  flutter clean
  
  # Update dependencies
  log "Updating Flutter dependencies..."
  flutter pub upgrade
  
  # Get dependencies again after upgrade
  log "Getting Flutter dependencies after upgrade..."
  flutter pub get
  
  log "Flutter project preparation completed successfully"
}

# Main setup sequence
log "Starting Flutter environment setup..."

# Send build start notification
send_email_notification "started" "" "" "" ""

# Validate Flutter environment
validate_flutter_env

# Check Flutter version (now just logs the version)
check_flutter_version

# Prepare Flutter project
#prepare_flutter_project

log "Flutter environment setup completed successfully."
# Send success email with artifacts
send_email_notification "success" "" "" "$APK_OUTPUT_PATH" "$AAB_OUTPUT_PATH"

# Determine workflow based on variables
WORKFLOW_TYPE="android-free" # Default workflow
WORKFLOW_VERSION="1.0.0" # Default workflow version (can be updated dynamically)

# Check for Firebase configuration to determine workflow
if [ -n "${firebase_config_android:-}" ]; then
  WORKFLOW_TYPE="android-paid"
  log "Firebase config detected. Setting workflow to: $WORKFLOW_TYPE"
fi

# Check for Keystore configuration to determine workflow
if [ -n "${KEY_STORE:-}" ]; then
  WORKFLOW_TYPE="android-publish"
  log "Keystore detected. Setting workflow to: $WORKFLOW_TYPE"
fi

# Update workflow version based on PUSH_NOTIFY and KEY_STORE
if [ "${PUSH_NOTIFY:-false}" = "true" ] && [ -z "${KEY_STORE:-}" ]; then
  WORKFLOW_VERSION="android-push-notify.yml" # Example: a specific workflow version if only push notify
elif [ "${PUSH_NOTIFY:-false}" = "true" ] && [ -n "${KEY_STORE:-}" ]; then
  WORKFLOW_VERSION="android-publish-push.yml" # Example: a specific workflow version if push notify and keystore
elif [ "${PUSH_NOTIFY:-false}" = "false" ] && [ -z "${KEY_STORE:-}" ]; then
  WORKFLOW_VERSION="android-free.yml" # Default free workflow
elif [ "${PUSH_NOTIFY:-false}" = "false" ] && [ -n "${KEY_STORE:-}" ]; then
  WORKFLOW_VERSION="android-publish-no-push.yml" # Example: a specific workflow version if keystore but no push
fi

# For simplicity, we are setting WORKFLOW_VERSION directly for demonstration. In a real scenario,
# this might be read from a Codemagic environment variable like CM_WORKFLOW_ID or calculated more dynamically.

log "Detected Android Workflow Type: $WORKFLOW_TYPE"
log "Calculated Workflow Version (example): $WORKFLOW_VERSION"

# Validate required variables (common across all workflows)
REQUIRED_VARS=(
  "APP_NAME"
  "PKG_NAME"
  "VERSION_NAME"
  "VERSION_CODE"
  "ORG_NAME"
  "WEB_URL"
  "EMAIL_ID"
)

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
rm -f "$OUTPUT_DIR/android/"*.apk || true
rm -f "$OUTPUT_DIR/android/"*.aab || true

# Branding, splash, and icon setup
log "Setting up branding and assets..."
if [ -f "lib/scripts/android/branding.sh" ]; then
  bash lib/scripts/android/branding.sh
else
  log "[WARN] Branding sub-script not found. Skipping branding setup."
fi

# Permissions setup
log "Setting up permissions..."
if [ -f "lib/scripts/android/permissions.sh" ]; then
  bash lib/scripts/android/permissions.sh
else
  log "[WARN] Permissions sub-script not found. Skipping permissions setup."
fi

# Function to download Firebase config
download_firebase_config() {
  log "Setting up Firebase..."
  if [ "${PUSH_NOTIFY:-}" = "true" ]; then
    log "PUSH_NOTIFY is true; setting up Firebase config..."
    log "Downloading google-services.json from URL..."
    
    # Ensure the URL is properly set
    if [ -z "${firebase_config_android:-}" ]; then
      log "[ERROR] Firebase configuration URL is not set"
      return 1
    fi
    
    # Remove any quotes from the URL
    local clean_url="${firebase_config_android//[\"']/}"
    log "Using URL: $clean_url"
    
    # Try curl first
    if command_exists curl; then
      if curl -L -o "$ANDROID_FIREBASE_CONFIG_PATH" "$clean_url"; then
        log "Successfully downloaded google-services.json using curl"
        return 0
      fi
    fi
    
    # Try wget if curl fails
    if command_exists wget; then
      if wget -O "$ANDROID_FIREBASE_CONFIG_PATH" "$clean_url"; then
        log "Successfully downloaded google-services.json using wget"
        return 0
      fi
    fi
    
    log "[ERROR] Failed to download google-services.json"
    return 1
  else
    log "PUSH_NOTIFY is false; skipping Firebase setup"
  fi
}

# Setting up Firebase
log "Setting up Firebase..."
if download_firebase_config; then
  # Remove existing google-services.json if present
  if [ -f "android/app/google-services.json" ]; then
    log "Removing existing google-services.json..."
    rm "android/app/google-services.json"
  fi

  # Create assets directory if it doesn't exist
  mkdir -p "assets"

  # Check if the config is a local file or URL
  if [ -f "${firebase_config_android}" ]; then
    # It's a local file, copy it directly
    log "Using local Firebase config file..."
    cp "${firebase_config_android}" "android/app/google-services.json"
    if [ $? -eq 0 ]; then
      log "Successfully copied local google-services.json"
      # Also copy to assets folder for Dart validation
      cp "${firebase_config_android}" "assets/google-services.json"
      log "Copied google-services.json to assets folder for Dart validation"
    else
      log "[ERROR] Failed to copy local google-services.json"
      exit 1
    fi
  else
    # It's a URL, try downloading with curl first, then wget
    log "Downloading google-services.json from URL..."
    MAX_RETRIES=3
    RETRY_COUNT=0
    SUCCESS=false

    # URL encode the Firebase config URL
    ENCODED_URL=$(echo "${firebase_config_android}" | sed 's/ /%20/g' | sed 's/(/%28/g' | sed 's/)/%29/g')
    log "Using encoded URL: ${ENCODED_URL}"

    # Try curl first
    while [ $RETRY_COUNT -lt $MAX_RETRIES ] && [ "$SUCCESS" = false ]; do
      if curl -L -o "android/app/google-services.json" "${ENCODED_URL}"; then
        SUCCESS=true
        log "Successfully downloaded google-services.json using curl"
      else
        RETRY_COUNT=$((RETRY_COUNT + 1))
        if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
          log "[WARN] Failed to download with curl (attempt $RETRY_COUNT of $MAX_RETRIES). Retrying..."
          sleep 2
        fi
      fi
    done

    # If curl failed, try wget
    if [ "$SUCCESS" = false ]; then
      log "Curl failed, trying wget..."
      RETRY_COUNT=0
      while [ $RETRY_COUNT -lt $MAX_RETRIES ] && [ "$SUCCESS" = false ]; do
        if wget -O "android/app/google-services.json" "${ENCODED_URL}"; then
          SUCCESS=true
          log "Successfully downloaded google-services.json using wget"
        else
          RETRY_COUNT=$((RETRY_COUNT + 1))
          if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
            log "[WARN] Failed to download with wget (attempt $RETRY_COUNT of $MAX_RETRIES). Retrying..."
            sleep 2
          fi
        fi
      done
    fi

    if [ "$SUCCESS" = true ]; then
      # Copy to assets folder for Dart validation
      cp "android/app/google-services.json" "assets/google-services.json"
      log "Copied google-services.json to assets folder for Dart validation"
    else
      log "[ERROR] Failed to download google-services.json after all attempts."
      log "[ERROR] Original URL: ${firebase_config_android}"
      log "[ERROR] Encoded URL: ${ENCODED_URL}"
      exit 1
    fi
  fi
else
  log "Firebase setup failed."
  exit 1
fi

# Keystore setup (if KEY_STORE is set)
if [ -n "${KEY_STORE:-}" ]; then
  log "Setting up Keystore..."
  if [ -f "lib/scripts/android/signing.sh" ]; then
    bash lib/scripts/android/signing.sh
  else
    log "[WARN] Signing sub-script not found. Skipping Keystore setup."
  fi
else
  log "KEY_STORE is not set; skipping Keystore setup."
fi

# Dart variable injection
log "Generating Dart environment variables..."
bash lib/scripts/utils/gen_dart_env.sh

# Check and create Android directory structure if needed
if [ ! -d "android" ]; then
  log "Android directory not found. Creating Flutter Android project..."
  flutter create . --platforms=android
fi

# Dynamic App Name & Package Name Injection (Android)
log "Updating app name and package ID..."
if [ -n "${APP_NAME:-}" ]; then
  if [ -f "android/app/src/main/AndroidManifest.xml" ]; then
    sed -i '' "s#android:label=\"[^\"]*\"#android:label=\"$APP_NAME\"#g" android/app/src/main/AndroidManifest.xml || true
  else
    log "[WARN] AndroidManifest.xml not found. Skipping app name update."
  fi
fi

if [ -n "${PKG_NAME:-}" ]; then
  # Update package name in build.gradle
  if [ -f "android/app/build.gradle" ]; then
    sed -i '' "s#applicationId \"[^\"]*\"#applicationId \"$PKG_NAME\"#g" android/app/build.gradle || true
    sed -i '' "s#namespace \"[^\"]*\"#namespace \"$PKG_NAME\"#g" android/app/build.gradle || true
  else
    log "[WARN] build.gradle not found. Skipping package name update in build.gradle."
  fi

  # Update package name in AndroidManifest.xml
  if [ -f "android/app/src/main/AndroidManifest.xml" ]; then
    sed -i '' "s#package=\"[^\"]*\"#package=\"$PKG_NAME\"#g" android/app/src/main/AndroidManifest.xml || true
  else
    log "[WARN] AndroidManifest.xml not found. Skipping package name update in AndroidManifest.xml."
  fi

  # Update package name in MainActivity.kt
  CURRENT_DIR=$(pwd)
  OLD_MAIN_ACTIVITY_PATH="$CURRENT_DIR/android/app/src/main/kotlin/com/example/quikapptest05/MainActivity.kt"
  NEW_PACKAGE_PATH=$(echo "$PKG_NAME" | sed 's/\./\//g') # Convert com.example.app to com/example/app
  NEW_MAIN_ACTIVITY_DIR="$CURRENT_DIR/android/app/src/main/kotlin/$NEW_PACKAGE_PATH"
  NEW_MAIN_ACTIVITY_FILE="$NEW_MAIN_ACTIVITY_DIR/MainActivity.kt"

  if [ -f "$OLD_MAIN_ACTIVITY_PATH" ]; then
    OLD_PACKAGE_IN_FILE="com.example.quikapptest05"
    # shellcheck disable=SC1078,SC1079
    # Create new package directory structure if it doesn't exist
    mkdir -p "$NEW_MAIN_ACTIVITY_DIR"

    # Move MainActivity.kt to the new package directory
    mv "$OLD_MAIN_ACTIVITY_PATH" "$NEW_MAIN_ACTIVITY_FILE" || true

    # Update package declaration in MainActivity.kt
    sed -i '' "s/package ${OLD_PACKAGE_IN_FILE}/package ${PKG_NAME}/g" "$NEW_MAIN_ACTIVITY_FILE" || true

    log "Updated package name in MainActivity.kt and moved to new directory."
  else
    log "[WARN] MainActivity.kt not found at expected path: $OLD_MAIN_ACTIVITY_PATH. Skipping package name update for this file."
  fi
fi

# Flutter build
log "Building Flutter Android app..."
# Use flutter build apk instead of flutter build android
flutter build apk --release

# --- Handle APK/AAB outputs ---
APK_OUTPUT_PATH="$OUTPUT_DIR/android/app-release.apk"
AAB_OUTPUT_PATH="$OUTPUT_DIR/android/app-release.aab"

# Find and rename APK/AAB files for consistency
find build/app/outputs/flutter-apk/ -name '*.apk' -exec mv {} "$APK_OUTPUT_PATH" \; || true
find build/app/outputs/bundle/release/ -name '*.aab' -exec mv {} "$AAB_OUTPUT_PATH" \; || true

log "Android build completed. Artifacts are in $OUTPUT_DIR/android/"

# Remove redundant notification logic
# The email is sent by the trap or the success call
# rm -f "$BUILD_LOG_FILE" # Only remove if the build is successful and email with log is not needed

log "Android workflow completed successfully."
exit 0 