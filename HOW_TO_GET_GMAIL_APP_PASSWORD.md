# How to Get Gmail App Password (Step-by-Step with Pictures)

## 📧 What is a Gmail App Password?

A **Gmail App Password** is a special 16-character password that allows apps (like our classroom monitor) to send emails from your Gmail account. It's **NOT** your regular Gmail password - it's a separate password just for this app.

---

## 🔐 Step-by-Step Guide to Get Gmail App Password

### Step 1: Enable 2-Step Verification

**Important:** You MUST enable 2-Step Verification before you can create App Passwords.

#### 1.1 Go to Google Account Security Page

Open your browser and go to:
```
https://myaccount.google.com/security
```

**OR**

1. Go to Gmail: https://gmail.com
2. Click your **profile picture** (top right)
3. Click **"Manage your Google Account"**
4. Click **"Security"** on the left sidebar

#### 1.2 Find "2-Step Verification"

Scroll down to **"How you sign in to Google"** section

Look for **"2-Step Verification"**

#### 1.3 Enable 2-Step Verification

1. Click on **"2-Step Verification"**
2. Click **"Get Started"** button
3. Enter your Gmail password when prompted
4. Follow the steps to set up:
   - Enter your phone number
   - Choose SMS or phone call
   - Enter verification code you receive
   - Click **"Turn On"**

✅ **Done!** 2-Step Verification is now enabled.

---

### Step 2: Generate App Password

#### 2.1 Go to App Passwords Page

**Direct Link:**
```
https://myaccount.google.com/apppasswords
```

**OR manually:**

1. Go to: https://myaccount.google.com/security
2. Scroll to **"How you sign in to Google"**
3. Click **"2-Step Verification"**
4. Scroll down
5. Click **"App passwords"** at the bottom

#### 2.2 Sign In Again (if prompted)

Google may ask you to sign in again for security - enter your Gmail password.

#### 2.3 Create App Password

**You'll see a page titled "App passwords"**

1. Under **"Select app"** dropdown:
   - Choose **"Mail"**

2. Under **"Select device"** dropdown:
   - Choose **"Other (Custom name)"**

3. Type a name:
   ```
   Classroom Monitor
   ```

4. Click **"Generate"** button

#### 2.4 Copy Your App Password

🎉 **Google shows you a 16-character password!**

It looks like this:
```
abcd efgh ijkl mnop
```

**IMPORTANT:**
- ✅ **Copy this password** - you'll only see it once!
- ✅ Write it down somewhere safe
- ✅ You'll paste it into `config.yaml` in the next step

---

### Step 3: Add Password to Config File

#### 3.1 Open VS Code

1. Open **Visual Studio Code**
2. Open your **CLAUDE** folder
3. Navigate to: **`config/config.yaml`**

#### 3.2 Edit the File

Find this line (around line 28):
```yaml
email_password: "YOUR_APP_PASSWORD_HERE"
```

#### 3.3 Replace with Your Password

**Remove the spaces** from the password and paste it:

```yaml
email_password: "abcdefghijklmnop"
```

**Example:**
- ❌ Wrong: `"abcd efgh ijkl mnop"` (has spaces)
- ✅ Correct: `"abcdefghijklmnop"` (no spaces)

#### 3.4 Save the File

Press **`Ctrl+S`** to save.

---

### Step 4: Test It!

In VS Code terminal:

```bash
python test_email_config.py
```

When prompted, type **`yes`** and press Enter.

✅ **Check your email inboxes:**
- srimidhuna47@gmail.com
- 02midhuna@gmail.com

You should receive a test email! 🎉

---

## 🖼️ Visual Guide

### Screenshot 1: Google Account Security
```
myaccount.google.com/security
↓
"How you sign in to Google" section
↓
Click "2-Step Verification"
```

### Screenshot 2: Enable 2-Step Verification
```
Click "Get Started"
↓
Enter phone number
↓
Receive verification code
↓
Enter code
↓
Click "Turn On"
```

### Screenshot 3: App Passwords
```
myaccount.google.com/apppasswords
↓
Select app: "Mail"
↓
Select device: "Other (Custom name)"
↓
Type name: "Classroom Monitor"
↓
Click "Generate"
```

### Screenshot 4: Copy Password
```
You'll see:
┌─────────────────────────────────┐
│  Your app password is:          │
│                                 │
│  abcd efgh ijkl mnop           │
│                                 │
│  [Copy to clipboard]            │
└─────────────────────────────────┘
```

---

## 📝 Quick Summary

1. **Enable 2-Step Verification** (one-time setup)
   - Go to: https://myaccount.google.com/security
   - Enable 2-Step Verification with your phone

2. **Generate App Password** (takes 30 seconds)
   - Go to: https://myaccount.google.com/apppasswords
   - App: Mail
   - Device: Other (Classroom Monitor)
   - Click Generate

