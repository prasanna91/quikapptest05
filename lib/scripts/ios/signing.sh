#!/bin/bash
set -euo pipefail

log() { echo "[SIGNING][$(date '+%Y-%m-%d %H:%M:%S')] $1"; }

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR/ios"

# Functions to send guidance emails
send_cer_guidance() {
  bash lib/scripts/utils/send_email.sh "iOS Signing Error" "iOS" "" "" "" "#" "#" "cer_guidance"
}
send_key_guidance() {
  bash lib/scripts/utils/send_email.sh "iOS Signing Error" "iOS" "" "" "" "#" "#" "key_guidance"
}
send_mobileprovision_guidance() {
  bash lib/scripts/utils/send_email.sh "iOS Signing Error" "iOS" "" "" "" "#" "#" "mobileprovision_guidance"
}

# Debug print URLs
log "CERT_CER_URL: ${CERT_CER_URL:-}"
log "CERT_KEY_URL: ${CERT_KEY_URL:-}"
log "PROFILE_URL: ${PROFILE_URL:-}"

# Validate .cer, .key, and .mobileprovision
if [[ -z "${CERT_CER_URL:-}" ]]; then
  log "CERT_CER_URL is not set"
  send_cer_guidance
  exit 1
fi

if ! curl -sSL "$CERT_CER_URL" -o "$OUTPUT_DIR/ios/apple_distribution.cer"; then
  log "Failed to download .cer file from $CERT_CER_URL"
  send_cer_guidance
  exit 1
fi

if [[ -z "${CERT_KEY_URL:-}" ]]; then
  log "CERT_KEY_URL is not set"
  send_key_guidance
  exit 1
fi

if ! curl -sSL "$CERT_KEY_URL" -o "$OUTPUT_DIR/ios/privatekey.key"; then
  log "Failed to download .key file from $CERT_KEY_URL"
  send_key_guidance
  exit 1
fi

if [[ -z "${PROFILE_URL:-}" ]]; then
  log "PROFILE_URL is not set"
  send_mobileprovision_guidance
  exit 1
fi

if ! curl -sSL "$PROFILE_URL" -o "$OUTPUT_DIR/ios/profile.mobileprovision"; then
  log "Failed to download .mobileprovision file from $PROFILE_URL"
  send_mobileprovision_guidance
  exit 1
fi

# Verify downloaded files
log "Verifying downloaded files..."
ls -l "$OUTPUT_DIR/ios/"

# Convert certificate to PEM format if needed
log "Converting certificate to PEM format..."
if ! openssl x509 -inform DER -in "$OUTPUT_DIR/ios/apple_distribution.cer" -out "$OUTPUT_DIR/ios/apple_distribution.pem" 2>/dev/null; then
  # If conversion fails, assume it's already in PEM format
  cp "$OUTPUT_DIR/ios/apple_distribution.cer" "$OUTPUT_DIR/ios/apple_distribution.pem"
fi

# Generate .p12
if command -v openssl >/dev/null 2>&1; then
  log "Generating .p12 using openssl"
  if ! openssl pkcs12 -export \
    -inkey "$OUTPUT_DIR/ios/privatekey.key" \
    -in "$OUTPUT_DIR/ios/apple_distribution.pem" \
    -certfile "$OUTPUT_DIR/ios/apple_distribution.pem" \
    -out "$OUTPUT_DIR/ios/ios_cert.p12" \
    -passout pass:"$CERT_PASSWORD" 2>&1; then
    log ".p12 generation failed. Sending all guidance emails."
    send_cer_guidance
    send_key_guidance
    send_mobileprovision_guidance
    exit 1
  fi
  log "Successfully generated .p12 file"
else
  log "openssl not found. Skipping .p12 generation."
  exit 1
fi

# Install the provisioning profile
log "Installing provisioning profile..."
mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles/
cp "$OUTPUT_DIR/ios/profile.mobileprovision" ~/Library/MobileDevice/Provisioning\ Profiles/

log "Code signing setup completed successfully."
exit 0 