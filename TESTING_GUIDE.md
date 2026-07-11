# Smart Classroom Monitoring System - Testing Guide

## 🎯 Test Scenarios by Student

### **Student: BHAVA**
**Test:** TALKING Detection Only

**Steps:**
1. Start the system: `python main.py`
2. Bhava's face should be recognized
3. **Open mouth VERY WIDE** (show teeth) and keep it open
4. Talk continuously for **5+ seconds**
5. System should detect talking after 5 seconds

**Expected Results:**
- ✅ Console message: `[timestamp] Bhava started talking`
- ✅ Email alert sent to:
  - `srimidhuna47@gmail.com` with greeting: **"Dear Teacher"**
  - `02midhuna@gmail.com` with greeting: **"Dear Parents"**
- ✅ Alert includes: Student name, behavior type, timestamp
- ❌ **NO proxy detection** for Bhava
- ❌ **NO sleeping detection** for Bhava

**Talking Detection Criteria:**
- MAR (Mouth Aspect Ratio) > 0.5 = Teeth showing
- Must be sustained for 150 frames (5 seconds)

---

### **Student: VISHAL**
**Test 1:** PROXY Detection (No Blink)

**Steps:**
1. Start the system: `python main.py`
2. Vishal's face should be recognized
3. **Keep eyes WIDE OPEN** - DO NOT BLINK for 8 seconds
4. Stare at camera without blinking

**Expected Results:**
- ✅ Console message: `🔍 Starting 8-second liveness check for Vishal...`
- ✅ After 8 seconds: `🚨 PROXY DETECTED: Vishal - No blink detected in 8 seconds!`
- ✅ Email alert sent with **"PROXY ATTENDANCE ATTEMPT"**
- ✅ Attendance should **NOT** be marked

**Test 2:** MOBILE PHONE Detection

**Steps:**
1. Start the system: `python main.py`
2. Vishal's face should be recognized
3. Hold a phone near your face
4. Keep phone visible for 1+ second

**Expected Results:**
- ✅ Console message: `📱 MOBILE PHONE DETECTED! Confidence: X.XX`
- ✅ Red rectangle drawn around phone
- ✅ "PHONE: X.XX" label on phone
- ✅ "User: Vishal" label if phone is near face
- ✅ Email alert sent: **"Phone usage detected for Vishal"**

---

### **Student: PRIYA**
**Test:** SLEEPING Detection Only

**Steps:**
1. Start the system: `python main.py`
2. Priya's face should be recognized
3. **Close eyes completely** for 5+ seconds
4. Keep eyes closed (don't open)

**Expected Results:**
- ✅ Console message: `[timestamp] Priya started sleeping`
- ✅ "SLEEPING (Xs)" text displayed below face
- ✅ Email alert sent after 5 seconds
- ❌ **NO proxy detection** for Priya
- ❌ **NO talking detection** for Priya

**Sleeping Detection Criteria:**
- EAR (Eye Aspect Ratio) < 0.20 = Eyes closed
- Must be sustained for 150 frames (5 seconds)

---

## 📧 Email Alert Format

### Teacher Email (`srimidhuna47@gmail.com`)
```
Subject: Classroom Alert: [BEHAVIOR] Detected

Dear Teacher,

Alert Details:
Student Name: [Name]
Behavior: [Sleeping/Talking/Phone Usage/Proxy Attempt]
Timestamp: [YYYY-MM-DD HH:MM:SS]
Duration/Details: [X seconds / Additional info]

Please take appropriate action.

Best regards,
Smart Classroom Monitoring System
```

### Parent Email (`02midhuna@gmail.com`)
```
Subject: Classroom Alert: [BEHAVIOR] Detected

Dear Parents,

Alert Details:
Student Name: [Name]
Behavior: [Sleeping/Talking/Phone Usage/Proxy Attempt]
Timestamp: [YYYY-MM-DD HH:MM:SS]
Duration/Details: [X seconds / Additional info]

Please take appropriate action.

Best regards,
Smart Classroom Monitoring System
```

---

## 🔍 Detection Thresholds Reference

| Detection | Threshold | Duration | Trigger |
|-----------|-----------|----------|---------|
| **Sleeping** | EAR < 0.20 | 5 seconds (150 frames) | Eyes closed |
| **Talking** | MAR > 0.5 | 5 seconds (150 frames) | Teeth showing (wide mouth) |
| **Proxy** | No blink | 8 seconds | Eyes open, no EAR drop |
| **Phone** | YOLOv8 confidence > 0.3 | 1 second | Rectangular object detected |

---

## ⚙️ System Performance

**Frame Processing:**
- Display: 60 FPS (every frame shows cached result)
- Processing: Every 3 frames (20 FPS processing)
- Face Detection: Every 20 frames (3/sec)
- Face Recognition: Every 40 frames (1.5/sec)
- Behavior Analysis: Every 90 frames (0.67/sec)
- Phone Detection: Every 120 frames (0.5/sec)

---

## 🚨 Common Issues & Solutions

### Issue: No rectangular frame around face
**Solution:** Face not recognized yet. Wait for face recognition (runs every 40 frames = 1.3 seconds)

### Issue: Email not sent
**Check:**
1. Email password set in `config/config.yaml` line 54
2. Using Gmail App Password (not regular password)
3. Internet connection active
4. Console shows no email errors

### Issue: Blink not detected (proxy warning)
**Solution:** Blink slowly and clearly - EAR must go below 0.21 for 3+ frames

### Issue: Talking not detected
**Solution:** Open mouth VERY WIDE (show teeth) - MAR must be > 0.5

### Issue: Sleeping not detected
**Solution:** Close eyes completely - EAR must go below 0.20 for 5+ seconds

---

## 📊 Testing Checklist

- [ ] **Bhava - Talking:** Open mouth wide (teeth show) for 5+ seconds
- [ ] **Bhava - Email:** Check both teacher and parent emails received
- [ ] **Vishal - Proxy:** Keep eyes open, no blink for 8 seconds
- [ ] **Vishal - Phone:** Hold phone near face for 1+ second
- [ ] **Vishal - Emails:** Check proxy alert and phone alert emails
- [ ] **Priya - Sleeping:** Close eyes for 5+ seconds
- [ ] **Priya - Email:** Check sleeping alert email
- [ ] **Email Greetings:** Verify "Dear Teacher" vs "Dear Parents"
- [ ] **Performance:** Check video is smooth (60 FPS)
- [ ] **Attendance:** Check Excel file generated in `data/attendance/`

---

## 🎯 Quick Start Commands

```powershell
# Navigate to project
cd C:\Coding\CLAUDE

# Pull latest code
git pull

# Run system
python main.py

# During runtime:
# q - Quit
# a - Mark attendance manually (for testing)
# r - Generate report
# s - Show statistics
```

---

## 📁 Output Files

**Attendance:** `data/attendance/attendance_YYYY-MM-DD.xlsx`
**Behavior Logs:** `data/behavior_logs/YYYY-MM-DD.json`
**Alert Reports:** `data/alerts/daily_report_YYYY-MM-DD.xlsx`

---

**Last Updated:** 2026-07-10
**System Version:** Extreme Performance Mode v1.0
