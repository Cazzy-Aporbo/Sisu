import imaplib
import email
from email.header import decode_header

# Your credentials
USERNAME = "your_email@example.com"
PASSWORD = "your_password"  # For Gmail, use an App Password

# Connect to the IMAP server
# For Gmail use 'imap.gmail.com', Outlook 'imap-mail.outlook.com'
imap = imaplib.IMAP4_SSL("imap.gmail.com")

# Login to your account
imap.login(USERNAME, PASSWORD)

# Select the mailbox you want to read, e.g., INBOX
imap.select("INBOX")

# Search for all emails
status, messages = imap.search(None, "ALL")
email_ids = messages[0].split()

print(f"Total emails: {len(email_ids)}")

# Fetch the last 5 emails
for i in email_ids[-5:]:
    res, msg = imap.fetch(i, "(RFC822)")
    for response in msg:
        if isinstance(response, tuple):
            msg_obj = email.message_from_bytes(response[1])
            subject, encoding = decode_header(msg_obj["Subject"])[0]
            if isinstance(subject, bytes):
                subject = subject.decode(encoding if encoding else "utf-8")
            from_ = msg_obj.get("From")
            print(f"From: {from_}")
            print(f"Subject: {subject}")
            print("=" * 50)

# Logout when done
imap.logout()