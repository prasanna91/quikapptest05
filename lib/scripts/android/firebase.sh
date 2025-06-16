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
    if ! curl -sSL "$firebase_config_android" -o android/app/google-services.json; then
      log "[WARN] Failed to download google-services.json. Sending Firebase guidance email."
      send_firebase_guidance
      exit 1
    fi
    log "Firebase config injected."
  else
    log "[WARN] firebase_config_android not set. Sending Firebase guidance email."
    send_firebase_guidance
    exit 1
  fi
else
  log "PUSH_NOTIFY is false; skipping Firebase config."
fi 