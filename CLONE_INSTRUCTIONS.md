# How to Clone and Set Up the Project

## 🔽 Cloning from Terminal

### Method 1: HTTPS Clone (Recommended for Public Repos)

```bash
# Clone the repository
git clone https://github.com/chatgpt638100-cpu/CLAUDE.git

# Navigate into the directory
cd CLAUDE

# Verify the clone
ls -la
```

### Method 2: SSH Clone (If You Have SSH Keys Set Up)

```bash
# Clone the repository
git clone git@github.com:chatgpt638100-cpu/CLAUDE.git

# Navigate into the directory
cd CLAUDE

# Verify the clone
ls -la
```

## 📦 Complete Setup After Cloning

Once you've cloned the repository, follow these steps:

### Step 1: Install Python Dependencies

```bash
# Make sure you're in the CLAUDE directory
cd CLAUDE

# Create a virtual environment (recommended)
python3 -m venv venv

# Activate the virtual environment
# On Linux/Mac:
source venv/bin/activate

# On Windows:
# venv\Scripts\activate

# Install all required packages
pip install -r requirements.txt
```

### Step 2: Verify Installation

```bash
# Test if all packages are installed correctly
python -c "import cv2; import mediapipe; import yaml; print('✓ All packages installed successfully!')"
```

### Step 3: Configure Email Alerts

```bash
# Read the email setup guide
cat EMAIL_SETUP_GUIDE.md

# OR open it in a text editor
nano config/config.yaml
# OR
vim config/config.yaml
# OR
gedit config/config.yaml
```

**Important**: Replace `YOUR_APP_PASSWORD_HERE` with your Gmail App Password

```yaml
email_password: "abcdefghijklmnop"  # Your 16-character App Password (no spaces)
```

### Step 4: Test Email Configuration

```bash
# Test if email alerts are working
python test_email_config.py
```

You should receive a test email at:
- srimidhuna47@gmail.com (Teacher)
- 02midhuna@gmail.com (Parent)

### Step 5: Collect Student Face Data

```bash
# Navigate to src directory
cd src

# Collect faces for each student
python collect_faces.py --name "Student Name" --images 30

# Example: Collect for multiple students
python collect_faces.py --name "John Doe" --images 30
python collect_faces.py --name "Jane Smith" --images 30

# List all registered students
python collect_faces.py --list
```

### Step 6: Train the Face Recognition Model

```bash
# Still in src directory
python face_recognition.py train

# You should see output like:
# Loading training data from data/students...
# Loading 30 images for John Doe
# Loading 30 images for Jane Smith
# Training KNN classifier...
# Training completed!
# Model saved to models/trained_knn_model.pkl
```

### Step 7: Run the System

```bash
# Go back to main directory
cd ..

# Start the monitoring system
python main.py
```

## 🎮 Using the System

Once running, you can use these keyboard controls:

| Key | Function |
|-----|----------|
| `q` | Quit the application |
| `a` | Mark attendance for all recognized students |
| `r` | Generate daily report |
| `s` | Show statistics |
| `v` | Switch to anti-proxy verification mode |
| `SPACE` | Pause/Resume monitoring |

## 📂 Project Structure After Clone

```
CLAUDE/
├── src/                         # Source code modules
│   ├── face_detection.py
│   ├── face_recognition.py
│   ├── anti_proxy.py
│   ├── behavior_analysis.py
│   ├── phone_detection.py
│   ├── alert_system.py
│   ├── utils.py
│   └── collect_faces.py
├── config/
│   └── config.yaml              # Configuration file (EDIT THIS!)
├── data/
│   ├── students/                # Add student face images here
│   ├── attendance_logs/         # Auto-generated attendance records
│   ├── behavior_logs/           # Auto-generated behavior logs
│   └── alerts/                  # Auto-generated alert logs
├── models/
│   └── trained_knn_model.pkl    # Auto-generated after training
├── main.py                      # Main application
├── requirements.txt             # Python dependencies
├── README.md                    # Full documentation
├── QUICKSTART.md               # Quick setup guide
├── EMAIL_SETUP_GUIDE.md        # Email configuration guide
├── QUICK_REFERENCE.md          # Quick reference card
└── test_email_config.py        # Email configuration test tool
```

## 🔧 Troubleshooting

### Issue: "git: command not found"

**Solution**: Install Git first

```bash
# On Ubuntu/Debian:
sudo apt-get update
sudo apt-get install git

# On macOS (with Homebrew):
brew install git

# On Windows:
# Download from https://git-scm.com/download/win
```

### Issue: "python: command not found"

**Solution**: Install Python 3.8+

```bash
# On Ubuntu/Debian:
sudo apt-get install python3 python3-pip python3-venv

# On macOS (with Homebrew):
brew install python3

# On Windows:
# Download from https://www.python.org/downloads/
```

### Issue: "pip install" fails

**Solution**: Update pip

```bash
python3 -m pip install --upgrade pip
pip install -r requirements.txt
```

### Issue: "Permission denied" during clone

**Solution**: Check repository access or use HTTPS

```bash
# Use HTTPS instead of SSH
git clone https://github.com/chatgpt638100-cpu/CLAUDE.git
```

### Issue: "No module named 'cv2'"

**Solution**: OpenCV not installed properly

```bash
pip install opencv-python opencv-contrib-python
```

### Issue: "Camera not opening"

**Solution**: Check camera permissions and try different camera index

```bash
# Try camera index 1 instead of 0
python main.py --source 1
```

## 🌐 Alternative: Download as ZIP

If you don't want to use Git:

1. Go to https://github.com/chatgpt638100-cpu/CLAUDE
2. Click the green "Code" button
3. Click "Download ZIP"
4. Extract the ZIP file
5. Open terminal in the extracted folder
6. Continue from **Step 1: Install Python Dependencies**

## 📱 Quick Command Summary

```bash
# Complete setup in one go (copy-paste entire block)
git clone https://github.com/chatgpt638100-cpu/CLAUDE.git
cd CLAUDE
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt

# After this, configure email and collect student faces
```

## ✅ Verification Checklist

After cloning and setup, verify everything:

- [ ] Repository cloned successfully
- [ ] Python dependencies installed
- [ ] Virtual environment activated
- [ ] Email configuration updated in `config/config.yaml`
- [ ] Test email sent and received
- [ ] Student face data collected
- [ ] Model trained successfully
- [ ] Camera accessible
- [ ] System runs without errors

## 🆘 Need Help?

- **Quick Reference**: `cat QUICK_REFERENCE.md`
- **Email Setup**: `cat EMAIL_SETUP_GUIDE.md`
- **Full Docs**: `cat README.md`
- **Quick Start**: `cat QUICKSTART.md`

## 🎓 Ready to Use!

Once all steps are complete:

```bash
python main.py
```

Your Smart Classroom Monitoring System will:
- ✅ Detect and recognize students
- ✅ Monitor sleeping (5 seconds)
- ✅ Monitor talking (5 seconds)
- ✅ Detect proxy attendance
- ✅ Detect mobile phones
- ✅ Send email alerts to teacher and parent
- ✅ Generate daily reports

---

**Repository**: https://github.com/chatgpt638100-cpu/CLAUDE  
**Teacher**: srimidhuna47@gmail.com  
**Parent**: 02midhuna@gmail.com  

Happy Monitoring! 🎓✨
