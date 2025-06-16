#!/bin/bash
set -euo pipefail

log() { echo "[FIREBASE][$(date '+%Y-%m-%d %H:%M:%S')] $1"; }

# Function to send Firebase guidance email
send_firebase_guidance() {
  bash lib/scripts/utils/send_email.sh "Firebase Error" "iOS-Only" "" "" "" "#" "#" "firebase_guidance"
}

if [[ "${PUSH_NOTIFY:-false}" == "true" ]]; then
  if [ -n "${firebase_config_ios:-}" ]; then
    log "Downloading GoogleService-Info.plist for Firebase..."
    mkdir -p ios/Runner assets
    if [ -f ios/Runner/GoogleService-Info.plist ]; then
      rm -f ios/Runner/GoogleService-Info.plist
    fi
    if [ -f assets/GoogleService-Info.plist ]; then
      rm -f assets/GoogleService-Info.plist
    fi
    
    # URL encode the config URL
    ENCODED_URL=$(echo "$firebase_config_ios" | sed 's/ /%20/g; s/(/%28/g; s/)/%29/g')
    
    wget --tries=3 --wait=5 -O ios/Runner/GoogleService-Info.plist "$ENCODED_URL" || {
      log "[WARN] Failed to download GoogleService-Info.plist after 3 attempts. Sending Firebase guidance email."
      send_firebase_guidance
      exit 1
    }
    cp ios/Runner/GoogleService-Info.plist assets/GoogleService-Info.plist
    log "Firebase config injected."
  else
    log "[WARN] firebase_config_ios not set. Sending Firebase guidance email."
    send_firebase_guidance
    exit 1
  fi
else
  log "PUSH_NOTIFY is false; skipping Firebase config."
fi 