#!/bin/bash
set -euo pipefail

log() { echo "[FIREBASE][$(date '+%Y-%m-%d %H:%M:%S')] $1"; }

if [[ "${PUSH_NOTIFY:-false}" == "true" ]]; then
  if [ -n "${firebase_config_ios:-}" ]; then
    log "Downloading GoogleService-Info.plist for Firebase..."
    mkdir -p ios/Runner
    curl -sSL "$firebase_config_ios" -o ios/Runner/GoogleService-Info.plist || log "[WARN] Failed to download GoogleService-Info.plist."
    log "Firebase config injected."
  else
    log "[WARN] firebase_config_ios not set."
  fi
else
  log "PUSH_NOTIFY is false; skipping Firebase config."
fi 