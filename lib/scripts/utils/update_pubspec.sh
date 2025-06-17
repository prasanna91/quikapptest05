#!/bin/bash
set -euo pipefail

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../../.." && pwd )"

# Function to update pubspec.yaml with environment variables
update_pubspec() {
    local pubspec_file="$PROJECT_ROOT/pubspec.yaml"
    local temp_file="$PROJECT_ROOT/pubspec.yaml.tmp"

    # Create a backup
    cp "$pubspec_file" "${pubspec_file}.bak"

    # Update version
    sed -i.bak "s/version: .*/version: ${VERSION_NAME}+${VERSION_CODE}/" "$pubspec_file"

    # Remove conditional dependencies
    sed -i.bak '/^[[:space:]]*$(.*)$/d' "$pubspec_file"

    # Add dependencies based on feature flags
    if [ "${PUSH_NOTIFY:-}" = "true" ]; then
        if ! grep -q "firebase_core:" "$pubspec_file"; then
            sed -i.bak '/dependencies:/a\
  firebase_core: ^2.24.2\
  firebase_messaging: ^14.7.9' "$pubspec_file"
        fi
    fi

    # Add other conditional dependencies
    local features=(
        "IS_CAMERA:camera:^0.10.5+9"
        "IS_LOCATION:geolocator:^10.1.0"
        "IS_MIC:speech_to_text:^6.5.1"
        "IS_CONTACT:contacts_service:^0.6.3"
        "IS_BIOMETRIC:local_auth:^2.1.8"
        "IS_CALENDAR:calendar_events:^0.0.1"
        "IS_STORAGE:file_picker:^6.1.1"
        "IS_CHATBOT:flutter_chat_ui:^1.6.10"
        "IS_DEEPLINK:uni_links:^0.5.1"
        "IS_SPLASH:flutter_native_splash:^2.3.9"
        "IS_PULLDOWN:pull_to_refresh:^2.0.0"
        "IS_BOTTOMMENU:flutter_svg:^2.0.9"
        "IS_LOAD_IND:loading_animation_widget:^1.2.0+4"
    )

    for feature in "${features[@]}"; do
        IFS=':' read -r flag package version <<< "$feature"
        if [ "${!flag:-}" = "true" ]; then
            if ! grep -q "$package:" "$pubspec_file"; then
                sed -i.bak "/dependencies:/a\\
  $package: $version" "$pubspec_file"
            fi
        fi
    done

    # Clean up temporary files
    rm -f "${pubspec_file}.bak"
}

# Main execution
update_pubspec 