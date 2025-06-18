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
trap 'handle_error "Email sending failed at line $LINENO"' ERR

# Validate required variables
if [ -z "$EMAIL_SMTP_SERVER" ] || [ -z "$EMAIL_SMTP_PORT" ] || [ -z "$EMAIL_SMTP_USER" ] || [ -z "$EMAIL_SMTP_PASS" ] || [ -z "$EMAIL_ID" ]; then
    handle_error "Missing required email configuration"
fi

# Parse arguments
STATUS=$1
MESSAGE=$2

# Set email subject and body based on status
case "$STATUS" in
    "started")
        SUBJECT="🚀 Build Started: $APP_NAME"
        BODY="Build process has started for $APP_NAME (Version: $VERSION_NAME)"
        ;;
    "success")
        SUBJECT="✅ Build Success: $APP_NAME"
        BODY="Build completed successfully for $APP_NAME (Version: $VERSION_NAME)"
        ;;
    "failure")
        SUBJECT="❌ Build Failed: $APP_NAME"
        BODY="Build failed for $APP_NAME (Version: $VERSION_NAME)\n\nError: $MESSAGE"
        ;;
    *)
        handle_error "Invalid status: $STATUS"
        ;;
esac

# Send email using curl
log "📧 Sending email notification to $EMAIL_ID"
curl -s --url "smtp://$EMAIL_SMTP_SERVER:$EMAIL_SMTP_PORT" \
    --mail-from "$EMAIL_SMTP_USER" \
    --mail-rcpt "$EMAIL_ID" \
    --user "$EMAIL_SMTP_USER:$EMAIL_SMTP_PASS" \
    --upload-file - << EOF
From: $EMAIL_SMTP_USER
To: $EMAIL_ID
Subject: $SUBJECT
Content-Type: text/plain; charset=UTF-8

$BODY

Build Details:
- App Name: $APP_NAME
- Version: $VERSION_NAME
- Package: $PKG_NAME
- Build Time: $(date)

EOF

log "✅ Email notification sent successfully!"
exit 0 