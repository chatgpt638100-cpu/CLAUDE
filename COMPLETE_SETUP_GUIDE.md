# 🎓 Complete Setup Guide - Smart Classroom Monitoring System

## ⚠️ IMPORTANT: You MUST Follow These Steps!

---

## 🚀 **Step-by-Step Setup (5 Minutes)**

### **Step 1: Pull Latest Code**
```powershell
cd C:\Coding\CLAUDE
git pull
```

**You should see:**
```
Already up to date.
OR
Updating...
```

---

### **Step 2: Train the Model (CRITICAL!)**

**This is why you see "Unknown" and no face boxes!**

```powershell
cd src
python face_recognition.py train
```

**Expected Output:**
```
=== Face Recognition Training ===
Loading training data from C:\Coding\CLAUDE\data/students...
Loading 30 images for Bhava
Loading 30 images for Vishal
Loaded 60 training samples for 2 students
Training KNN classifier...
✓ Training completed!
Model saved to models/trained_knn_model.pkl

Model trained successfully with 2 students:
  - Bhava
  - Vishal
```

**❌ If you get error:** "No student directories found"
- Check: `C:\Coding\CLAUDE\data\students\`
- Should contain folders: `Bhava` (30 images), `Vishal` (30 images)

---

### **Step 3: Run the System**

```powershell
cd C:\Coding\CLAUDE
python main.py
```

**Expected Startup Output:**
```
✓ Loaded configuration from: config/config.yaml
Initializing Smart Classroom Monitoring System...
  ✓ Loading Face Detector...
  ✓ Loading Face Recognizer...
  ✓ Loading Anti-Proxy Verifier...
  ✓ Loading Behavior Analyzer...
  ✓ Loading Phone Detector...
  ✓ Loading Alert System...
  ✓ Email alerts configured

✓ System Ready!

======================================================================
SMART CLASSROOM MONITORING SYSTEM - ACTIVE
======================================================================
```

---

## 📺 **What You'll See On Screen:**

### **When Model is Trained:**

```
┌─────────────────────────────────┐
│  SMART CLASSROOM MONITORING     │  ← Status bar (top)
│  2026-07-11 13:00:00            │
└─────────────────────────────────┘

     ┌──────────────────┐
     │ Bhava            │  ← Name on green background
   ┌─┴──────────────────┴─┐
   │                       │
   │    👤 Face Here       │  ← Green box around face
   │                       │
   └───────────────────────┘
        SLEEPING (5s)        ← Status if eyes closed

     ┌──────────────────┐
     │ Vishal           │  ← Second student
   ┌─┴──────────────────┴─┐
   │                       │
   │    👤 Face Here       │  ← Green box
   │                       │
   └───────────────────────┘
```

### **Face Box Colors:**
- 🟢 **Green box** = Recognized student (Bhava, Vishal)
- 🔵 **Orange box** = Unknown face (not in database)

### **Text Display:**
- ✅ **Student name** - Always shows on top of face box
- ✅ **"SLEEPING (Xs)"** - Shows if eyes closed for 5+ seconds
- ❌ **Talking** - NOT shown on screen (only email alerts)

---

## 📧 **Email Alerts:**

### **When Configured:**
```
✓ Email sent to srimidhuna47@gmail.com
✓ Email sent to 02midhuna@gmail.com
```

### **If Not Configured:**
```
⚠️  WARNING: Email alerts enabled but password not configured!
   Edit config/config.yaml and set email_password
   Get App Password: https://myaccount.google.com/apppasswords