3. **Copy the 16-character password**

4. **Paste into `config/config.yaml`** (remove spaces)
   ```yaml
   email_password: "abcdefghijklmnop"
   ```

5. **Test it:**
   ```bash
   python test_email_config.py
   ```

---

## ❓ Frequently Asked Questions

### Q: Do I use my regular Gmail password?
**A: NO!** You must create a special App Password. Your regular password won't work.

### Q: Where do I create the App Password?
**A:** Go to: https://myaccount.google.com/apppasswords

### Q: I don't see "App passwords" option
**A:** You need to enable 2-Step Verification first. Go to:
https://myaccount.google.com/security

### Q: Can I use the same password for multiple apps?
**A:** You can, but it's better to generate separate passwords for security.

### Q: What if I lose the password?
**A:** No problem! Just generate a new one following the same steps.

### Q: The password has spaces, do I keep them?
**A:** NO! Remove all spaces when pasting into `config.yaml`

### Q: Do both emails need App Passwords?
**A:** NO! Only the **sender email** (srimidhuna47@gmail.com) needs an App Password. The parent email (02midhuna@gmail.com) will just receive emails.

---

## 🔒 Security Tips

✅ **DO:**
- Keep your App Password secret
- Use different App Passwords for different applications
- Revoke App Passwords for apps you no longer use

❌ **DON'T:**
- Share your App Password
- Commit `config.yaml` with password to public GitHub
- Use your regular Gmail password in the app

---

## 🆘 Troubleshooting

### Problem: "Username and Password not accepted"

**Solution:**
1. Make sure you're using the App Password, NOT your regular password
2. Check that you removed all spaces from the password
3. Try generating a new App Password

### Problem: "2-Step Verification not enabled"

**Solution:**
1. Go to https://myaccount.google.com/security
2. Enable 2-Step Verification first
3. Then generate App Password

### Problem: Can't find "App passwords" option

**Solution:**
1. Make sure you're signed in to the correct Gmail account (srimidhuna47@gmail.com)
2. Verify 2-Step Verification is enabled
3. Use this direct link: https://myaccount.google.com/apppasswords

### Problem: Email test fails with "SMTP Authentication Error"

**Solution:**
1. Double-check the password in `config.yaml`
2. Make sure there are NO spaces in the password
3. Verify the password is inside quotes: `"abcdefghijklmnop"`
4. Try generating a new App Password

---

## 🎯 What You're Looking For

When you go to https://myaccount.google.com/apppasswords, you'll see:

```
┌─────────────────────────────────────────┐
│         App passwords                    │
├─────────────────────────────────────────┤
│                                          │
│  Select the app and device you want     │
│  to generate the app password for.      │
│                                          │
│  Select app:     [Mail ▼]              │
│  Select device:  [Other (Custom) ▼]    │
│                                          │
│  Name: [Classroom Monitor___________]   │
│                                          │
│  [ GENERATE ]                           │
│                                          │
└─────────────────────────────────────────┘
```

After clicking Generate:

```
┌─────────────────────────────────────────┐
│  Generated app password                  │
├─────────────────────────────────────────┤
│                                          │
│  Your app password for your device is:   │
│                                          │
│  ┌──────────────────────────────────┐  │
│  │  abcd efgh ijkl mnop             │  │
│  └──────────────────────────────────┘  │
│                                          │
│  [ DONE ]                               │
│                                          │
└─────────────────────────────────────────┘
```

**Copy that password!** Then paste it into `config/config.yaml` (without spaces).

---

## ✅ Final Checklist

Before running the system:

- [ ] Logged into srimidhuna47@gmail.com
- [ ] 2-Step Verification enabled
- [ ] App Password generated (16 characters)
- [ ] Password copied
- [ ] `config/config.yaml` updated with password (no spaces)
- [ ] File saved (`Ctrl+S`)
- [ ] Test email sent successfully
- [ ] Both inboxes received test email

---

## 🎓 You're Done!

Once you see the test email in both inboxes, you're ready to run:

```bash
python main.py
```

Your classroom monitoring system will now send email alerts to:
- 👩‍🏫 **Teacher**: srimidhuna47@gmail.com
- 👪 **Parent**: 02midhuna@gmail.com

---

## 🔗 Important Links

| Link | Purpose |
|------|---------|
| https://myaccount.google.com/security | Google Account Security |
| https://myaccount.google.com/apppasswords | Generate App Password |
| https://gmail.com | Check your Gmail |

---

**Need more help?** Check these files:
- `EMAIL_SETUP_GUIDE.md` - Detailed email setup
- `VISUAL_STUDIO_SETUP.md` - VS Code setup guide
- `QUICK_REFERENCE.md` - Quick cheat sheet

**Repository:** https://github.com/chatgpt638100-cpu/CLAUDE

Happy monitoring! 📧✨
