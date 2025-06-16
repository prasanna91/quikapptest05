#!/bin/bash
set -euo pipefail
trap 'echo "[ERROR] Script failed at line $LINENO"; exit 1' ERR

# Logging function
log() {
  echo "[ANDROID][$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Source common variables with defaults
source lib/scripts/utils/variables.sh

# Source local environment variables if available (for local development/testing)
# These will override defaults from variables.sh
if [ -f "lib/config/env.sh" ]; then
  log "Sourcing local environment variables from lib/config/env.sh"
  # Note: `source` (or `.`) automatically exports variables when called directly
  source lib/config/env.sh
else
  log "lib/config/env.sh not found. Assuming Codemagic environment variables (CM_ENV) are present."
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

log "Starting Android build workflow..."

# Function to send email notification
send_notification() {
  local status=$1
  local message=$2
  local logs_url=$3
  
  # Get build info from environment variables
  local build_number=${BUILD_NUMBER:-"unknown"}
  local build_id=${BUILD_ID:-"unknown"}
  local project_name=${PROJECT_NAME:-"Flutter Project"}
  
  # Format email subject
  local subject="[${status}] ${project_name} Build #${build_number}"
  
  # Format email body
  local body="
Build Status: ${status}
Project: ${project_name}
Build Number: ${build_number}
Build ID: ${build_id}

${message}

View build logs: ${logs_url}
"
  
  # Send email using mail command if available
  if command -v mail &> /dev/null; then
    echo "${body}" | mail -s "${subject}" "${NOTIFICATION_EMAIL:-}"
  else
    log "[WARN] mail command not available. Skipping email notification."
    log "Would have sent:"
    log "Subject: ${subject}"
    log "Body: ${body}"
  fi
}

# Function to install specific Flutter version
install_flutter_version() {
  local version=$1
  log "Installing Flutter version $version..."
  
  # Create Flutter directory if it doesn't exist
  local flutter_dir="$HOME/flutter"
  mkdir -p "$flutter_dir"
  
  # Download Flutter SDK
  log "Downloading Flutter SDK version $version..."
  if curl -L "https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_$version-stable.zip" -o flutter.zip; then
    log "Download successful, extracting..."
    unzip -o flutter.zip -d "$HOME"
    rm flutter.zip
    
    # Add Flutter to PATH
    export PATH="$flutter_dir/bin:$PATH"
    
    # Run Flutter doctor to ensure everything is set up
    log "Running Flutter doctor..."
    flutter doctor -v
    
    # Verify installation
    if flutter --version | grep -q "Flutter $version"; then
      log "Successfully installed Flutter version $version"
      
      # Accept Android licenses
      log "Accepting Android licenses..."
      yes | flutter doctor --android-licenses
      
      # Pre-download Android SDK components
      log "Pre-downloading Android SDK components..."
      flutter precache --android
      
      return 0
    else
      log "[ERROR] Flutter version verification failed after installation"
      return 1
    fi
  else
    log "[ERROR] Failed to download Flutter SDK version $version"
    return 1
  fi
}

# Function to validate Flutter environment
validate_flutter_env() {
  log "Validating Flutter environment..."
  
  # Check Flutter installation
  if ! command -v flutter &> /dev/null; then
    log "[ERROR] Flutter is not installed or not in PATH"
    send_notification "FAILED" "Flutter is not installed or not in PATH" "${BUILD_URL:-}"
    exit 1
  fi

  # Check Flutter doctor
  log "Running Flutter doctor..."
  if ! flutter doctor -v; then
    log "[ERROR] Flutter doctor reported issues. Please fix them before proceeding."
    send_notification "FAILED" "Flutter doctor reported issues" "${BUILD_URL:-}"
    exit 1
  fi

  # Check Android toolchain
  if ! flutter doctor --android-licenses; then
    log "[WARN] Android licenses not accepted. Attempting to accept..."
    yes | flutter doctor --android-licenses || {
      log "[ERROR] Failed to accept Android licenses"
      send_notification "FAILED" "Failed to accept Android licenses" "${BUILD_URL:-}"
      exit 1
    }
  fi
}

# Function to check and set Flutter version
check_flutter_version() {
  log "Checking Flutter version..."
  
  # Get current Flutter version
  CURRENT_FLUTTER_VERSION=$(flutter --version | grep -o "Flutter [0-9]\+\.[0-9]\+\.[0-9]\+" | cut -d' ' -f2)
  log "Current Flutter version: $CURRENT_FLUTTER_VERSION"
  
  # Get current Dart version
  CURRENT_DART_VERSION=$(flutter --version | grep -o "Dart [0-9]\+\.[0-9]\+\.[0-9]\+" | cut -d' ' -f2)
  log "Current Dart version: $CURRENT_DART_VERSION"
  
  # Get required versions from pubspec.yaml
  if [ -f "pubspec.yaml" ]; then
    # Get Flutter SDK version
    REQUIRED_FLUTTER_VERSION=$(grep -A1 "sdk:" pubspec.yaml | grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+" || echo "")
    
    # Get Dart SDK version
    REQUIRED_DART_VERSION=$(grep -A2 "sdk:" pubspec.yaml | grep -o ">= [0-9]\+\.[0-9]\+\.[0-9]\+" | cut -d' ' -f2 || echo "")
    
    if [ -n "$REQUIRED_FLUTTER_VERSION" ]; then
      log "Required Flutter version from pubspec.yaml: $REQUIRED_FLUTTER_VERSION"
      log "Required Dart version from pubspec.yaml: $REQUIRED_DART_VERSION"
      
      # Check Flutter version
      if [ "$CURRENT_FLUTTER_VERSION" != "$REQUIRED_FLUTTER_VERSION" ]; then
        log "Flutter version mismatch. Attempting to install version $REQUIRED_FLUTTER_VERSION..."
        
        # Try direct installation first (most reliable in CI)
        if install_flutter_version "$REQUIRED_FLUTTER_VERSION"; then
          log "Successfully installed Flutter version $REQUIRED_FLUTTER_VERSION"
        else
          log "[ERROR] Failed to install Flutter version $REQUIRED_FLUTTER_VERSION"
          send_notification "FAILED" "Failed to install Flutter version $REQUIRED_FLUTTER_VERSION" "${BUILD_URL:-}"
          exit 1
        fi
      else
        log "Flutter version matches requirements"
      fi
      
      # Check Dart version
      if [ -n "$REQUIRED_DART_VERSION" ] && [ "$CURRENT_DART_VERSION" != "$REQUIRED_DART_VERSION" ]; then
        log "[WARN] Dart version mismatch. Current: $CURRENT_DART_VERSION, Required: $REQUIRED_DART_VERSION"
        log "This might cause issues. Consider updating your Flutter installation."
      fi
    else
      log "[WARN] Could not determine required Flutter version from pubspec.yaml"
    fi
  else
    log "[ERROR] pubspec.yaml not found"
    send_notification "FAILED" "pubspec.yaml not found" "${BUILD_URL:-}"
    exit 1
  fi
}

# Function to clean and prepare Flutter project
prepare_flutter_project() {
  log "Preparing Flutter project..."
  
  # Clean Flutter
  log "Cleaning Flutter project..."
  flutter clean || {
    log "[ERROR] Failed to clean Flutter project"
    send_notification "FAILED" "Failed to clean Flutter project" "${BUILD_URL:-}"
    exit 1
  }
  
  # Delete build directory if it exists
  if [ -d "build" ]; then
    log "Removing build directory..."
    rm -rf build
  fi
  
  # Delete .dart_tool directory if it exists
  if [ -d ".dart_tool" ]; then
    log "Removing .dart_tool directory..."
    rm -rf .dart_tool
  fi
  
  # Get dependencies
  log "Getting Flutter dependencies..."
  flutter pub get || {
    log "[ERROR] Failed to get Flutter dependencies"
    send_notification "FAILED" "Failed to get Flutter dependencies" "${BUILD_URL:-}"
    exit 1
  }
  
  # Verify pub get was successful
  if [ ! -f ".packages" ]; then
    log "[ERROR] .packages file not found after flutter pub get"
    send_notification "FAILED" ".packages file not found after flutter pub get" "${BUILD_URL:-}"
    exit 1
  fi
}

# Main setup sequence
log "Starting Flutter environment setup..."

# Validate Flutter environment
validate_flutter_env

# Check and set Flutter version
check_flutter_version

# Prepare Flutter project
prepare_flutter_project

log "Flutter environment setup completed successfully."
send_notification "SUCCESS" "Flutter environment setup completed successfully" "${BUILD_URL:-}"

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

# Setting up Firebase
log "Setting up Firebase..."
if [ "${PUSH_NOTIFY:-}" = "true" ]; then
  log "PUSH_NOTIFY is true; setting up Firebase config..."
  
  # Check if Firebase config is provided
  if [ -z "${firebase_config_android:-}" ]; then
    log "[ERROR] FIREBASE_CONFIG_ANDROID environment variable is not set"
    exit 1
  fi

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
  log "PUSH_NOTIFY is false; skipping Firebase config."
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
    # Create new package directory structure if it doesn't exist
    mkdir -p "$NEW_MAIN_ACTIVITY_DIR"

    # Move MainActivity.kt to the new package directory
    mv "$OLD_MAIN_ACTIVITY_PATH" "$NEW_MAIN_ACTIVITY_FILE" || true

    # Update package declaration in MainActivity.kt
    sed -i '' "s/package $OLD_PACKAGE_IN_FILE/package $PKG_NAME/g" "$NEW_MAIN_ACTIVITY_FILE" || true

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

# Send notification email (stub - will be implemented in send_email.sh)
log "Sending notification email..."

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
BUILD_LOG_URL="${BUILD_LOG_URL:-#}"
RESUME_URL="${RESUME_URL:-#}"

# Check if APK and/or AAB files exist before sending their URLs
ACTUAL_APK_URL=""
if [ -f "$APK_OUTPUT_PATH" ]; then
  ACTUAL_APK_URL="$CM_BUILD_WEB_URL/artifacts/$APK_OUTPUT_PATH"
fi

ACTUAL_AAB_URL=""
if [ -f "$AAB_OUTPUT_PATH" ]; then
  ACTUAL_AAB_URL="$CM_BUILD_WEB_URL/artifacts/$AAB_OUTPUT_PATH"
fi

send_notification "Success" "$ACTUAL_APK_URL" "$ACTUAL_AAB_URL" "$BUILD_LOG_URL" "$RESUME_URL"

log "Android workflow completed successfully."
exit 0 