```

**To Configure:**
1. Open: `config/config.yaml`
2. Find line 54: `email_password: "YOUR_APP_PASSWORD_HERE"`
3. Replace with: `email_password: "zxnmzvvwCvbkkqest"` (your App Password)
4. Save and restart

---

## ✅ **Testing Checklist:**

| Test | What to Do | Expected Result |
|------|-----------|-----------------|
| **1. Model Trained?** | `dir models\trained_knn_model.pkl` | File exists |
| **2. Face Recognition** | Look at camera | Green box + your name on top |
| **3. Attendance** | Face camera for 2 seconds | "✓ Attendance marked for [Name]" |
| **4. Sleeping** | Close eyes 6 seconds | "SLEEPING (6s)" on screen + Email |
| **5. Talking** | Talk continuously 6s | Email sent (NO screen text) |
| **6. Phone** | Hold phone near face | Red box around phone |
| **7. Proxy Detection** | Use photo of face | "⚠️ PROXY DETECTED!" |

---

## 🐛 **Troubleshooting:**

### **Problem 1: Always Shows "Unknown"**
**Cause:** Model not trained

**Fix:**
```powershell
cd C:\Coding\CLAUDE\src
python face_recognition.py train
```

---

### **Problem 2: No Face Box Visible**
**Cause:** Model not trained (recognition returns empty list)

**Fix:** Train the model (see above)

---

### **Problem 3: No Emails Sent**
**Cause:** Email password not configured in config.yaml

**Fix:**
1. Open `config/config.yaml`
2. Line 54: Change `YOUR_APP_PASSWORD_HERE` to your App Password
3. Save and restart

**To Get App Password:**
1. Visit: https://myaccount.google.com/apppasswords
2. Sign in with srimidhuna47@gmail.com
3. Generate App Password for "Mail"
4. Copy 16-character password
5. Paste in config.yaml

---

### **Problem 4: Talking Detected When Mouth Closed**
**Cause:** Old code version

**Fix:**
```powershell
cd C:\Coding\CLAUDE
git pull
```

Thresholds are now very strict:
- mar_std > 0.12 (high movement)
- mar_range > 0.25 (wide opening)
- mar_mean > 0.30 (significant opening)

---

### **Problem 5: Terminal Spam**
**Cause:** Old code version

**Fix:**
```powershell
git pull
```

Terminal is now clean - only shows important messages.

---

## 📊 **File Locations:**

| File | Location | Purpose |
|------|----------|---------|
| **Model** | `models/trained_knn_model.pkl` | Face recognition (MUST exist!) |
| **Student Images** | `data/students/Bhava/`, `data/students/Vishal/` | Training data |
| **Config** | `config/config.yaml` | Email, thresholds, settings |
| **Attendance Log** | `data/attendance_logs/YYYY-MM-DD.json` | Daily attendance JSON |
| **Attendance Excel** | `data/attendance/attendance_YYYY-MM-DD.xlsx` | Excel export |
| **Behavior Logs** | `data/behavior_logs/YYYY-MM-DD.json` | Sleeping/talking logs |

---

## 🎯 **Quick Start Commands:**

```powershell
# 1. Navigate to project
cd C:\Coding\CLAUDE

# 2. Pull latest code
git pull

# 3. Train model (if not done)
cd src
python face_recognition.py train
cd ..

# 4. Run system
python main.py

# 5. Test
#    - Face camera → Should see green box + name
#    - Close eyes 6s → SLEEPING alert
#    - Check emails
```

---

## ✅ **Success Indicators:**

**You'll know it's working when:**
1. ✅ Terminal shows: "✓ Loaded configuration from: config/config.yaml"
2. ✅ Terminal shows: "✓ Email alerts configured"
3. ✅ **Green box appears around your face** (most important!)
4. ✅ **Your name shows on top of the box** (white text, green background)
5. ✅ Terminal shows: "✓ Attendance marked for [Your Name]"
6. ✅ Excel file created in `data/attendance/`

---

## 🚨 **Most Common Mistake:**

**❌ RUNNING WITHOUT TRAINING MODEL**

```powershell
# WRONG - Will show "Unknown" forever!
python main.py  ← Model doesn't exist!
```

```powershell
# CORRECT - Train first!
cd src
python face_recognition.py train  ← Creates model
cd ..
python main.py  ← Now it works!
```

---

## 📞 **Need Help?**

Check these in order:
1. ✅ Model file exists: `dir models\trained_knn_model.pkl`
2. ✅ Config loaded: Terminal says "✓ Loaded configuration from:"
3. ✅ Students exist: `dir data\students\` (should show Bhava, Vishal)
4. ✅ Images exist: `dir data\students\Bhava\` (should show 30 images)

---

## 🎓 **You're Ready!**

Once model is trained:
- Face boxes will appear ✅
- Names will show ✅  
- Attendance works ✅
- Emails send ✅
- Clean terminal ✅

**Train the model now and everything will work!** 🚀✨
