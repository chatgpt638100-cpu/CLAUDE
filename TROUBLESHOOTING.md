# Troubleshooting Guide

## Common Issues and Solutions

---

## ❌ Error: `AttributeError: module 'mediapipe' has no attribute 'solutions'`

### Problem:
```
File "face_detection.py", line 21, in __init__
    self.mp_face_detection = mp.solutions.face_detection
AttributeError: module 'mediapipe' has no attribute 'solutions'
```

### Cause:
MediaPipe is not installed correctly or the wrong version is installed.

### Solution:

**Step 1: Uninstall MediaPipe**
```bash
pip uninstall mediapipe -y
```

**Step 2: Reinstall MediaPipe**
```bash
pip install mediapipe==0.10.9
```

**Step 3: Verify Installation**
```bash
python -c "import mediapipe as mp; print(mp.__version__); print(mp.solutions)"
```

You should see:
```
0.10.9
<module 'mediapipe.python.solutions' ...>
```

**Step 4: Try Again**
```bash
python collect_faces.py --name "Student Name" --images 30
```

---

## Alternative: Reinstall All Packages

If the above doesn't work, reinstall all packages:

```bash
# Deactivate virtual environment (if active)
deactivate

# Delete the virtual environment folder
# Windows:
rmdir /s venv

# Linux/Mac:
rm -rf venv

# Create new virtual environment
python -m venv venv

# Activate it
# Windows:
venv\Scripts\activate

# Linux/Mac:
source venv/bin/activate

# Upgrade pip
python -m pip install --upgrade pip

# Install all packages
pip install -r requirements.txt
```

---

## ❌ Error: `cv2.error: OpenCV(4.x.x) error`

### Solution:
```bash
pip uninstall opencv-python opencv-contrib-python -y
pip install opencv-python==4.8.1.78
pip install opencv-contrib-python==4.8.1.78
```

---

## ❌ Error: `DLL load failed` (Windows)

### Solution:
Install Microsoft Visual C++ Redistributable:
- Download: https://aka.ms/vs/17/release/vc_redist.x64.exe
- Install and restart your computer

---

## ❌ Error: Camera not opening

### Solution 1: Try different camera index
```bash
# In collect_faces.py, line 42, change:
cap = cv2.VideoCapture(0)
# to:
cap = cv2.VideoCapture(1)  # or 2, 3, etc.
```

### Solution 2: Check camera permissions
- **Windows**: Settings → Privacy → Camera → Allow apps to access camera
- **Mac**: System Preferences → Security & Privacy → Camera
- **Linux**: Make sure user is in `video` group

### Solution 3: Test camera directly
```bash
python -c "import cv2; cap = cv2.VideoCapture(0); print('Camera works!' if cap.isOpened() else 'Camera error')"
```

---

## ❌ Error: `ModuleNotFoundError: No module named 'yaml'`

### Solution:
```bash
pip install pyyaml
```

---

## ❌ Error: `ModuleNotFoundError: No module named 'ultralytics'`

### Solution:
```bash
pip install ultralytics
```

---

## ❌ Error: Email not sending

### Problem 1: "Username and Password not accepted"

**Solution:**
1. Make sure you're using **App Password**, not regular Gmail password
2. Check that password has NO spaces
3. Generate a new App Password: https://myaccount.google.com/apppasswords

### Problem 2: "SMTP Authentication Error"

**Solution:**
```bash
# Edit config/config.yaml
# Make sure format is correct:
email_password: "abcdefghijklmnop"  # 16 characters, no spaces, in quotes
```

### Problem 3: Test email script
```bash
python test_email_config.py
```

---

## ❌ Error: `sklearn` not found

### Solution:
```bash
pip install scikit-learn
```

---

## ❌ Error: YOLOv8 model download fails

### Solution:
```bash
# Manually download model
pip install ultralytics
python -c "from ultralytics import YOLO; YOLO('yolov8n.pt')"
```

---

## ❌ Error: Low FPS / Slow performance

### Solution 1: Disable phone detection
```bash
python main.py --no-phone
```

### Solution 2: Reduce detection frequency
Edit `main.py`, line 104:
```python
# Change from:
if self.frame_count % 5 == 0:
# To:
if self.frame_count % 10 == 0:  # Check every 10 frames instead of 5
```

### Solution 3: Use smaller frame size
Edit `main.py`, add after line 93:
```python
frame = cv2.resize(frame, (640, 480))  # Reduce resolution
```

---

## ❌ Error: `No module named 'sklearn.neighbors._base'`

### Solution:
```bash
pip install --upgrade scikit-learn
```

---

## ❌ Error: Virtual environment not activating

### Windows PowerShell: Execution Policy Error

**Problem:**
```
cannot be loaded because running scripts is disabled on this system
```

**Solution:**
```powershell
# Run as Administrator
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# Then activate again
venv\Scripts\activate
```

---

## ❌ Error: `ImportError: DLL load failed while importing _face_detection`

### Solution (Windows):
```bash
pip uninstall mediapipe
pip install mediapipe-silicon  # For Apple M1/M2
# OR
pip install mediapipe==0.10.9  # For Intel/AMD
```

---

## 🔧 Complete Fresh Installation

