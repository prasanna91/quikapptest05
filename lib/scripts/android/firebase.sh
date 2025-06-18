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
    exit 1
}

# Trap errors
trap 'handle_error "Firebase setup failed at line $LINENO"' ERR

# Start Firebase setup
log "🔥 Starting Firebase setup for $APP_NAME"

# Create necessary directories
mkdir -p android/app/src/main/assets

# Download Firebase config
if [ -n "$firebase_config_android" ]; then
    log "📥 Downloading Firebase config from $firebase_config_android"
    curl -L "$firebase_config_android" -o android/app/google-services.json || handle_error "Failed to download Firebase config"
    
    # Validate JSON format
    if ! jq empty android/app/google-services.json 2>/dev/null; then
        handle_error "Invalid Firebase config JSON format"
    fi
    
    # Verify package name matches
    CONFIG_PACKAGE=$(jq -r '.client[0].client_info.android_client_info.package_name' android/app/google-services.json)
    if [ "$CONFIG_PACKAGE" != "$PKG_NAME" ]; then
        handle_error "Firebase config package name ($CONFIG_PACKAGE) does not match app package name ($PKG_NAME)"
    fi
fi

# Update build.gradle.kts with Firebase dependencies
log "📝 Updating build.gradle.kts with Firebase dependencies"
cat > android/app/build.gradle.kts << EOF
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
}

android {
    namespace = "$PKG_NAME"
    compileSdk = 34

    defaultConfig {
        applicationId = "$PKG_NAME"
        minSdk = 21
        targetSdk = 34
        versionCode = $VERSION_CODE
        versionName = "$VERSION_NAME"
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.7.4"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-messaging")
    implementation("com.google.firebase:firebase-crashlytics")
}
EOF

# Update project-level build.gradle.kts
log "📝 Updating project-level build.gradle.kts"
cat > android/build.gradle.kts << EOF
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.2.2")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.22")
        classpath("com.google.gms:google-services:4.4.1")
        classpath("com.google.firebase:firebase-crashlytics-gradle:2.9.9")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
EOF

log "✅ Firebase setup completed successfully!"
exit 0 