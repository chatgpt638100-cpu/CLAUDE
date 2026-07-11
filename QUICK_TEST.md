# Quick Testing Reference

## 🚀 Start System
```powershell
cd C:\Coding\CLAUDE
git pull
python main.py
```

---

## 🎯 Test Each Student

### **BHAVA - Talking**
**Action:** Open mouth VERY WIDE (show teeth) for 5+ seconds

**Expected Console Output:**
```
✉️ Bhava - Talking detected → Email sent
```

**Expected Emails:**
- `srimidhuna47@gmail.com` → "Dear Teacher, ..."
- `02midhuna@gmail.com` → "Dear Parents, ..."

---

### **VISHAL - Proxy**
**Action:** Keep eyes WIDE OPEN, DON'T BLINK for 8 seconds

**Expected Console Output:**
```
✉️ Vishal - Proxy attempt detected → Email sent
```

**Expected:** Attendance NOT marked

---

### **VISHAL - Phone**
**Action:** Hold phone near face for 1+ second

**Expected Console Output:**
```
✉️ Vishal - Phone usage detected → Email sent
```

**Expected:** Red box around phone on screen

---

### **PRIYA - Sleeping**
**Action:** Close eyes completely for 5+ seconds

**Expected Console Output:**
```
✉️ Priya - Sleeping detected → Email sent
```

**Expected:** "SLEEPING" text on screen below face

---

## ⚙️ Detection Thresholds

- **Talking:** MAR > 0.5 (very wide mouth) for 5 seconds
- **Sleeping:** EAR < 0.20 (eyes closed) for 5 seconds  
- **Proxy:** No blink (no EAR drop below 0.21) for 8 seconds
- **Phone:** YOLOv8 detects cell phone with confidence > 0.3

---

## 📧 Email Greetings

- Teacher (`srimidhuna47@gmail.com`): **"Dear Teacher,"**
- Parent (`02midhuna@gmail.com`): **"Dear Parents,"**

---

## ✅ System is SILENT

**Only console output:**
- Simple email confirmation messages
- NO debug output
- NO detection spam
- NO verbose logs

**Just:**
```
✉️ [Student] - [Behavior] → Email sent
```

---

## 🔧 Controls

- **q** - Quit
- **SPACE** - Pause/Resume
- **a** - Manual attendance mark (for testing)
- **r** - Generate report
- **s** - Show statistics

---

**Version:** Silent Mode v1.0
**Last Updated:** 2026-07-10
