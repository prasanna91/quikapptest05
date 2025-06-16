#!/bin/bash
set -euo pipefail

log() { echo "[FIREBASE][$(date '+%Y-%m-%d %H:%M:%S')] $1"; }

# Function to send Firebase guidance email
send_firebase_guidance() {
  bash lib/scripts/utils/send_email.sh "Firebase Error" "Android-Publish" "" "" "" "#" "#" "firebase_guidance"
}

if [[ "${PUSH_NOTIFY:-false}" == "true" ]]; then
  if [ -n "${firebase_config_android:-}" ]; then
    log "Downloading google-services.json for Firebase..."
    mkdir -p android/app assets
    if [ -f android/app/google-services.json ]; then
      rm -f android/app/google-services.json
    fi
    if [ -f assets/google-services.json ]; then
      rm -f assets/google-services.json
    fi
    wget --tries=3 --wait=5 -O android/app/google-services.json "$firebase_config_android" || {
      log "[WARN] Failed to download google-services.json after 3 attempts. Sending Firebase guidance email."
      send_firebase_guidance
      exit 1
    }
    cp android/app/google-services.json assets/google-services.json
    log "Firebase config injected."
  else
    log "[WARN] firebase_config_android not set. Sending Firebase guidance email."
    send_firebase_guidance
    exit 1
  fi
else
  log "PUSH_NOTIFY is false; skipping Firebase config."
fi 