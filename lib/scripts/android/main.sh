#!/bin/bash
set -e

# Load environment variables
source ./lib/config/admin_config.env

# Log function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Error handling
handle_error() {
    log "❌ Error: $1"
    # Send failure email
    bash ./lib/scripts/utils/send_email.sh "failure" "$1"
    exit 1
}

# Trap errors
trap 'handle_error "Build failed at line $LINENO"' ERR

# Start build
log "🚀 Starting Android build workflow for $APP_NAME"

# Validate required variables
if [ -z "$VERSION_NAME" ] || [ -z "$VERSION_CODE" ] || [ -z "$APP_NAME" ] || [ -z "$PKG_NAME" ]; then
    handle_error "Missing required variables"
fi

# Create output directory
mkdir -p output/android

# Run sub-scripts
log "📦 Running branding script..."
bash ./lib/scripts/android/branding.sh || handle_error "Branding script failed"

if [ "$PUSH_NOTIFY" = "true" ]; then
    log "🔥 Running Firebase script..."
    bash ./lib/scripts/android/firebase.sh || handle_error "Firebase script failed"
fi

if [ "$USE_KEYSTORE" = "true" ]; then
    log "🔑 Running keystore script..."
    bash ./lib/scripts/android/keystore.sh || handle_error "Keystore script failed"
fi

# Build APK
log "🏗️ Building APK..."
flutter clean
flutter pub get
flutter build apk --release || handle_error "APK build failed"

# Build AAB if enabled
if [ "$BUILD_AAB" = "true" ]; then
    log "📦 Building AAB..."
    flutter build appbundle --release || handle_error "AAB build failed"
fi

# Copy artifacts to output directory
log "📦 Copying artifacts to output directory..."
cp build/app/outputs/flutter-apk/app-release.apk output/android/
if [ "$BUILD_AAB" = "true" ]; then
    cp build/app/outputs/bundle/release/app-release.aab output/android/
fi

# Send success email
log "📧 Sending success email..."
bash ./lib/scripts/utils/send_email.sh "success" "Build completed successfully"

log "✅ Build completed successfully!"
exit 0 