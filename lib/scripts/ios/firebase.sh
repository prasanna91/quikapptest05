#!/bin/bash
set -euo pipefail

log() { echo "[FIREBASE][$(date '+%Y-%m-%d %H:%M:%S')] $1"; }

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
    wget --tries=3 --wait=5 -O ios/Runner/GoogleService-Info.plist "$firebase_config_ios" || {
      log "[FIREBASE][ERROR] Failed to download GoogleService-Info.plist after 3 attempts.";
      exit 1;
    }
    cp ios/Runner/GoogleService-Info.plist assets/GoogleService-Info.plist
    log "Firebase config injected."
  else
    log "[WARN] firebase_config_ios not set."
  fi
else
  log "PUSH_NOTIFY is false; skipping Firebase config."
fi 