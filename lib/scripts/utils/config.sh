#!/bin/bash
set -euo pipefail

# Detect Flutter root path
if command -v flutter >/dev/null 2>&1; then
    export flutterRoot="$(dirname "$(which flutter)")"
else
    export flutterRoot=""
fi

# API Variables with defaults
VERSION_NAME=${VERSION_NAME:-"1.0.0"}
VERSION_CODE=${VERSION_CODE:-"1"}
APP_NAME=${APP_NAME:-"QuikApp"}
ORG_NAME=${ORG_NAME:-"QuikApp"}
WEB_URL=${WEB_URL:-"https://quikapp.co"}
PKG_NAME=${PKG_NAME:-"com.quikapp.app"}
BUNDLE_ID=${BUNDLE_ID:-"com.quikapp.app"}
EMAIL_ID=${EMAIL_ID:-"admin@quikapp.co"}
PUSH_NOTIFY=${PUSH_NOTIFY:-"false"}
IS_CHATBOT=${IS_CHATBOT:-"false"}
IS_DEEPLINK=${IS_DEEPLINK:-"false"}
IS_SPLASH=${IS_SPLASH:-"false"}
IS_PULLDOWN=${IS_PULLDOWN:-"false"}
IS_BOTTOMMENU=${IS_BOTTOMMENU:-"false"}
IS_LOAD_IND=${IS_LOAD_IND:-"false"}
IS_CAMERA=${IS_CAMERA:-"false"}
IS_LOCATION=${IS_LOCATION:-"false"}
IS_MIC=${IS_MIC:-"false"}
IS_NOTIFICATION=${IS_NOTIFICATION:-"false"}
IS_CONTACT=${IS_CONTACT:-"false"}
IS_BIOMETRIC=${IS_BIOMETRIC:-"false"}
IS_CALENDAR=${IS_CALENDAR:-"false"}
IS_STORAGE=${IS_STORAGE:-"false"}
LOGO_URL=${LOGO_URL:-""}
SPLASH_URL=${SPLASH_URL:-""}
SPLASH_BG=${SPLASH_BG:-""}
SPLASH_BG_COLOR=${SPLASH_BG_COLOR:-"#FFFFFF"}
SPLASH_TAGLINE=${SPLASH_TAGLINE:-""}
SPLASH_TAGLINE_COLOR=${SPLASH_TAGLINE_COLOR:-"#000000"}
SPLASH_ANIMATION=${SPLASH_ANIMATION:-"fade"}
SPLASH_DURATION=${SPLASH_DURATION:-"3"}
BOTTOMMENU_ITEMS=${BOTTOMMENU_ITEMS:-"[]"}
BOTTOMMENU_BG_COLOR=${BOTTOMMENU_BG_COLOR:-"#FFFFFF"}
BOTTOMMENU_ICON_COLOR=${BOTTOMMENU_ICON_COLOR:-"#000000"}
BOTTOMMENU_TEXT_COLOR=${BOTTOMMENU_TEXT_COLOR:-"#000000"}
BOTTOMMENU_FONT=${BOTTOMMENU_FONT:-"Roboto"}
BOTTOMMENU_FONT_SIZE=${BOTTOMMENU_FONT_SIZE:-"12"}
BOTTOMMENU_FONT_BOLD=${BOTTOMMENU_FONT_BOLD:-"false"}
BOTTOMMENU_FONT_ITALIC=${BOTTOMMENU_FONT_ITALIC:-"false"}
BOTTOMMENU_ACTIVE_TAB_COLOR=${BOTTOMMENU_ACTIVE_TAB_COLOR:-"#0000FF"}
BOTTOMMENU_ICON_POSITION=${BOTTOMMENU_ICON_POSITION:-"above"}
BOTTOMMENU_VISIBLE_ON=${BOTTOMMENU_VISIBLE_ON:-"all"}

