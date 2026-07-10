# Quick Reference Card

## 📋 System Configuration Summary

| Setting | Value | Description |
|---------|-------|-------------|
| **Sleeping Alert** | 5 seconds | Eyes closed for 5 seconds triggers alert |
| **Talking Alert** | 5 seconds | Mouth moving for 5 seconds triggers alert |
| **Proxy Detection** | No blinks | Eyes open but no blinking = proxy attendance |
| **Phone Detection** | Immediate | Rectangular phone object detected = instant alert |
| **Teacher Email** | srimidhuna47@gmail.com | Primary alert recipient |
| **Parent Email** | 02midhuna@gmail.com | Secondary alert recipient |

## 🚀 Quick Start Commands

```bash
# 1. Collect student faces (do once per student)
cd src
python collect_faces.py --name "Student Name" --images 30

# 2. Train the model (do after adding students)
python face_recognition.py train

# 3. Test email configuration (IMPORTANT - do before running)
cd ..
python test_email_config.py

# 4. Run the monitoring system
python main.py
```

## 🎮 Keyboard Controls

| Key | Action |
|-----|--------|
| `q` | Quit application |
| `a` | Mark attendance for all recognized students |
| `r` | Generate and export daily report |
| `s` | Show system statistics |
| `v` | Switch to anti-proxy verification mode |
| `SPACE` | Pause/Resume monitoring |

## 📧 Email Setup Checklist

Before running the system, complete these steps:

- [ ] Go to https://myaccount.google.com/security
- [ ] Enable 2-Step Verification
- [ ] Go to https://myaccount.google.com/apppasswords
- [ ] Generate App Password for "Mail"
- [ ] Copy the 16-character password (e.g., `abcd efgh ijkl mnop`)
- [ ] Edit `config/config.yaml`
- [ ] Replace `email_password: "YOUR_APP_PASSWORD_HERE"` with your App Password
- [ ] Remove spaces: `email_password: "abcdefghijklmnop"`
- [ ] Run `python test_email_config.py` to verify
- [ ] Check both email inboxes for test message

## 🎯 Alert Triggers

### Sleeping Detection
- **Trigger**: Eyes closed (EAR < 0.22) for 150 consecutive frames (~5 seconds)
- **Alert**: WARNING - "Student has been sleeping for X seconds"
- **Email**: Sent to teacher and parent

### Talking Detection
- **Trigger**: Mouth moving (MAR > 0.6) for 150 consecutive frames (~5 seconds)
- **Alert**: INFO - "Student has been talking for X seconds"
- **Email**: Sent to teacher and parent

### Proxy Attendance
- **Trigger**: Face detected but no blinks within timeout period
- **Alert**: CRITICAL - "Possible proxy attendance detected"
- **Email**: Sent to teacher and parent

### Mobile Phone Usage
- **Trigger**: YOLOv8 detects cell phone (COCO class 67) with confidence > 0.5
- **Alert**: CRITICAL - "Student detected using mobile phone"
- **Email**: Sent immediately to teacher and parent

## 📁 Output Files

| File | Location | Content |
|------|----------|---------|
| Attendance | `data/attendance_logs/YYYY-MM-DD.json` | Daily attendance records |
| Behaviors | `data/behavior_logs/YYYY-MM-DD.json` | Sleeping, talking, phone incidents |
| Alerts | `data/alerts/YYYY-MM-DD.json` | All triggered alerts |
| Reports | `data/reports/report_YYYY-MM-DD.json` | Daily summary reports |

## 🔧 Common Tasks

### Add a New Student
```bash
cd src
python collect_faces.py --name "New Student" --images 30
python face_recognition.py train
```

### View Today's Attendance
```bash
cat data/attendance_logs/$(date +%Y-%m-%d).json
```

### View Today's Alerts
```bash
cat data/alerts/$(date +%Y-%m-%d).json
```

### Generate Report
While system is running, press `r` key

### Change Alert Thresholds
Edit `config/config.yaml` and restart the system

## 🆘 Troubleshooting Quick Fixes

### Camera Not Working
```bash
# Test different camera index
python main.py --source 1
```

### Email Not Sending
```bash
# Verify configuration
python test_email_config.py

# Check password is not "YOUR_APP_PASSWORD_HERE"
grep email_password config/config.yaml
```

### Model Not Found
```bash
# Ensure training completed
cd src
python face_recognition.py train
```

### Low FPS
- Close other applications
- Use `--no-phone` flag: `python main.py --no-phone`
- Reduce video resolution in code

### No Faces Detected
- Improve lighting
- Move closer to camera
- Check camera is not blocked

## 📊 Performance Tips

1. **Optimize Detection Speed**
   - Phone detection runs every 5 frames (configurable)
   - Reduce `sleep_frames` and `talk_frames` for faster detection (less accurate)
   - Increase for more accurate detection (slower response)

2. **Prevent False Alerts**
   - Adjust `sleep_ear_threshold` (lower = more sensitive)
   - Adjust `talk_mar_threshold` (lower = more sensitive)
   - Use `alert_cooldown` to prevent spam

3. **Better Recognition**
   - Collect more images per student (30-50 recommended)
   - Include different angles and lighting
   - Retrain model after adding students

## 🔒 Security Notes

- App Password is stored in `config/config.yaml`
- Never commit this file to public repositories
- Add `config/config.yaml` to `.gitignore` (already done)
- Revoke App Password if compromised

## 📞 Support

| Issue | Solution |
|-------|----------|
| Email setup help | Read `EMAIL_SETUP_GUIDE.md` |
| Full documentation | Read `README.md` |
| Quick setup | Read `QUICKSTART.md` |
| Project overview | Read `PROJECT_SUMMARY.md` |

## ✅ Pre-Flight Checklist

Before deploying in classroom:

- [ ] All student faces collected
- [ ] Model trained successfully
- [ ] Email configuration tested
- [ ] Test emails received by both teacher and parent
- [ ] Camera positioned to capture all students
- [ ] Good lighting in classroom
- [ ] System tested with video file first
- [ ] Alert thresholds verified
- [ ] Backup system in place

## 🎓 System Ready!

Once all checkboxes are complete:

```bash
python main.py
```

The system will now:
- ✅ Detect faces in real-time
- ✅ Recognize students and mark attendance
- ✅ Monitor sleeping (5 seconds)
- ✅ Monitor talking (5 seconds)
- ✅ Detect proxy attendance (no blinks)
- ✅ Detect mobile phones (immediately)
- ✅ Send email alerts to teacher and parent
- ✅ Log all incidents
- ✅ Generate daily reports

---

**Teacher**: srimidhuna47@gmail.com  
**Parent**: 02midhuna@gmail.com  
**Repository**: https://github.com/chatgpt638100-cpu/CLAUDE

Happy monitoring! 🎓✨
