# 📧 Email Alert Setup Guide

## 🎯 Enable Email Notifications

To receive email alerts for sleeping, talking, and phone usage, you need to configure Gmail App Password.

---

## 📋 Step-by-Step Setup

### **Step 1: Enable 2-Step Verification** (Required)

1. Go to: **https://myaccount.google.com/security**
2. Scroll to **"How you sign in to Google"**
3. Click **"2-Step Verification"**
4. Follow the steps to enable it (if not already enabled)

---

### **Step 2: Generate App Password**

1. Go to: **https://myaccount.google.com/apppasswords**
2. You may need to sign in again
3. **Select app:** Choose **"Mail"**
4. **Select device:** Choose **"Windows Computer"** or **"Other (Custom name)"**
5. Click **"Generate"**
6. Copy the **16-character password** (e.g., `abcd efgh ijkl mnop`)

⚠️ **IMPORTANT**: Save this password - you won't see it again!

---

### **Step 3: Update config.yaml**

1. Open file: `C:\Coding\CLAUDE\config\config.yaml`
2. Find the email configuration section (around line 30):

```yaml
# Email configuration
email_smtp_server: "smtp.gmail.com"
email_smtp_port: 587
email_sender: "srimidhuna47@gmail.com"       # Teacher's email (sender)
email_password: "YOUR_APP_PASSWORD_HERE"      # ← CHANGE THIS
email_recipients: 
  - "srimidhuna47@gmail.com"                  # Teacher email
  - "02midhuna@gmail.com"                     # Parent email
```

3. Replace `YOUR_APP_PASSWORD_HERE` with your 16-character App Password:

```yaml
email_password: "abcd efgh ijkl mnop"  # ← Your actual App Password (no spaces in YAML)
```

Or remove spaces:
```yaml
email_password: "abcdefghijklmnop"  # 16 characters, no spaces
```

4. **Save the file**

---

### **Step 4: Verify Configuration**

Run the system:
```powershell
cd C:\Coding\CLAUDE
python main.py
```

**If configured correctly:**
- System will NOT show warning messages
- Alerts will be sent via email

**If NOT configured:**
```
⚠ Email alerts disabled: Please configure Gmail App Password in config/config.yaml
   Visit: https://myaccount.google.com/apppasswords to generate one
```

---

## 📧 Email Alert Behavior

### **When Alerts Are Sent:**

| Behavior | Trigger | Email Sent To |
|----------|---------|---------------|
| **Sleeping** | Eyes closed for 5+ seconds | Teacher + Parents |
| **Talking** | Continuous talking for 5+ seconds | Teacher + Parents |
| **Phone Usage** | Phone detected near face | Teacher + Parents |

### **Email Format:**

#### **To Teacher** (srimidhuna47@gmail.com):
```
Dear Teacher,

This is an automated alert from the Smart Classroom Monitoring System.

Alert Information:
==================
Type: SLEEPING
Severity: WARNING
Student: Bhava
Time: 2026-07-11 11:30:45

Alert Message:
Student has been sleeping for 7 seconds

Additional Details:
{
  "duration": 7,
  "threshold": 5
}

---
This is an automated message from the Smart Classroom Monitoring System.
```

#### **To Parents** (02midhuna@gmail.com):
```
Dear Parents,

This is an automated alert from the Smart Classroom Monitoring System.

Alert Information:
==================
Type: SLEEPING
Severity: WARNING
Student: Bhava
Time: 2026-07-11 11:30:45

Alert Message:
Student has been sleeping for 7 seconds

Additional Details:
{
  "duration": 7,
  "threshold": 5
}

---
This is an automated message from the Smart Classroom Monitoring System.
```

---

## 🔒 Security Notes

### **App Password vs Regular Password**
- ✅ **Use:** 16-character App Password (more secure)
- ❌ **Don't use:** Your regular Gmail password (won't work)

### **Keep It Safe**
- Don't share your App Password
- Don't commit it to public repositories (keep config.yaml private)
- You can revoke it anytime at: https://myaccount.google.com/apppasswords

---

## 🛠️ Troubleshooting

### **Error: "Email authentication failed"**
**Cause:** Wrong App Password or 2-Step Verification not enabled

**Fix:**
1. Verify 2-Step Verification is ON
2. Generate a NEW App Password
3. Update config.yaml with the new password
4. Remove any spaces from the password

---

### **Error: "Less secure app access"**
**Cause:** Trying to use regular password instead of App Password

**Fix:**
- Don't enable "Less secure app access" (deprecated)
- Use App Password instead (modern, secure method)

---

### **No Emails Received**
**Check:**
1. ✅ App Password is correct in config.yaml
2. ✅ Email addresses are correct
3. ✅ Check spam/junk folder
4. ✅ Behavior actually triggers (e.g., eyes closed 5+ seconds)
5. ✅ Alert cooldown period (60 seconds between same alerts)

---

## ✅ Quick Test

To test if emails work:

1. Configure App Password in config.yaml
2. Run: `python main.py`
3. Close your eyes for 6 seconds → Should send "SLEEPING" alert
4. Check both email inboxes (teacher + parent)

---

## 📝 Current Configuration

**Teacher Email (Sender):** srimidhuna47@gmail.com
**Parent Email:** 02midhuna@gmail.com

**Both will receive:**
- Sleeping alerts
- Talking alerts  
- Phone usage alerts

**Email will say:**
- "Dear Teacher," for srimidhuna47@gmail.com
- "Dear Parents," for 02midhuna@gmail.com

---

## 🎓 Perfect for Smart Educational Institutions!

Once configured, the system will automatically notify teachers and parents about student behavior in real-time!