# Admin / Build Environment Variables (defaults)
export CM_BUILD_DIR=${CM_BUILD_DIR:-""}
export BUILD_MODE=${BUILD_MODE:-"release"}
export FLUTTER_VERSION=${FLUTTER_VERSION:-"3.32.2"}
export GRADLE_VERSION=${GRADLE_VERSION:-"8.0.0"}
export JAVA_VERSION=${JAVA_VERSION:-"17"}
export ANDROID_COMPILE_SDK=${ANDROID_COMPILE_SDK:-"34"}
export ANDROID_MIN_SDK=${ANDROID_MIN_SDK:-"21"}
export ANDROID_TARGET_SDK=${ANDROID_TARGET_SDK:-"34"}
export ANDROID_BUILD_TOOLS=${ANDROID_BUILD_TOOLS:-"34.0.0"}
export ANDROID_NDK_VERSION=${ANDROID_NDK_VERSION:-"27.0.12077973"}
export ANDROID_CMDLINE_TOOLS=${ANDROID_CMDLINE_TOOLS:-"latest"}

# These paths are derived from PROJECT_ROOT, which is set in main.sh
export PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../../.." && pwd )"
export ANDROID_ROOT="$PROJECT_ROOT/android"
export ASSETS_DIR="$PROJECT_ROOT/assets"
export OUTPUT_DIR="$PROJECT_ROOT/output"
export TEMP_DIR="$PROJECT_ROOT/temp"

export ANDROID_MANIFEST_PATH="$ANDROID_ROOT/app/src/main/AndroidManifest.xml"
export ANDROID_BUILD_GRADLE_PATH="$ANDROID_ROOT/app/build.gradle"
export ANDROID_KEY_PROPERTIES_PATH="$ANDROID_ROOT/gradle.properties"
export ANDROID_FIREBASE_CONFIG_PATH="$ANDROID_ROOT/app/google-services.json"
export ANDROID_MIPMAP_DIR="$ANDROID_ROOT/app/src/main/res/mipmap-anydpi-v26"
export ANDROID_DRAWABLE_DIR="$ANDROID_ROOT/app/src/main/res/drawable-v21"

export APK_OUTPUT_PATH="$OUTPUT_DIR/android"
export AAB_OUTPUT_PATH="$OUTPUT_DIR/android"

# Email Configuration
export EMAIL_SMTP_SERVER="smtp.gmail.com"
export EMAIL_SMTP_PORT="587"
export EMAIL_SMTP_USER="${Notifi_E_ID:-prasannasrie@gmail.com}"
export EMAIL_SMTP_PASS="jbbf nzhm zoay lbwb"

# Firebase Configuration
export firebase_config_android=${firebase_config_android:-""}
export firebase_config_ios=${firebase_config_ios:-""}

# Automatically determine settings based on variable presence
if [ -n "${KEY_STORE:-}" ] && [ -n "${CM_KEYSTORE_PASSWORD:-}" ] && [ -n "${CM_KEY_ALIAS:-}" ] && [ -n "${CM_KEY_PASSWORD:-}" ]; then
    USE_KEYSTORE="true"
    BUILD_AAB="true"
else
    USE_KEYSTORE="false"
    BUILD_AAB="false"
fi

