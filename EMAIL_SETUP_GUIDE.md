# Email Alert Setup Guide

The system is configured to send email alerts to:
- **Teacher**: srimidhuna47@gmail.com
- **Parent**: 02midhuna@gmail.com

## 🔐 Gmail App Password Setup

Since you're using Gmail, you need to create an **App Password** (Google's security requirement):

### Step 1: Enable 2-Step Verification

1. Go to: https://myaccount.google.com/security
2. Scroll to "Signing in to Google"
3. Click on "2-Step Verification"
4. Follow the steps to enable it (if not already enabled)

### Step 2: Generate App Password

1. Go to: https://myaccount.google.com/apppasswords
2. You may need to sign in again
3. In "Select app" dropdown, choose **Mail**
4. In "Select device" dropdown, choose **Other (Custom name)**
5. Type "Classroom Monitor" as the name
6. Click **Generate**
7. Google will show you a 16-character password (like: `abcd efgh ijkl mnop`)
8. **Copy this password** - you'll need it in the next step

### Step 3: Update Configuration

Edit `config/config.yaml` and replace the line:

```yaml
email_password: "YOUR_APP_PASSWORD_HERE"
```

With your actual app password (remove spaces):

```yaml
email_password: "abcdefghijklmnop"
```

## ⚙️ Updated Alert Thresholds

Your system is now configured with these exact specifications:

| Behavior | Threshold | Alert Trigger |
|----------|-----------|---------------|
| **Sleeping** | 5 seconds | Eyes closed for 5 seconds |
| **Talking** | 5 seconds | Mouth moving for 5 seconds |
| **Proxy** | No blinks | Eyes open but no blinking detected |
| **Phone** | Immediate | Rectangular phone detected on screen |

## 📧 Email Notifications

Alerts will be sent via email for:
- ✅ Student sleeping (> 5 seconds)
- ✅ Excessive talking (> 5 seconds)
- ✅ Proxy attendance detected
- ✅ Mobile phone usage
- ✅ Multiple violations

### Email Content Example

```
Subject: [WARNING] Classroom Alert - SLEEPING

Classroom Monitoring Alert

Alert ID: 123
Type: SLEEPING
Severity: WARNING
Student: John Doe
Time: 2024-01-15 10:30:45

Message: John Doe has been sleeping for 8 seconds

Details: {
  "duration": 8.2,
  "ear": 0.18
}

---
Automated Smart Classroom Monitoring System
```

## 🧪 Testing Email Setup

Test the email configuration without running the full system:

```bash
cd src
python -c "
from alert_system import AlertSystem
import yaml

# Load config
with open('../config/config.yaml', 'r') as f:
    config = yaml.safe_load(f)

# Create alert system
alert_system = AlertSystem(config['alert_config'])

# Send test alert
alert_system.create_alert(
    alert_type='SLEEPING',
    severity='WARNING',
    student_name='Test Student',
    message='Test alert - Email system is working!',
    details={'test': True}
)

print('Test email sent! Check both inboxes.')
"
```

## 🔍 Troubleshooting

### Issue: "Username and Password not accepted"
**Solution**: Make sure you're using the App Password, not your regular Gmail password.

### Issue: "SMTP Authentication Error"
**Solution**: 
1. Double-check the App Password is correct (no spaces)
2. Verify 2-Step Verification is enabled
3. Try generating a new App Password

### Issue: Emails not arriving
**Solution**:
1. Check spam/junk folders
2. Verify email addresses are correct in config.yaml
3. Check console for error messages

### Issue: "Less secure app access"
**Solution**: Gmail no longer supports this. You MUST use App Passwords.

## 📱 Alternative Email Providers

If you want to use a different email service:

### For Outlook/Hotmail:
```yaml
email_smtp_server: "smtp-mail.outlook.com"
email_smtp_port: 587
email_sender: "your-email@outlook.com"
email_password: "your-password"
```

### For Yahoo Mail:
```yaml
email_smtp_server: "smtp.mail.yahoo.com"
email_smtp_port: 587
email_sender: "your-email@yahoo.com"
email_password: "your-app-password"  # Yahoo also requires app passwords
```

### For Custom SMTP Server:
```yaml
email_smtp_server: "your-smtp-server.com"
email_smtp_port: 587  # or 465 for SSL
email_sender: "your-email@domain.com"
email_password: "your-password"
```

## 🔒 Security Best Practices

1. ✅ Never commit `config.yaml` with passwords to public repositories
2. ✅ Use environment variables for sensitive data (optional):
   ```bash
   export EMAIL_PASSWORD="your-app-password"
   ```
3. ✅ Keep App Passwords secure
4. ✅ Revoke App Passwords if compromised
5. ✅ Use different App Passwords for different applications

## 📊 Alert Frequency

With the current settings:
- **Cooldown**: 60 seconds between same alerts for the same student
- This prevents spam while ensuring important alerts are sent
- Each unique violation triggers an email

## 🎯 What Gets Emailed

### Always Sends Email:
- ✅ First detection of sleeping (after 5 seconds)
- ✅ First detection of talking (after 5 seconds)
- ✅ Phone usage detected
- ✅ Proxy attendance attempt
- ✅ Multiple violations threshold exceeded

### Cooldown Applied:
- Same student, same behavior within 60 seconds → No duplicate email
- Different behavior → New email sent
- After 60 seconds → New email can be sent

## 📝 Quick Reference

**Teacher Email**: srimidhuna47@gmail.com  
**Parent Email**: 02midhuna@gmail.com  
**Sleeping Threshold**: 5 seconds (eyes closed)  
**Talking Threshold**: 5 seconds (mouth moving)  
**Proxy Detection**: No blinks with eyes open  
**Phone Detection**: Immediate (rectangular object)  
**Alert Cooldown**: 60 seconds  

---

## ✅ Final Checklist

Before running the system:

- [ ] 2-Step Verification enabled on srimidhuna47@gmail.com
- [ ] App Password generated
- [ ] `config/config.yaml` updated with App Password
- [ ] Test email sent successfully
- [ ] Both inboxes checked and receiving alerts
- [ ] Student face data collected
- [ ] Model trained

Once complete, run:
```bash
python main.py
```

The system will now send real-time email alerts to both teacher and parent! 📧✨
