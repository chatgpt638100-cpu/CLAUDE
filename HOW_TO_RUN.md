# How to Run the Smart Classroom System

## Quick Start (3 Steps)

### Step 1: Install Requirements

Open your terminal/command prompt in the project folder and run:

```bash
pip install -r requirements.txt
```

This installs all the necessary packages including OpenCV, MediaPipe, YOLO, and openpyxl for Excel.

### Step 2: Set Up Student Faces

You need to collect face images for each student first:

```bash
python src/collect_faces.py
```

**What this does:**
- Opens your webcam
- Press **'s'** to capture face images
- Capture **10-15 images** of each student
- Press **'q'** to quit

**For your students:**
1. Run the script for Bhava - capture 10-15 images
2. Run again for Vishal - capture 10-15 images  
3. Run again for Priya - capture 10-15 images

Images are saved in: `data/students/[student_name]/`

### Step 3: Run the System

```bash
python main.py
```

That's it! The system is now running.

---

## What Happens When Running

### On Screen Display

You'll see:
- **Live video feed** from your webcam
- **Green boxes** around detected faces
- **Student names** and confidence scores
- **Status messages** (Present, Proxy Detected, Sleeping, Talking, Using Phone)
- **FPS counter** (frames per second)

### Console Messages

You'll see messages like:
```
Attendance has been marked for Bhava
✓ Attendance exported to Excel: data/attendance_excel/Attendance_2026-07-13.xlsx
⚠ Anti-proxy verification failed for Vishal
📧 Email alert sent to teacher about Bhava talking
```

### Keyboard Controls

While the system is running:
- Press **'q'** to quit
- Press **ESC** to exit

---

## What Gets Created

### 1. Excel Attendance Files
**Location:** `data/attendance_excel/Attendance_YYYY-MM-DD.xlsx`

**Contains:**
- Date and time of attendance
- Student name
- Status (present)
- Confidence score

### 2. Text Log Files
**Location:** `data/attendance_logs/attendance_YYYY-MM-DD.txt`

**Contains:**
- Text format attendance records

### 3. Email Alerts

Based on your requirements:

**Bhava (Talking detected):**
- Email to: srimidhuna47@gmail.com
- Subject: "Alert: Bhava Talking in Class"
- Greeting: "Dear Teacher"

**Vishal (Proxy + Phone detected):**
- Email to: srimidhuna47@gmail.com AND 02midhuna@gmail.com
- Subject: "Alert: Vishal Proxy Attendance + Using Phone"
- Greeting: "Dear Teacher" / "Dear Parents"

**Priya (Sleeping detected):**
- Email to: srimidhuna47@gmail.com
- Subject: "Alert: Priya Sleeping in Class"
- Greeting: "Dear Teacher"

---

## System Behavior Summary

### Bhava Test
✅ **Attendance marked** (even when talking)  
📧 **Email to teacher** when mouth open for 5+ seconds  
📊 **Recorded in Excel** as present

### Vishal Test
❌ **NO attendance** (proxy detected - no blinking for 8 seconds)  
📧 **Email to teacher AND parents** for proxy detection  
📧 **Email to teacher AND parents** if phone detected  
📊 **NOT recorded in Excel**

### Priya Test
✅ **Attendance marked** (even when sleeping)  
📧 **Email to teacher** when eyes closed for 5+ seconds  
📊 **Recorded in Excel** as present

---

## Troubleshooting

### "No module named 'cv2'"
```bash
pip install opencv-python opencv-contrib-python
```

### "No module named 'openpyxl'"
```bash
pip install openpyxl
```

### Webcam not opening
- Make sure no other application is using the webcam
- Close Zoom, Skype, or other video apps
- Try running as administrator

### Face not detected
- Ensure good lighting
- Face the camera directly
- Remove glasses or hats if possible
- Collect more training images (Step 2)

### Email not sending
Check your email configuration in `config/config.yaml`:
```yaml
smtp_server: "smtp.gmail.com"
smtp_port: 587
email_address: "your-email@gmail.com"
email_password: "your-app-password"  # Use Gmail App Password, not regular password
```

See **EMAIL_SETUP_GUIDE.md** for detailed email setup instructions.

---

## System Requirements

### Hardware
- **Webcam** (built-in or USB)
- **CPU:** Intel i5 or better (recommended)
- **RAM:** 4GB minimum, 8GB recommended
- **Storage:** 2GB free space

### Software
- **Python:** 3.8 or higher
- **Operating System:** Windows 10/11, macOS, or Linux

### Internet Connection
- Required for:
  - Sending email alerts
  - Installing packages
- Not required during monitoring (after setup)

---

## Testing the System

### Quick Test
```bash
python test_system.py
```

This tests:
- Face detection
- Face recognition
- Anti-proxy verification
- Behavior analysis
- Phone detection
- Excel export

### Test Email Configuration
```bash
python test_email_config.py
```

This sends a test email to verify your email settings work.

---

## Full Setup Checklist

- [ ] Python 3.8+ installed
- [ ] Requirements installed (`pip install -r requirements.txt`)
- [ ] Email configured in `config/config.yaml`
- [ ] Student face images collected (10-15 per student)
- [ ] Webcam connected and working
- [ ] Test email sent successfully

Once all checked, run: `python main.py`

---

## Directory Structure

```
CLAUDE/
├── main.py                    # ← RUN THIS FILE
├── requirements.txt           # Python packages
├── config/
│   └── config.yaml           # Email settings
├── data/
│   ├── students/             # Student face images
│   │   ├── Bhava/
│   │   ├── Vishal/
│   │   └── Priya/
│   ├── attendance_logs/      # Text attendance records
│   └── attendance_excel/     # Excel attendance files
├── models/                    # Trained models saved here
└── src/                       # Source code
    ├── collect_faces.py      # Collect student faces
    └── ...
```

---

## Need More Help?

Check these guides:
- **QUICKSTART.md** - Overview and quick start
- **TESTING_GUIDE.md** - Detailed testing instructions
- **EMAIL_SETUP_GUIDE.md** - Email configuration
- **EXCEL_ATTENDANCE_GUIDE.md** - Excel attendance details
- **TROUBLESHOOTING.md** - Common issues and fixes

---

## Summary

### To Run:
1. `pip install -r requirements.txt`
2. `python src/collect_faces.py` (collect student faces)
3. `python main.py` (start monitoring)

### To Stop:
- Press **'q'** or **ESC**

### To View Attendance:
- Open: `data/attendance_excel/Attendance_YYYY-MM-DD.xlsx`

That's it! You're ready to go! 🚀