# Function to send email notification
send_email_notification() {
    local status=$1
    local error_message=${2:-}
    local log_file_path=${3:-}
    local apk_path=${4:-}
    local aab_path=${5:-}

    local subject=""
    local project_configurations
    project_configurations="$(get_project_configurations)"

    if [ "$status" = "started" ]; then
        subject="[Build Started] ${APP_NAME} Build Notification"
        body="
        <html>
        <head>
            <style>
                body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                .header { background-color: #f8f9fa; padding: 20px; border-radius: 5px; }
                .content { padding: 20px; }
                .footer { text-align: center; padding: 20px; font-size: 12px; color: #666; }
                .status-started { color: #007bff; }
            </style>
        </head>
        <body>
            <div class='container'>
                <div class='header'>
                    <h2>${APP_NAME} Build Notification</h2>
                    <p>Organization: ${ORG_NAME}</p>
                </div>
                <div class='content'>
                    <h3 class='status-started'>Build Status: Started</h3>
                    <p>Version: ${VERSION_NAME} (${VERSION_CODE})</p>
                    <p>Build Date: $(date '+%Y-%m-%d %H:%M:%S')</p>
                    <h4>Project Configurations:</h4>
                    <ul>
                        ${project_configurations}
                    </ul>
                </div>
                <div class='footer'>
                    <p>This is an automated message from ${APP_NAME} Build System</p>
                    <p>© $(date '+%Y') ${ORG_NAME}. All rights reserved.</p>
                </div>
            </div>
        </body>
        </html>
        "
    elif [ "$status" = "success" ]; then
        subject="[Build Success] ${APP_NAME} Build Notification"
        body="
        <html>
        <head>
            <style>
                body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                .header { background-color: #f8f9fa; padding: 20px; border-radius: 5px; }
                .content { padding: 20px; }
                .footer { text-align: center; padding: 20px; font-size: 12px; color: #666; }
                .button { display: inline-block; padding: 10px 20px; background-color: #007bff; color: white; text-decoration: none; border-radius: 5px; }
                .status-success { color: #28a745; }
            </style>
        </head>
        <body>
            <div class='container'>
                <div class='header'>
                    <h2>${APP_NAME} Build Notification</h2>
                    <p>Organization: ${ORG_NAME}</p>
                </div>
                <div class='content'>
                    <h3 class='status-success'>Build Status: Success</h3>
                    <p>Version: ${VERSION_NAME} (${VERSION_CODE})</p>
                    <p>Build Date: $(date '+%Y-%m-%d %H:%M:%S')</p>
                    <h4>Project Configurations:</h4>
                    <ul>
                        ${project_configurations}
                    </ul>
                    <div class='artifacts'>
                        <h4>Build Artifacts:</h4>
                        $( [ -n "${aab_path}" ] && echo "<p><a href='file://${aab_path}' class='artifact-link'>📦 Download AAB</a></p>" )
                        $( [ -n "${apk_path}" ] && echo "<p><a href='file://${apk_path}' class='artifact-link'>📱 Download APK</a></p>" )
                    </div>
                </div>
                <div class='footer'>
                    <p>This is an automated message from ${APP_NAME} Build System</p>
                    <p>© $(date '+%Y') ${ORG_NAME}. All rights reserved.</p>
                </div>
            </div>
        </body>
        </html>
        "
    elif [ "$status" = "failure" ]; then
        subject="[Build Failed] ${APP_NAME} Build Notification"
        body="
        <html>
        <head>
            <style>
                body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                .header { background-color: #f8f9fa; padding: 20px; border-radius: 5px; }
                .content { padding: 20px; }
                .footer { text-align: center; padding: 20px; font-size: 12px; color: #666; }
                .status-failure { color: #dc3545; }
            </style>
        </head>
        <body>
            <div class='container'>
                <div class='header'>
                    <h2>${APP_NAME} Build Notification</h2>
                    <p>Organization: ${ORG_NAME}</p>
                </div>
                <div class='content'>
                    <h3 class='status-failure'>Build Status: Failed</h3>
                    <p>Version: ${VERSION_NAME} (${VERSION_CODE})</p>
                    <p>Build Date: $(date '+%Y-%m-%d %H:%M:%S')</p>
                    <h4>Project Configurations:</h4>
                    <ul>
                        ${project_configurations}
                    </ul>
                    $( [ -n "${error_message}" ] && echo "<h4>Error Details:</h4><pre>${error_message}</pre>" )
                </div>
                <div class='footer'>
                    <p>This is an automated message from ${APP_NAME} Build System</p>
                    <p>© $(date '+%Y') ${ORG_NAME}. All rights reserved.</p>
                </div>
            </div>
        </body>
        </html>
        "
    else
        echo "Invalid status for email notification: $status"
        return 1
    fi

    local email_file
    email_file=$(mktemp)
    echo "${body}" > "${email_file}"
    
    # Call Python script to send email
    python3 lib/scripts/utils/send_email_python.py \
        "${EMAIL_SMTP_SERVER}" \
        "${EMAIL_SMTP_PORT}" \
        "${EMAIL_SMTP_USER}" \
        "${EMAIL_SMTP_PASS}" \
        "${EMAIL_SMTP_USER}" \
        "${EMAIL_ID}" \
        "${subject}" \
        "${email_file}" \
        "${log_file_path}" \
        "${apk_path}" \
        "${aab_path}"
    
    # Clean up temporary file
    rm "${email_file}" || true
}

# Function to get project configurations for email
get_project_configurations() {
    local configs=(
        "APP_NAME:${APP_NAME}"
        "ORG_NAME:${ORG_NAME}"
        "WEB_URL:${WEB_URL}"
        "VERSION_NAME:${VERSION_NAME}"
        "VERSION_CODE:${VERSION_CODE}"
        "PKG_NAME:${PKG_NAME}"
        "BUNDLE_ID:${BUNDLE_ID}"
        "EMAIL_ID:${EMAIL_ID}"
        "PUSH_NOTIFY:${PUSH_NOTIFY}"
        "IS_CHATBOT:${IS_CHATBOT}"
        "IS_DEEPLINK:${IS_DEEPLINK}"
        "IS_SPLASH:${IS_SPLASH}"
        "IS_PULLDOWN:${IS_PULLDOWN}"
        "IS_BOTTOMMENU:${IS_BOTTOMMENU}"
        "IS_LOAD_IND:${IS_LOAD_IND}"
        "IS_CAMERA:${IS_CAMERA}"
        "IS_LOCATION:${IS_LOCATION}"
        "IS_MIC:${IS_MIC}"
        "IS_NOTIFICATION:${IS_NOTIFICATION}"
        "IS_CONTACT:${IS_CONTACT}"
        "IS_BIOMETRIC:${IS_BIOMETRIC}"
        "IS_CALENDAR:${IS_CALENDAR}"
        "IS_STORAGE:${IS_STORAGE}"
        "LOGO_URL:${LOGO_URL}"
        "SPLASH_URL:${SPLASH_URL}"
        "SPLASH_BG:${SPLASH_BG}"
        "SPLASH_BG_COLOR:${SPLASH_BG_COLOR}"
        "SPLASH_TAGLINE:${SPLASH_TAGLINE}"
        "SPLASH_TAGLINE_COLOR:${SPLASH_TAGLINE_COLOR}"
        "SPLASH_ANIMATION:${SPLASH_ANIMATION}"
        "SPLASH_DURATION:${SPLASH_DURATION}"
        "BOTTOMMENU_ITEMS:${BOTTOMMENU_ITEMS}"
        "BOTTOMMENU_BG_COLOR:${BOTTOMMENU_BG_COLOR}"
        "BOTTOMMENU_ICON_COLOR:${BOTTOMMENU_ICON_COLOR}"
        "BOTTOMMENU_TEXT_COLOR:${BOTTOMMENU_TEXT_COLOR}"
        "BOTTOMMENU_FONT:${BOTTOMMENU_FONT}"
        "BOTTOMMENU_FONT_SIZE:${BOTTOMMENU_FONT_SIZE}"
        "BOTTOMMENU_FONT_BOLD:${BOTTOMMENU_FONT_BOLD}"
        "BOTTOMMENU_FONT_ITALIC:${BOTTOMMENU_FONT_ITALIC}"
        "BOTTOMMENU_ACTIVE_TAB_COLOR:${BOTTOMMENU_ACTIVE_TAB_COLOR}"
        "BOTTOMMENU_ICON_POSITION:${BOTTOMMENU_ICON_POSITION}"
        "BOTTOMMENU_VISIBLE_ON:${BOTTOMMENU_VISIBLE_ON}"
        "firebase_config_android:${firebase_config_android}"
        "firebase_config_ios:${firebase_config_ios}"
        "KEY_STORE:${KEY_STORE}"
        "CM_KEYSTORE_PASSWORD:${CM_KEYSTORE_PASSWORD}"
        "CM_KEY_ALIAS:${CM_KEY_ALIAS}"
        "CM_KEY_PASSWORD:${CM_KEY_PASSWORD}"
        "EMAIL_SMTP_SERVER:${EMAIL_SMTP_SERVER}"
        "EMAIL_SMTP_PORT:${EMAIL_SMTP_PORT}"
        "EMAIL_SMTP_USER:${EMAIL_SMTP_USER}"
        "EMAIL_SMTP_PASS:********"
    )

    local config_list=""
    for config in "${configs[@]}"; do
        config_list+="<li>${config}</li>"
    done
    echo "$config_list"
}

# Function to generate environment.dart
generate_environment_dart() {
    cat > lib/config/env_config.dart << EOF
class EnvConfig {
  static const String appName = '${APP_NAME}';
  static const String orgName = '${ORG_NAME}';
  static const String webUrl = '${WEB_URL}';
  static const String pkgName = '${PKG_NAME}';
  static const String bundleId = '${BUNDLE_ID}';
  static const String emailId = '${EMAIL_ID}';
  static const bool isChatbot = ${IS_CHATBOT};
  static const bool isDeeplink = ${IS_DEEPLINK};
  static const bool isSplash = ${IS_SPLASH};
  static const bool isPulldown = ${IS_PULLDOWN};
  static const bool isBottommenu = ${IS_BOTTOMMENU};
  static const bool isLoadIndicator = ${IS_LOAD_IND};
  static const bool isCamera = ${IS_CAMERA};
  static const bool isLocation = ${IS_LOCATION};
  static const bool isMic = ${IS_MIC};
  static const bool isNotification = ${IS_NOTIFICATION};
  static const bool isContact = ${IS_CONTACT};
  static const bool isBiometric = ${IS_BIOMETRIC};
  static const bool isCalendar = ${IS_CALENDAR};
  static const bool isStorage = ${IS_STORAGE};
  static const String logoUrl = '${LOGO_URL}';
  static const String splashUrl = '${SPLASH_URL}';
  static const String splashBg = '${SPLASH_BG}';
  static const String splashBgColor = '${SPLASH_BG_COLOR}';
  static const String splashTagline = '${SPLASH_TAGLINE}';
  static const String splashTaglineColor = '${SPLASH_TAGLINE_COLOR}';
  static const String splashAnimation = '${SPLASH_ANIMATION}';
  static const int splashDuration = ${SPLASH_DURATION};
  static const String bottommenuItems = r'''${BOTTOMMENU_ITEMS}''';
  static const String bottommenuBgColor = '${BOTTOMMENU_BG_COLOR}';
  static const String bottommenuIconColor = '${BOTTOMMENU_ICON_COLOR}';
  static const String bottommenuTextColor = '${BOTTOMMENU_TEXT_COLOR}';
  static const String bottommenuFont = '${BOTTOMMENU_FONT}';
  static const double bottommenuFontSize = ${BOTTOMMENU_FONT_SIZE};
  static const bool bottommenuFontBold = ${BOTTOMMENU_FONT_BOLD};
  static const bool bottommenuFontItalic = ${BOTTOMMENU_FONT_ITALIC};
  static const String bottommenuActiveTabColor = '${BOTTOMMENU_ACTIVE_TAB_COLOR}';
  static const String bottommenuIconPosition = '${BOTTOMMENU_ICON_POSITION}';
  static const String bottommenuVisibleOn = '${BOTTOMMENU_VISIBLE_ON}';
  static const bool pushNotify = ${PUSH_NOTIFY};
}
EOF
}

# Function to generate AndroidManifest.xml
generate_android_manifest() {
    cat > android/app/src/main/AndroidManifest.xml << EOF
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- PERMISSIONS_PLACEHOLDER -->

    <application
        android:label="${APP_NAME}"
        android:name="\${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <meta-data
                android:name="io.flutter.embedding.android.NormalTheme"
                android:resource="@style/NormalTheme"/>
            
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
            
            <!-- DEEPLINK_INTENT_FILTER_PLACEHOLDER -->
            
            <!-- FIREBASE_NOTIFICATION_INTENT_FILTER_PLACEHOLDER -->
        </activity>
        
        <!-- FIREBASE_SERVICES_PLACEHOLDER -->
        
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
EOF
}

# Function to generate build.gradle
generate_build_gradle() {
    cat > android/app/build.gradle << EOF
def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

def flutterRoot = localProperties.getProperty('flutter.sdk')
if (flutterRoot == null) {
    throw new GradleException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.")
}

def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
if (flutterVersionCode == null) {
    flutterVersionCode = '1'
}

def flutterVersionName = localProperties.getProperty('flutter.versionName')
if (flutterVersionName == null) {
    flutterVersionName = '1.0'
}

apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"
// FIREBASE_GRADLE_PLUGIN_PLACEHOLDER

android {
    namespace "${PKG_NAME}"
    compileSdkVersion flutter.compileSdkVersion
    ndkVersion flutter.ndkVersion

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }

    defaultConfig {
        applicationId "${PKG_NAME}"
        minSdkVersion flutter.minSdkVersion
        targetSdkVersion flutter.targetSdkVersion
        versionCode ${VERSION_CODE}
        versionName "${VERSION_NAME}"
    }

    signingConfigs {
        // SIGNING_CONFIGS_BLOCK_PLACEHOLDER
    }

    buildTypes {
        release {
            // BUILD_TYPES_SIGNING_CONFIG_PLACEHOLDER
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}

flutter {
    source '../../'
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
    // FIREBASE_BOM_DEPENDENCY_PLACEHOLDER
    // FIREBASE_MESSAGING_DEPENDENCY_PLACEHOLDER
}
EOF
}

# Function to generate pubspec.yaml
generate_pubspec_yaml() {
    cat > pubspec.yaml << EOF
name: quikapp
description: "A new Flutter project."
publish_to: 'none'
version: ${VERSION_NAME}+${VERSION_CODE}

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  # FIREBASE_CORE_DEPENDENCY_PLACEHOLDER
  # FIREBASE_MESSAGING_PUBSPEC_DEPENDENCY_PLACEHOLDER
  flutter_inappwebview: ^5.8.0
  url_launcher: ^6.2.2
  package_info_plus: ^5.0.1
  shared_preferences: ^2.2.2
  flutter_local_notifications: ^16.2.0
  permission_handler: ^11.1.0
  # CAMERA_DEPENDENCY_PLACEHOLDER
  # GEOLOCATOR_DEPENDENCY_PLACEHOLDER
  # SPEECH_TO_TEXT_DEPENDENCY_PLACEHOLDER
  # CONTACTS_SERVICE_DEPENDENCY_PLACEHOLDER
  # LOCAL_AUTH_DEPENDENCY_PLACEHOLDER
  # CALENDAR_EVENTS_DEPENDENCY_PLACEHOLDER
  # FILE_PICKER_DEPENDENCY_PLACEHOLDER
  # FLUTTER_CHAT_UI_DEPENDENCY_PLACEHOLDER
  # UNI_LINKS_DEPENDENCY_PLACEHOLDER
  # FLUTTER_NATIVE_SPLASH_DEPENDENCY_PLACEHOLDER
  # PULL_TO_REFRESH_DEPENDENCY_PLACEHOLDER
  # FLUTTER_SVG_DEPENDENCY_PLACEHOLDER
  # LOADING_ANIMATION_WIDGET_DEPENDENCY_PLACEHOLDER

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
EOF
}

# Generate all configuration files
generate_environment_dart
generate_android_manifest
generate_build_gradle
generate_pubspec_yaml

# Send build start notification
# This call is moved to main.sh or combined.sh to be part of the build flow
# send_email_notification "started"

echo "Configuration generated successfully!" 