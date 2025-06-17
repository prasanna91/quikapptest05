import smtplib
import ssl
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import sys

def send_email(smtp_server, smtp_port, sender_email, sender_password, receiver_email, subject, body_file):
    """Sends an email with HTML content."""
    
    with open(body_file, 'r') as f:
        html_body = f.read()

    message = MIMEMultipart("alternative")
    message["Subject"] = subject
    message["From"] = sender_email
    message["To"] = receiver_email

    # Turn these into plain/html MIMEText objects
    part1 = MIMEText(html_body, "html")

    # Add HTML part to MIMEMultipart message
    # The email client will try to render the last part first
    message.attach(part1)

    context = ssl.create_default_context()
    try:
        with smtplib.SMTP_SSL(smtp_server, int(smtp_port), context=context) as server:
            server.login(sender_email, sender_password)
            server.sendmail(sender_email, receiver_email, message.as_string())
        print("Email sent successfully!")
    except Exception as e:
        print(f"Error sending email: {e}")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 9:
        print("Usage: python send_email_python.py <smtp_server> <smtp_port> <sender_email> <sender_password> <sender_email_again_from_bash> <recipient_email> <subject> <body_file>")
        sys.exit(1)

    smtp_server = sys.argv[1]
    smtp_port = sys.argv[2]
    sender_email = sys.argv[3]
    sender_password = sys.argv[4]
    # The fifth argument is also the sender's email, as passed from config.sh
    # We will use the sixth argument as the actual receiver email
    receiver_email = sys.argv[6] 
    subject = sys.argv[7]
    body_file = sys.argv[8]

    send_email(smtp_server, smtp_port, sender_email, sender_password, receiver_email, subject, body_file) 