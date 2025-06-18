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
trap 'handle_error "Keystore setup failed at line $LINENO"' ERR

# Start keystore setup
log "🔑 Starting keystore setup for $APP_NAME"

# Validate required variables
if [ -z "$KEY_STORE" ] || [ -z "$CM_KEYSTORE_PASSWORD" ] || [ -z "$CM_KEY_ALIAS" ] || [ -z "$CM_KEY_PASSWORD" ]; then
    handle_error "Missing required keystore variables"
fi

# Create keystore properties file
log "📝 Creating keystore.properties file"
cat > android/keystore.properties << EOF
storeFile=keystore.jks
storePassword=$CM_KEYSTORE_PASSWORD
keyAlias=$CM_KEY_ALIAS
keyPassword=$CM_KEY_PASSWORD
EOF

# Download keystore file
log "📥 Downloading keystore from $KEY_STORE"
curl -L "$KEY_STORE" -o android/app/keystore.jks || handle_error "Failed to download keystore"

# Verify keystore
log "🔍 Verifying keystore"
if ! keytool -list -keystore android/app/keystore.jks -storepass "$CM_KEYSTORE_PASSWORD" >/dev/null 2>&1; then
    handle_error "Invalid keystore or password"
fi

# Update build.gradle.kts with signing config
log "📝 Updating build.gradle.kts with signing configuration"
cat > android/app/build.gradle.kts << EOF
import java.util.Properties
import java.io.FileInputStream

val keystorePropertiesFile = rootProject.file("keystore.properties")
val keystoreProperties = Properties()
keystoreProperties.load(FileInputStream(keystorePropertiesFile))

plugins {
    id("com.android.application")
    id("kotlin-android")
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

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            signingConfig = signingConfigs.getByName("release")
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
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.22")
}
EOF

log "✅ Keystore setup completed successfully!"
exit 0 