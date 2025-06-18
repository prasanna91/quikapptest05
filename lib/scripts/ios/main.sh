#!/bin/bash
set -e

# Load environment variables from Codemagic
# These variables are injected by codemagic.yaml
APP_ID=${APP_ID}
WORKFLOW_ID=${WORKFLOW_ID}
BRANCH=${BRANCH}
VERSION_NAME=${VERSION_NAME}
VERSION_CODE=${VERSION_CODE}
APP_NAME=${APP_NAME}
ORG_NAME=${ORG_NAME}
WEB_URL=${WEB_URL}
EMAIL_ID=${EMAIL_ID}
BUNDLE_ID=${BUNDLE_ID}

# Feature flags
PUSH_NOTIFY=${PUSH_NOTIFY}
IS_CHATBOT=${IS_CHATBOT}
IS_DOMAIN_URL=${IS_DOMAIN_URL}
IS_SPLASH=${IS_SPLASH}
IS_PULLDOWN=${IS_PULLDOWN}
IS_BOTTOMMENU=${IS_BOTTOMMENU}
IS_LOAD_IND=${IS_LOAD_IND}

# Permissions
IS_CAMERA=${IS_CAMERA}
IS_LOCATION=${IS_LOCATION}
IS_MIC=${IS_MIC}
IS_NOTIFICATION=${IS_NOTIFICATION}
IS_CONTACT=${IS_CONTACT}
IS_BIOMETRIC=${IS_BIOMETRIC}
IS_CALENDAR=${IS_CALENDAR}
IS_STORAGE=${IS_STORAGE}

# Branding
LOGO_URL=${LOGO_URL}
SPLASH_URL=${SPLASH_URL}
SPLASH_BG_URL=${SPLASH_BG_URL}
SPLASH_BG_COLOR=${SPLASH_BG_COLOR}
SPLASH_TAGLINE=${SPLASH_TAGLINE}
SPLASH_TAGLINE_COLOR=${SPLASH_TAGLINE_COLOR}
SPLASH_ANIMATION=${SPLASH_ANIMATION}
SPLASH_DURATION=${SPLASH_DURATION}

# Bottom menu
BOTTOMMENU_ITEMS=${BOTTOMMENU_ITEMS}
BOTTOMMENU_BG_COLOR=${BOTTOMMENU_BG_COLOR}
BOTTOMMENU_ICON_COLOR=${BOTTOMMENU_ICON_COLOR}
BOTTOMMENU_TEXT_COLOR=${BOTTOMMENU_TEXT_COLOR}
BOTTOMMENU_FONT=${BOTTOMMENU_FONT}
BOTTOMMENU_FONT_SIZE=${BOTTOMMENU_FONT_SIZE}
BOTTOMMENU_FONT_BOLD=${BOTTOMMENU_FONT_BOLD}
BOTTOMMENU_FONT_ITALIC=${BOTTOMMENU_FONT_ITALIC}
BOTTOMMENU_ACTIVE_TAB_COLOR=${BOTTOMMENU_ACTIVE_TAB_COLOR}
BOTTOMMENU_ICON_POSITION=${BOTTOMMENU_ICON_POSITION}
BOTTOMMENU_VISIBLE_ON=${BOTTOMMENU_VISIBLE_ON}

# Firebase
FIREBASE_CONFIG_IOS=${FIREBASE_CONFIG_IOS}

# iOS Signing
APPLE_TEAM_ID=${APPLE_TEAM_ID}
APNS_KEY_ID=${APNS_KEY_ID}
APNS_AUTH_KEY_URL=${APNS_AUTH_KEY_URL}
CERT_PASSWORD=${CERT_PASSWORD}
PROFILE_URL=${PROFILE_URL}
CERT_CER_URL=${CERT_CER_URL}
CERT_KEY_URL=${CERT_KEY_URL}
APP_STORE_CONNECT_KEY_IDENTIFIER=${APP_STORE_CONNECT_KEY_IDENTIFIER}

# Logging function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Error handling function
handle_error() {
    log "ERROR: $1"
    exit 1
}

# Set up error handling
trap 'handle_error "Error occurred at line $LINENO"' ERR

# Start iOS build
log "Starting iOS build for $APP_NAME"

# Validate required variables
if [ -z "$BUNDLE_ID" ] || [ -z "$VERSION_NAME" ] || [ -z "$VERSION_CODE" ]; then
    handle_error "Missing required variables"
fi

# Create necessary directories
mkdir -p ios/QuikApp/Resources
mkdir -p ios/QuikApp/Supporting\ Files

# Run sub-scripts
log "Running branding script"
./lib/scripts/ios/branding.sh || handle_error "Branding script failed"

log "Running permissions script"
./lib/scripts/ios/permissions.sh || handle_error "Permissions script failed"

if [ "$FIREBASE_CONFIG_IOS" != "" ]; then
    log "Running Firebase script"
    ./lib/scripts/ios/firebase.sh || handle_error "Firebase script failed"
fi

log "Running signing script"
./lib/scripts/ios/signing.sh || handle_error "Signing script failed"

# Build iOS app
log "Building iOS app"
xcodebuild -workspace ios/QuikApp.xcworkspace \
    -scheme QuikApp \
    -configuration Release \
    -archivePath build/QuikApp.xcarchive \
    archive || handle_error "Archive failed"

# Export IPA
log "Exporting IPA"
xcodebuild -exportArchive \
    -archivePath build/QuikApp.xcarchive \
    -exportOptionsPlist ios/exportOptions.plist \
    -exportPath build/ios || handle_error "Export failed"

# Send email notification
if [ "$ENABLE_EMAIL_NOTIFICATIONS" = "true" ]; then
    log "Sending email notification"
    ./lib/scripts/utils/send_email.sh "success" || log "Email notification failed"
fi

log "iOS build completed successfully"
exit 0 