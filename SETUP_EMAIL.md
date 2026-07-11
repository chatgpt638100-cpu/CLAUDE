# 📧 Email Setup Instructions

## ⚠️ IMPORTANT: Configure Email Password

Your email is **NOT configured yet**. To enable email alerts, you need to set up a Gmail App Password.

---

## 🔧 Steps to Enable Email Alerts:

### **Step 1: Create Gmail App Password**

1. Go to your Google Account: https://myaccount.google.com/security
2. **Enable 2-Step Verification** (if not already enabled)
3. Go to App Passwords: https://myaccount.google.com/apppasswords
4. Select "Mail" and "Windows Computer" (or "Other")
5. Click **Generate**
6. Copy the **16-character password** (something like: `abcd efgh ijkl mnop`)

### **Step 2: Update Configuration File**

Open `config/config.yaml` and replace this line:

```yaml
email_password: "YOUR_APP_PASSWORD_HERE"
```

With your actual app password:

```yaml
email_password: "abcd efgh ijkl mnop"
```

**Note:** Use the app password, NOT your regular Gmail password!

### **Step 3: Save and Test**

1. Save the `config/config.yaml` file
2. Run the system: `python main.py`
3. Show Bhava's face → wait 5 seconds
4. You should see: `"Bhava is talking email sent to teacher"`
5. Check email inbox: `srimidhuna47@gmail.com`

---

## 📋 Current Email Configuration:

**Sender (Teacher):** `srimidhuna47@gmail.com`
**Recipients:**
- Teacher: `srimidhuna47@gmail.com`
- Parent: `02midhuna@gmail.com`

**Email Rules:**
- **Bhava:** Email to teacher only
- **Vishal:** Email to both teacher and parent
- **Priya:** Email to teacher only

---

## 🚨 Troubleshooting

### **If you see error message:**

```
Bhava is talking email FAILED to send: [error message]
```

**Common fixes:**

1. **"Missing email password"**
   - Solution: Add app password to `config/config.yaml` line 54

2. **"Authentication failed"**
   - Solution: Make sure you're using **App Password**, not regular password
   - Make sure 2-Step Verification is enabled in Google Account

3. **"SMTP server error"**
   - Solution: Check internet connection
   - Make sure Gmail SMTP is not blocked by firewall

4. **"Password incorrect"**
   - Solution: Generate a NEW app password
   - Copy it exactly (with or without spaces, both work)

---

## ✅ Email Configuration File Location

**File:** `C:\Coding\CLAUDE\config\config.yaml`

**Line 54:** Replace `YOUR_APP_PASSWORD_HERE` with your Gmail app password

---

## 🧪 Testing Email

After configuring, test each student:

### **Test 1: Bhava**
```
python main.py
# Show Bhava face for 5 seconds
# Expected: "Bhava is talking email sent to teacher"
# Check: srimidhuna47@gmail.com inbox
```

### **Test 2: Vishal**
```
# Show Vishal face for 5 seconds
# Expected: "Vishal is not blinking and is using a mobile phone email sent to teacher and parent"
# Check: Both srimidhuna47@gmail.com and 02midhuna@gmail.com inboxes
```

### **Test 3: Priya**
```
# Show Priya face for 5 seconds
# Expected: "Priya is sleeping email sent to teacher"
# Check: srimidhuna47@gmail.com inbox
```

---

## 📝 Email Message Format

**Subject:** `[SEVERITY] Classroom Alert - ALERT_TYPE`

**Body:**
```
Dear Teacher, (or Dear Parents,)

This is an automated alert from the Smart Classroom Monitoring System.

Alert Information:
==================
Type: TALKING / PROXY_DETECTED / SLEEPING
Severity: INFO / CRITICAL / WARNING
Student: Bhava / Vishal / Priya
Time: 2026-07-11 14:30:45

Alert Message:
Bhava is talking in class

Additional Details:
{
  "duration": 5
}

---
This is an automated message from the Smart Classroom Monitoring System.
For any questions, please contact the school administration.
```

---

## 🎯 Quick Setup (Copy-Paste)

1. **Get your Gmail App Password** (16 characters)
2. **Open:** `C:\Coding\CLAUDE\config\config.yaml`
3. **Find line 54:** `email_password: "YOUR_APP_PASSWORD_HERE"`
4. **Replace with:** `email_password: "your-app-password-here"`
5. **Save file**
6. **Run:** `python main.py`
7. **Test:** Show student face for 5 seconds

Done! 🎉
