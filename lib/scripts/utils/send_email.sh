#!/bin/bash
set -euo pipefail

# Usage: send_email.sh <status> <workflow> <apk_url> <aab_url> <ipa_url> <log_url> <resume_url>

STATUS=${1:-Completed}
WORKFLOW=${2:-Combined Android & iOS}
APK_URL=${3:-}
AAB_URL=${4:-}
IPA_URL=${5:-}
LOG_URL=${6:-#}
RESUME_URL=${7:-#}
GUIDANCE_MODE=${8:-}

APP_NAME=${APP_NAME:-Whale Tech}
DATE=$(date '+%d/%m/%Y')
EMAIL_TO=${NOTIFICATION_EMAIL_TO:-admin@quikapp.co}
EMAIL_FROM=${NOTIFICATION_EMAIL_FROM:-noreply@quikapp.co}
SUBJECT="[$APP_NAME] $WORKFLOW Build $STATUS"

# HTML Email Template
EMAIL_BODY=$(cat <<'EOF'
<html>
  <body style='font-family: "Inter", Arial, sans-serif; background: #f8fafc; color: #222;'>
    <div style='max-width: 480px; margin: 32px auto; background: #fff; border-radius: 12px; box-shadow: 0 2px 8px #0001; padding: 32px;'>
      <h2 style='margin: 0 0 8px 0; color: #1a56db;'>%s</h2>
      <div style='margin-bottom: 8px; font-size: 1.1em;'>Workflow: <b>%s</b></div>
      <div style='margin-bottom: 8px;'>Date: <b>%s</b></div>
      <div style='margin-bottom: 16px;'>Status: <span style='background: #e0fbe0; color: #1a7f37; border-radius: 6px; padding: 2px 10px; font-weight: bold;'>%s</span></div>
      <div style='margin-bottom: 16px;'>Artifacts:</div>
      <ul style='list-style: none; padding: 0;'>
        %s
        %s
        %s
      </ul>
      <div style='margin: 24px 0;'>
        <a href="%s" style='background:#1a56db; color:#fff; border-radius:6px; padding:8px 18px; text-decoration:none; margin-right:12px;'>▶️ Resume Build</a>
        <a href="%s" style='background:#f1f5f9; color:#222; border-radius:6px; padding:8px 18px; text-decoration:none;'>📄 View Logs</a>
      </div>
      <div style='font-size:0.95em; color:#888;'>Styled by QuikApp Portal UI • quikapp.co</div>
    </div>
  </body>
</html>
EOF
)
EMAIL_BODY=$(printf "$EMAIL_BODY" "$APP_NAME" "$WORKFLOW" "$DATE" "$STATUS" \
  "${APK_URL:+<li><a href=\"$APK_URL\" style='text-decoration:none;'><span style='background:#e0eaff; color:#1a56db; border-radius:5px; padding:4px 12px;'>🔗 Download APK</span></a></li>}" \
  "${AAB_URL:+<li><a href=\"$AAB_URL\" style='text-decoration:none;'><span style='background:#e0eaff; color:#1a56db; border-radius:5px; padding:4px 12px;'>🔗 Download AAB</span></a></li>}" \
  "${IPA_URL:+<li><a href=\"$IPA_URL\" style='text-decoration:none;'><span style='background:#e0eaff; color:#1a56db; border-radius:5px; padding:4px 12px;'>🔗 Download IPA</span></a></li>}" \
  "$RESUME_URL" "$LOG_URL")

# Source SMTP variables if available
if [ -f "lib/scripts/utils/variables.sh" ]; then
  source lib/scripts/utils/variables.sh
fi

# Prepare msmtp config if msmtp is available
if command -v msmtp >/dev/null 2>&1; then
  cat > /tmp/msmtp_quikapp.conf <<EOF
account default
host "${DEFAULT_SMTP_SERVER:-smtp.gmail.com}"
port "${DEFAULT_SMTP_PORT:-587}"
auth on
user "${DEFAULT_SMTP_USER:-}"
password "${DEFAULT_SMTP_PASS:-}"
from "${EMAIL_FROM}"
tls on
tls_starttls on
EOF
  chmod 600 /tmp/msmtp_quikapp.conf
  # Write the email body to a temp file
  EMAIL_TMP_FILE=$(mktemp)
  {
    echo "To: $EMAIL_TO"
    echo "Subject: $SUBJECT"
    echo "MIME-Version: 1.0"
    echo "Content-Type: text/html; charset=UTF-8"
    echo "From: $EMAIL_FROM"
    echo ""
    echo "$EMAIL_BODY"
  } > "$EMAIL_TMP_FILE"
  msmtp --file=/tmp/msmtp_quikapp.conf --from="$EMAIL_FROM" -t < "$EMAIL_TMP_FILE"
  rm -f "$EMAIL_TMP_FILE"
  exit $?
fi

# Send email (using mailx or sendmail)
if command -v mailx >/dev/null 2>&1; then
  # BSD mailx does not support -r or -S flags; cannot set sender or content-type
  echo "$EMAIL_BODY" | mailx -s "$SUBJECT" "$EMAIL_TO"
elif command -v sendmail >/dev/null 2>&1; then
  {
    echo "To: $EMAIL_TO"
    echo "Subject: $SUBJECT"
    echo "MIME-Version: 1.0"
    echo "Content-Type: text/html; charset=UTF-8"
    echo "From: $EMAIL_FROM"
    echo ""
    echo "$EMAIL_BODY"
  } | sendmail -t
else
  echo "[ERROR] No supported mail client found (mailx or sendmail)."
  exit 1
fi

if [[ "$GUIDANCE_MODE" == "keystore_guidance" ]]; then
  SUBJECT="[QuikApp] Android Keystore Generation Guidance"
  EMAIL_BODY="""
  <html>
    <body style='font-family: "Inter", Arial, sans-serif; background: #f8fafc; color: #222;'>
      <div style='max-width: 480px; margin: 32px auto; background: #fff; border-radius: 12px; box-shadow: 0 2px 8px #0001; padding: 32px;'>
        <h2 style='margin: 0 0 8px 0; color: #1a56db;'>Android Keystore Required</h2>
        <div style='margin-bottom: 16px;'>Your Android build could not proceed because a valid keystore was not provided or was invalid.</div>
        <div style='margin-bottom: 16px; color: #a30237;'><b>How to Generate a Keystore:</b></div>
        <div style='margin-bottom: 8px;'><b>Windows / Mac / Linux (Terminal):</b></div>
        <pre style='background:#f1f5f9; padding:12px; border-radius:6px; font-size:0.95em;'>
keytool -genkeypair -v -keystore my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my_key_alias
        </pre>
        <div style='margin-bottom: 8px;'>You will be prompted for passwords and organization info. <br>Remember your alias and passwords for Codemagic config.</div>
        <div style='margin-bottom: 8px;'><b>Upload the .jks file to a secure location (e.g., GitHub, Google Drive) and provide the URL in the KEY_STORE variable.</b></div>
        <div style='margin-bottom: 8px;'>
          <b>Codemagic Variables Required:</b>
          <ul>
            <li>KEY_STORE (URL to .jks file)</li>
            <li>CM_KEYSTORE_PASSWORD (Keystore password)</li>
            <li>CM_KEY_ALIAS (Alias name)</li>
            <li>CM_KEY_PASSWORD (Alias password)</li>
          </ul>
        </div>
        <div style='margin-bottom: 8px;'>
          <b>Reference:</b> <a href='https://docs.codemagic.io/code-signing/keystore/' style='color:#1a56db;'>Codemagic: Android code signing</a>
        </div>
        <div style='font-size:0.95em; color:#888;'>Styled by QuikApp Portal UI • quikapp.co</div>
      </div>
    </body>
  </html>
  """
fi

if [[ "$GUIDANCE_MODE" == "firebase_guidance" ]]; then
  SUBJECT="[QuikApp] Firebase Setup Guidance"
  EMAIL_BODY="""
  <html>
    <body style='font-family: \"Inter\", Arial, sans-serif; background: #f8fafc; color: #222;'>
      <div style='max-width: 480px; margin: 32px auto; background: #fff; border-radius: 12px; box-shadow: 0 2px 8px #0001; padding: 32px;'>
        <h2 style='margin: 0 0 8px 0; color: #1a56db;'>Firebase Configuration Required</h2>
        <div style='margin-bottom: 16px;'>Your Android build could not proceed because a valid Firebase configuration was not provided or was invalid.</div>
        <div style='margin-bottom: 16px; color: #a30237;'><b>How to Set Up Firebase for Android:</b></div>
        <ol style='margin-bottom: 8px;'>
          <li>Go to the <a href='https://console.firebase.google.com/' style='color:#1a56db;'>Firebase Console</a> and create a new project (or select your existing project).</li>
          <li>Add your Android app's package name: <b>[YOUR_PACKAGE_NAME]</b>.</li>
          <li>Download the <b>google-services.json</b> file.</li>
          <li>Upload the file to a secure location (e.g., GitHub, Google Drive) and provide the URL in the <b>firebase_config_android</b> variable.</li>
        </ol>
        <div style='margin-bottom: 8px;'>
          <b>Reference:</b> <a href='https://firebase.google.com/docs/android/setup' style='color:#1a56db;'>Firebase: Add Firebase to your Android project</a>
        </div>
        <div style='font-size:0.95em; color:#888;'>Styled by QuikApp Portal UI • quikapp.co</div>
      </div>
    </body>
  </html>
  """
fi

if [[ "$GUIDANCE_MODE" == "cer_guidance" ]]; then
  SUBJECT="[QuikApp] iOS Distribution Certificate (.cer) Guidance"
  EMAIL_BODY="""
  <html>
    <body style='font-family: \"Inter\", Arial, sans-serif; background: #f8fafc; color: #222;'>
      <div style='max-width: 480px; margin: 32px auto; background: #fff; border-radius: 12px; box-shadow: 0 2px 8px #0001; padding: 32px;'>
        <h2 style='margin: 0 0 8px 0; color: #1a56db;'>iOS Distribution Certificate (.cer) Required</h2>
        <div style='margin-bottom: 16px;'>Your iOS build could not proceed because a valid Apple Distribution Certificate (.cer) was not provided or was invalid.</div>
        <div style='margin-bottom: 16px; color: #a30237;'><b>How to Download Your .cer File:</b></div>
        <ol style='margin-bottom: 8px;'>
          <li>Go to the <a href='https://developer.apple.com/account/resources/certificates/list' style='color:#1a56db;'>Apple Developer Certificates</a> page.</li>
          <li>Select your Distribution Certificate and click <b>Download</b>.</li>
          <li>Upload the .cer file to a secure location (e.g., GitHub, Google Drive) and provide the URL in the <b>CERT_CER_URL</b> variable.</li>
        </ol>
        <div style='margin-bottom: 8px;'>
          <b>Reference:</b> <a href='https://docs.codemagic.io/code-signing/ios/' style='color:#1a56db;'>Codemagic: iOS code signing</a>
        </div>
        <div style='font-size:0.95em; color:#888;'>Styled by QuikApp Portal UI • quikapp.co</div>
      </div>
    </body>
  </html>
  """
fi

if [[ "$GUIDANCE_MODE" == "key_guidance" ]]; then
  SUBJECT="[QuikApp] iOS Private Key (.key) Guidance"
  EMAIL_BODY="""
  <html>
    <body style='font-family: \"Inter\", Arial, sans-serif; background: #f8fafc; color: #222;'>
      <div style='max-width: 480px; margin: 32px auto; background: #fff; border-radius: 12px; box-shadow: 0 2px 8px #0001; padding: 32px;'>
        <h2 style='margin: 0 0 8px 0; color: #1a56db;'>iOS Private Key (.key) Required</h2>
        <div style='margin-bottom: 16px;'>Your iOS build could not proceed because a valid private key (.key) was not provided or was invalid.</div>
        <div style='margin-bottom: 16px; color: #a30237;'><b>How to Export Your Private Key:</b></div>
        <ol style='margin-bottom: 8px;'>
          <li>Open <b>Keychain Access</b> on your Mac.</li>
          <li>Find your Distribution Certificate, right-click, and select <b>Export</b>.</li>
          <li>Choose <b>.p12</b> format, then extract the .key file using <b>openssl</b> if needed:<br>
            <pre style='background:#f1f5f9; padding:12px; border-radius:6px; font-size:0.95em;'>openssl pkcs12 -in exported.p12 -nocerts -out privatekey.key -nodes</pre>
          </li>
          <li>Upload the .key file to a secure location and provide the URL in the <b>CERT_KEY_URL</b> variable.</li>
        </ol>
        <div style='margin-bottom: 8px;'>
          <b>Reference:</b> <a href='https://docs.codemagic.io/code-signing/ios/' style='color:#1a56db;'>Codemagic: iOS code signing</a>
        </div>
        <div style='font-size:0.95em; color:#888;'>Styled by QuikApp Portal UI • quikapp.co</div>
      </div>
    </body>
  </html>
  """
fi

if [[ "$GUIDANCE_MODE" == "mobileprovision_guidance" ]]; then
  SUBJECT="[QuikApp] iOS Mobile Provision (.mobileprovision) Guidance"
  EMAIL_BODY="""
  <html>
    <body style='font-family: \"Inter\", Arial, sans-serif; background: #f8fafc; color: #222;'>
      <div style='max-width: 480px; margin: 32px auto; background: #fff; border-radius: 12px; box-shadow: 0 2px 8px #0001; padding: 32px;'>
        <h2 style='margin: 0 0 8px 0; color: #1a56db;'>iOS Mobile Provision (.mobileprovision) Required</h2>
        <div style='margin-bottom: 16px;'>Your iOS build could not proceed because a valid mobile provisioning profile (.mobileprovision) was not provided or was invalid.</div>
        <div style='margin-bottom: 16px; color: #a30237;'><b>How to Download Your Mobile Provision:</b></div>
        <ol style='margin-bottom: 8px;'>
          <li>Go to the <a href='https://developer.apple.com/account/resources/profiles/list' style='color:#1a56db;'>Apple Developer Profiles</a> page.</li>
          <li>Select your App Store or Ad Hoc profile and click <b>Download</b>.</li>
          <li>Upload the .mobileprovision file to a secure location and provide the URL in the <b>PROFILE_URL</b> variable.</li>
        </ol>
        <div style='margin-bottom: 8px;'>
          <b>Reference:</b> <a href='https://docs.codemagic.io/code-signing/ios/' style='color:#1a56db;'>Codemagic: iOS code signing</a>
        </div>
        <div style='font-size:0.95em; color:#888;'>Styled by QuikApp Portal UI • quikapp.co</div>
      </div>
    </body>
  </html>
  """
fi 