If nothing works, start fresh:

### Windows:
```powershell
# Navigate to project folder
cd C:\Coding\CLAUDE

# Remove old environment
rmdir /s venv

# Create new environment
python -m venv venv

# Activate
venv\Scripts\activate

# Upgrade pip
python -m pip install --upgrade pip

# Install packages ONE BY ONE (helps identify problems)
pip install opencv-python==4.8.1.78
pip install opencv-contrib-python==4.8.1.78
pip install mediapipe==0.10.9
pip install numpy==1.24.3
pip install scikit-learn==1.3.2
pip install ultralytics==8.0.196
pip install pyyaml==6.0.1
pip install Pillow==10.1.0
pip install scipy==1.11.4
pip install python-dateutil==2.8.2
```

### Mac/Linux:
```bash
# Navigate to project folder
cd ~/Desktop/CLAUDE

# Remove old environment
rm -rf venv

# Create new environment
python3 -m venv venv

# Activate
source venv/bin/activate

# Upgrade pip
python -m pip install --upgrade pip

# Install packages
pip install -r requirements.txt
```

---

## 📊 System Requirements Check

Run this to check your system:

```bash
python -c "
import sys
print(f'Python: {sys.version}')

try:
    import cv2
    print(f'OpenCV: {cv2.__version__}')
except:
    print('OpenCV: NOT INSTALLED')

try:
    import mediapipe as mp
    print(f'MediaPipe: {mp.__version__}')
except:
    print('MediaPipe: NOT INSTALLED')

try:
    import yaml
    print('PyYAML: Installed')
except:
    print('PyYAML: NOT INSTALLED')

try:
    from ultralytics import YOLO
    print('YOLOv8: Installed')
except:
    print('YOLOv8: NOT INSTALLED')

try:
    import sklearn
    print(f'scikit-learn: {sklearn.__version__}')
except:
    print('scikit-learn: NOT INSTALLED')
"
```

**Expected output:**
```
Python: 3.8.x or higher
OpenCV: 4.8.x
MediaPipe: 0.10.x
PyYAML: Installed
YOLOv8: Installed
scikit-learn: 1.3.x
```

---

## 🆘 Still Having Issues?

### Check Python Version
```bash
python --version
```

Should be **Python 3.8** or higher.

### Check if Virtual Environment is Active
You should see `(venv)` or `(.venv)` at the start of your terminal prompt.

If not:
```bash
# Windows
venv\Scripts\activate

# Mac/Linux
source venv/bin/activate
```

### Check Package Installation
```bash
pip list
```

Should show all packages from `requirements.txt`.

---

## 📋 Quick Diagnostic Script

Create a file `diagnose.py`:

```python
#!/usr/bin/env python3
"""Diagnostic script to check system setup"""

print("=" * 70)
print("SMART CLASSROOM MONITOR - DIAGNOSTIC CHECK")
print("=" * 70)

import sys
print(f"\n✓ Python Version: {sys.version}")

errors = []

# Check each package
packages = {
    'cv2': 'opencv-python',
    'mediapipe': 'mediapipe',
    'yaml': 'pyyaml',
    'sklearn': 'scikit-learn',
    'numpy': 'numpy',
    'scipy': 'scipy',
    'PIL': 'Pillow',
}

for module, package in packages.items():
    try:
        imported = __import__(module)
        version = getattr(imported, '__version__', 'unknown')
        print(f"✓ {package}: {version}")
    except ImportError:
        print(f"✗ {package}: NOT INSTALLED")
        errors.append(package)

# Check YOLOv8
try:
    from ultralytics import YOLO
    print(f"✓ ultralytics: Installed")
except:
    print(f"✗ ultralytics: NOT INSTALLED")
    errors.append('ultralytics')

# Check MediaPipe solutions
try:
    import mediapipe as mp
    mp.solutions.face_detection
    print(f"✓ MediaPipe solutions: Working")
except:
    print(f"✗ MediaPipe solutions: ERROR")
    errors.append('mediapipe (reinstall needed)')

# Check camera
try:
    import cv2
    cap = cv2.VideoCapture(0)
    if cap.isOpened():
        print(f"✓ Camera: Accessible")
        cap.release()
    else:
        print(f"✗ Camera: Cannot open")
        errors.append('camera')
except:
    print(f"✗ Camera: Error checking")

print("\n" + "=" * 70)
if errors:
    print("❌ ISSUES FOUND:")
    for error in errors:
        print(f"   - {error}")
    print("\nRun: pip install " + " ".join(errors))
else:
    print("✅ ALL CHECKS PASSED! System ready.")
print("=" * 70)
```

Run it:
```bash
python diagnose.py
```

---

## 📞 Contact Information

If you're still stuck after trying all solutions:

1. Check which error you're getting
2. Note your Python version
3. Note your operating system
4. Check the error message carefully

Common patterns:
- **DLL errors** → Reinstall Visual C++ Redistributable (Windows)
- **Module not found** → Package not installed correctly
- **Attribute errors** → Wrong package version
- **Camera errors** → Permissions or wrong camera index

---

**Repository:** https://github.com/chatgpt638100-cpu/CLAUDE

Good luck! 🚀
