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
trap 'handle_error "Branding failed at line $LINENO"' ERR

# Start branding process
log "🎨 Starting branding process for $APP_NAME"

# Create necessary directories
mkdir -p android/app/src/main/res/mipmap-{hdpi,mdpi,xhdpi,xxhdpi,xxxhdpi}
mkdir -p android/app/src/main/res/drawable

# Download and process app icon
if [ -n "$LOGO_URL" ]; then
    log "📥 Downloading app icon from $LOGO_URL"
    curl -L "$LOGO_URL" -o temp_icon.png || handle_error "Failed to download app icon"
    
    # Convert icon to different sizes
    log "🖼️ Converting app icon to different sizes"
    convert temp_icon.png -resize 48x48 android/app/src/main/res/mipmap-mdpi/ic_launcher.png
    convert temp_icon.png -resize 72x72 android/app/src/main/res/mipmap-hdpi/ic_launcher.png
    convert temp_icon.png -resize 96x96 android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
    convert temp_icon.png -resize 144x144 android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
    convert temp_icon.png -resize 192x192 android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
    
    rm temp_icon.png
fi

# Handle splash screen
if [ "$IS_SPLASH" = "true" ]; then
    log "🎨 Setting up splash screen"
    
    # Create splash screen drawable
    cat > android/app/src/main/res/drawable/launch_background.xml << EOF
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item>
        <color android:color="${SPLASH_BG_COLOR:-#FFFFFF}"/>
    </item>
    <item>
        <bitmap
            android:gravity="center"
            android:src="@mipmap/splash"/>
    </item>
    <item android:top="60%">
        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="${SPLASH_TAGLINE:-}"
            android:textColor="${SPLASH_TAGLINE_COLOR:-#000000}"
            android:textSize="18sp"
            android:gravity="center"/>
    </item>
</layer-list>
EOF

    # Download splash image if provided
    if [ -n "$SPLASH_URL" ]; then
        log "📥 Downloading splash image from $SPLASH_URL"
        curl -L "$SPLASH_URL" -o temp_splash.png || handle_error "Failed to download splash image"
        
        # Convert splash to different sizes
        log "🖼️ Converting splash image to different sizes"
        convert temp_splash.png -resize 320x320 android/app/src/main/res/mipmap-mdpi/splash.png
        convert temp_splash.png -resize 480x480 android/app/src/main/res/mipmap-hdpi/splash.png
        convert temp_splash.png -resize 640x640 android/app/src/main/res/mipmap-xhdpi/splash.png
        convert temp_splash.png -resize 960x960 android/app/src/main/res/mipmap-xxhdpi/splash.png
        convert temp_splash.png -resize 1280x1280 android/app/src/main/res/mipmap-xxxhdpi/splash.png
        
        rm temp_splash.png
    fi
fi

# Update AndroidManifest.xml with branding
log "📝 Updating AndroidManifest.xml"
sed -i '' "s/android:label=\"[^\"]*\"/android:label=\"$APP_NAME\"/g" android/app/src/main/AndroidManifest.xml

log "✅ Branding process completed successfully!"
exit 0 