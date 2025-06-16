#!/bin/bash
set -euo pipefail

echo "[SIGNING][$(date '+%Y-%m-%d %H:%M:%S')] Decoding .cer, .key, and .mobileprovision (stub)"
# TODO: Decode base64 files if needed

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

# Validate .cer, .key, and .mobileprovision
if [[ -z "${CERT_CER_URL:-}" ]] || ! curl -sSL "$CERT_CER_URL" -o "$OUTPUT_DIR/ios/apple_distribution.cer"; then
  echo "[SIGNING][$(date '+%Y-%m-%d %H:%M:%S')] .cer file missing or invalid. Sending guidance email."
  send_cer_guidance
  exit 1
fi
if [[ -z "${CERT_KEY_URL:-}" ]] || ! curl -sSL "$CERT_KEY_URL" -o "$OUTPUT_DIR/ios/privatekey.key"; then
  echo "[SIGNING][$(date '+%Y-%m-%d %H:%M:%S')] .key file missing or invalid. Sending guidance email."
  send_key_guidance
  exit 1
fi
if [[ -z "${PROFILE_URL:-}" ]] || ! curl -sSL "$PROFILE_URL" -o "$OUTPUT_DIR/ios/profile.mobileprovision"; then
  echo "[SIGNING][$(date '+%Y-%m-%d %H:%M:%S')] .mobileprovision file missing or invalid. Sending guidance email."
  send_mobileprovision_guidance
  exit 1
fi

# Generate .p12
if command -v openssl >/dev/null 2>&1; then
  echo "[SIGNING][$(date '+%Y-%m-%d %H:%M:%S')] Generating .p12 using openssl"
  if ! openssl pkcs12 -export \
    -inkey "$OUTPUT_DIR/ios/privatekey.key" \
    -in "$OUTPUT_DIR/ios/apple_distribution.cer" \
    -certfile "$OUTPUT_DIR/ios/apple_distribution.cer" \
    -out "$OUTPUT_DIR/ios/ios_cert.p12" \
    -passout pass:"$CERT_PASSWORD"; then
    echo "[SIGNING][$(date '+%Y-%m-%d %H:%M:%S')] .p12 generation failed. Sending all guidance emails."
    send_cer_guidance
    send_key_guidance
    send_mobileprovision_guidance
    exit 1
  fi
else
  echo "[SIGNING][$(date '+%Y-%m-%d %H:%M:%S')] openssl not found. Skipping .p12 generation."
fi
exit 0 