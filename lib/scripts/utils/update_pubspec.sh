#!/bin/bash
set -euo pipefail

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../../.." && pwd )"

# Function to update pubspec.yaml with environment variables
update_pubspec() {
    local pubspec_file="$PROJECT_ROOT/pubspec.yaml"

    # Create a backup
    cp "$pubspec_file" "${pubspec_file}.bak"

    # Update version
    sed -i.bak "s/version: .*/version: ${VERSION_NAME}+${VERSION_CODE}/" "$pubspec_file"

    # Replace placeholders with actual dependencies based on feature flags
    if [ "${PUSH_NOTIFY:-}" = "true" ]; then
        sed -i.bak "s/# FIREBASE_CORE_DEPENDENCY_PLACEHOLDER/firebase_core: ^2.24.2/" "$pubspec_file"
        sed -i.bak "s/# FIREBASE_MESSAGING_PUBSPEC_DEPENDENCY_PLACEHOLDER/firebase_messaging: ^14.7.9/" "$pubspec_file"
    else
        # Remove the placeholder lines if feature is disabled
        sed -i.bak "/# FIREBASE_CORE_DEPENDENCY_PLACEHOLDER/d" "$pubspec_file"
        sed -i.bak "/# FIREBASE_MESSAGING_PUBSPEC_DEPENDENCY_PLACEHOLDER/d" "$pubspec_file"
    fi

    # Handle other conditional dependencies
    if [ "${IS_CAMERA:-}" = "true" ]; then
        sed -i.bak "s/# CAMERA_DEPENDENCY_PLACEHOLDER/camera: ^0.10.5+9/" "$pubspec_file"
    else
        sed -i.bak "/# CAMERA_DEPENDENCY_PLACEHOLDER/d" "$pubspec_file"
    fi
    
    if [ "${IS_LOCATION:-}" = "true" ]; then
        sed -i.bak "s/# GEOLOCATOR_DEPENDENCY_PLACEHOLDER/geolocator: ^10.1.0/" "$pubspec_file"
    else
        sed -i.bak "/# GEOLOCATOR_DEPENDENCY_PLACEHOLDER/d" "$pubspec_file"
    fi
    
    if [ "${IS_MIC:-}" = "true" ]; then
        sed -i.bak "s/# SPEECH_TO_TEXT_DEPENDENCY_PLACEHOLDER/speech_to_text: ^6.5.1/" "$pubspec_file"
    else
        sed -i.bak "/# SPEECH_TO_TEXT_DEPENDENCY_PLACEHOLDER/d" "$pubspec_file"
    fi
    
    if [ "${IS_CONTACT:-}" = "true" ]; then
        sed -i.bak "s/# CONTACTS_SERVICE_DEPENDENCY_PLACEHOLDER/contacts_service: ^0.6.3/" "$pubspec_file"
    else
        sed -i.bak "/# CONTACTS_SERVICE_DEPENDENCY_PLACEHOLDER/d" "$pubspec_file"
    fi
    
    if [ "${IS_BIOMETRIC:-}" = "true" ]; then
        sed -i.bak "s/# LOCAL_AUTH_DEPENDENCY_PLACEHOLDER/local_auth: ^2.1.8/" "$pubspec_file"
    else
        sed -i.bak "/# LOCAL_AUTH_DEPENDENCY_PLACEHOLDER/d" "$pubspec_file"
    fi
    
    if [ "${IS_CALENDAR:-}" = "true" ]; then
        sed -i.bak "s/# CALENDAR_EVENTS_DEPENDENCY_PLACEHOLDER/calendar_events: ^1.0.5/" "$pubspec_file"
    else
        sed -i.bak "/# CALENDAR_EVENTS_DEPENDENCY_PLACEHOLDER/d" "$pubspec_file"
    fi
    
    if [ "${IS_STORAGE:-}" = "true" ]; then
        sed -i.bak "s/# FILE_PICKER_DEPENDENCY_PLACEHOLDER/file_picker: ^6.1.1/" "$pubspec_file"
    else
        sed -i.bak "/# FILE_PICKER_DEPENDENCY_PLACEHOLDER/d" "$pubspec_file"
    fi
    
    if [ "${IS_CHATBOT:-}" = "true" ]; then
        sed -i.bak "s/# FLUTTER_CHAT_UI_DEPENDENCY_PLACEHOLDER/flutter_chat_ui: ^1.6.10/" "$pubspec_file"
    else
        sed -i.bak "/# FLUTTER_CHAT_UI_DEPENDENCY_PLACEHOLDER/d" "$pubspec_file"
    fi
    
    if [ "${IS_DEEPLINK:-}" = "true" ]; then
        sed -i.bak "s/# UNI_LINKS_DEPENDENCY_PLACEHOLDER/uni_links: ^0.5.1/" "$pubspec_file"
    else
        sed -i.bak "/# UNI_LINKS_DEPENDENCY_PLACEHOLDER/d" "$pubspec_file"
    fi
    
    if [ "${IS_SPLASH:-}" = "true" ]; then
        sed -i.bak "s/# FLUTTER_NATIVE_SPLASH_DEPENDENCY_PLACEHOLDER/flutter_native_splash: ^2.3.9/" "$pubspec_file"
    else
        sed -i.bak "/# FLUTTER_NATIVE_SPLASH_DEPENDENCY_PLACEHOLDER/d" "$pubspec_file"
    fi
    
    if [ "${IS_PULLDOWN:-}" = "true" ]; then
        sed -i.bak "s/# PULL_TO_REFRESH_DEPENDENCY_PLACEHOLDER/pull_to_refresh: ^2.0.0/" "$pubspec_file"
    else
        sed -i.bak "/# PULL_TO_REFRESH_DEPENDENCY_PLACEHOLDER/d" "$pubspec_file"
    fi
    
    if [ "${IS_BOTTOMMENU:-}" = "true" ]; then
        sed -i.bak "s/# FLUTTER_SVG_DEPENDENCY_PLACEHOLDER/flutter_svg: ^2.0.9/" "$pubspec_file"
    else
        sed -i.bak "/# FLUTTER_SVG_DEPENDENCY_PLACEHOLDER/d" "$pubspec_file"
    fi
    
    if [ "${IS_LOAD_IND:-}" = "true" ]; then
        sed -i.bak "s/# LOADING_ANIMATION_WIDGET_DEPENDENCY_PLACEHOLDER/loading_animation_widget: ^1.2.0+4/" "$pubspec_file"
    else
        sed -i.bak "/# LOADING_ANIMATION_WIDGET_DEPENDENCY_PLACEHOLDER/d" "$pubspec_file"
    fi

    # Clean up backup files
    rm -f "${pubspec_file}.bak"
}

# Main execution
update_pubspec 