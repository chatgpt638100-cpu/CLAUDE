# Visual Studio Setup Guide

Complete setup guide for cloning and running the Smart Classroom Monitoring System in Visual Studio Code or Visual Studio.

---

## 🎨 Visual Studio Code Setup (Recommended)

### Method 1: Using VS Code's Built-in Git

#### Step 1: Clone the Repository

1. **Open Visual Studio Code**

2. **Press `Ctrl+Shift+P`** (Windows/Linux) or **`Cmd+Shift+P`** (Mac) to open Command Palette

3. Type: **`Git: Clone`** and press Enter

4. Paste this URL:
   ```
   https://github.com/chatgpt638100-cpu/CLAUDE.git
   ```

5. Press **Enter**

6. Choose a folder location (e.g., `Desktop` or `Documents`)

7. Click **"Open"** when prompted to open the cloned repository

#### Step 2: Open Terminal in VS Code

1. **Press `` Ctrl+` ``** (backtick) or go to **View → Terminal**

2. You'll see a terminal at the bottom of VS Code

#### Step 3: Create Virtual Environment

In the VS Code terminal, run:

```bash
# Create virtual environment
python -m venv venv
```

#### Step 4: Activate Virtual Environment

**Windows:**
```bash
venv\Scripts\activate
```

**Linux/Mac:**
```bash
source venv/bin/activate
```

You should see `(venv)` appear in your terminal prompt.

#### Step 5: Install Dependencies

```bash
pip install -r requirements.txt
```

This will install all required packages (OpenCV, MediaPipe, YOLOv8, etc.)

#### Step 6: Select Python Interpreter

1. **Press `Ctrl+Shift+P`** to open Command Palette

2. Type: **`Python: Select Interpreter`**

3. Choose the one that shows **`./venv/bin/python`** or **`.\venv\Scripts\python.exe`**

#### Step 7: Configure Email Alerts

1. In VS Code Explorer (left sidebar), navigate to **`config/config.yaml`**

2. Click to open it

3. Find this line:
   ```yaml
   email_password: "YOUR_APP_PASSWORD_HERE"
   ```

4. Replace with your Gmail App Password:
   ```yaml
   email_password: "your16charpassword"
   ```

5. **Save the file** (`Ctrl+S`)

#### Step 8: Test Email Configuration

In the VS Code terminal:

```bash
python test_email_config.py
```

Check if emails arrive at both addresses!

#### Step 9: Collect Student Faces

In the terminal:

```bash
cd src
python collect_faces.py --name "Student Name" --images 30
```

Follow on-screen instructions:
- Press **SPACE** to capture images
- Press **Q** to quit

#### Step 10: Train the Model

```bash
python face_recognition.py train
cd ..
```

#### Step 11: Run the System

```bash
python main.py
```

---

## 🖥️ Visual Studio (Full IDE) Setup

### Step 1: Install Python Development Workload

1. Open **Visual Studio Installer**
2. Click **Modify** on your VS installation
3. Check **Python development** workload
4. Click **Modify** to install

### Step 2: Clone Repository

1. Open **Visual Studio**

2. Click **"Clone a repository"** on start screen

   OR go to **File → Clone Repository**

3. Paste this URL:
   ```
   https://github.com/chatgpt638100-cpu/CLAUDE.git
   ```

4. Choose a path (e.g., `C:\Users\YourName\Desktop`)

5. Click **Clone**

### Step 3: Open Solution

1. Visual Studio will detect the Python files

2. Open **View → Solution Explorer**

3. You'll see all project files

### Step 4: Create Virtual Environment

1. In **Solution Explorer**, right-click on **"Python Environments"**

2. Select **"Add Environment"**

3. Choose **"Virtual Environment"**

4. Click **Create**

### Step 5: Install Packages

1. In **Solution Explorer**, expand **"Python Environments"**

2. Expand your virtual environment

3. Right-click on **"Packages"**

4. Select **"Install from requirements.txt"**

5. Select the `requirements.txt` file

6. Click **Install**

### Step 6: Configure Email

1. In **Solution Explorer**, navigate to **`config/config.yaml`**

2. Double-click to open

3. Find and edit:
   ```yaml
   email_password: "YOUR_APP_PASSWORD_HERE"
   ```
   
   Change to:
   ```yaml
   email_password: "your16charpassword"
   ```

4. **Save** (`Ctrl+S`)

### Step 7: Run the System

1. In **Solution Explorer**, right-click **`main.py`**

2. Select **"Set as Startup File"**

3. Press **F5** or click **"Start"** to run

---

## 🎯 Alternative: Download as ZIP (No Git Required)

If you don't want to use Git:

### Step 1: Download

1. Go to: https://github.com/chatgpt638100-cpu/CLAUDE

2. Click green **"Code"** button

3. Click **"Download ZIP"**

4. Save to your computer

### Step 2: Extract

1. Right-click the downloaded ZIP file

2. Select **"Extract All..."**

3. Choose a location (e.g., Desktop)

4. Click **"Extract"**

### Step 3: Open in VS Code

1. Open **Visual Studio Code**

2. Go to **File → Open Folder**

3. Navigate to the extracted **CLAUDE** folder

4. Click **"Select Folder"**

### Step 4: Continue Setup

Follow steps 3-11 from the VS Code method above.

---

## 📂 Folder Structure in VS Code

After cloning, you'll see:

```
CLAUDE/
├── 📁 src/                      ← Source code
│   ├── face_detection.py
│   ├── face_recognition.py
│   ├── anti_proxy.py
│   ├── behavior_analysis.py
│   ├── phone_detection.py
│   ├── alert_system.py
│   ├── utils.py
│   └── collect_faces.py
├── 📁 config/
│   └── config.yaml              ← EDIT THIS FILE!
├── 📁 data/
│   ├── 📁 students/             ← Add face images here
│   ├── 📁 attendance_logs/
│   ├── 📁 behavior_logs/
│   └── 📁 alerts/
├── 📁 models/
├── 📄 main.py                   ← Run this file
├── 📄 requirements.txt
├── 📄 README.md
├── 📄 EMAIL_SETUP_GUIDE.md
├── 📄 QUICK_REFERENCE.md
└── 📄 test_email_config.py
```

---

## 🔧 VS Code Extensions (Recommended)

Install these extensions for better experience:

1. **Python** (by Microsoft)
   - Press `Ctrl+Shift+X`
   - Search: "Python"
   - Click **Install**

2. **Pylance** (by Microsoft)
   - Provides better code completion
   - Auto-installs with Python extension

3. **YAML** (by Red Hat)
   - For editing `config.yaml` with syntax highlighting
   - Search: "YAML"
   - Click **Install**

---

## 🎮 Running Individual Modules in VS Code

### Test Face Detection:
1. Open `src/face_detection.py`
2. Press **F5** or click **Run** button (▶️)

### Test Email Configuration:
1. Open `test_email_config.py`
2. Press **F5**

### Run Main System:
1. Open `main.py`
2. Press **F5**

---

## 🐛 Debugging in VS Code

### Step 1: Set Breakpoints

1. Open any Python file (e.g., `main.py`)
2. Click to the left of line numbers to add red dots (breakpoints)

### Step 2: Start Debugging

1. Press **F5** or click **Run and Debug** (Ctrl+Shift+D)
2. Select **"Python File"**
3. Program will pause at breakpoints
4. Use toolbar to step through code

---

## 📸 Screenshot Guide

### 1. Cloning in VS Code

![Clone Repository]
- Command Palette → Git: Clone
- Paste URL
- Choose folder

### 2. Terminal in VS Code

![Terminal]
- Press Ctrl+`
- Run commands here

### 3. File Explorer

![Explorer]
- Left sidebar
- Navigate files
- Edit config.yaml

### 4. Running Code

![Run]
- Press F5
- Or click ▶️ button
- See output below

---

## ⚙️ Configuration File Location

Edit this file for email setup:

**Path:** `config/config.yaml`

**In VS Code:**
1. Click **Explorer** (📁) in left sidebar
2. Navigate: **config** → **config.yaml**
3. Edit these lines:

```yaml
email_sender: "srimidhuna47@gmail.com"       # Already set ✓
email_password: "YOUR_APP_PASSWORD_HERE"      # CHANGE THIS!
email_recipients: 
  - "srimidhuna47@gmail.com"                 # Already set ✓
  - "02midhuna@gmail.com"                    # Already set ✓
```

**Replace:** `YOUR_APP_PASSWORD_HERE`  
**With:** Your Gmail App Password (16 characters)

---

## 🧪 Testing in VS Code

### 1. Test Email Setup

**Terminal:**
```bash
python test_email_config.py
```

**Expected Output:**
```
✓ Loading configuration...
📧 Email Configuration:
   Sender: srimidhuna47@gmail.com
   Recipients: srimidhuna47@gmail.com, 02midhuna@gmail.com
✓ TEST EMAIL SENT SUCCESSFULLY!
```

### 2. Test Face Detection

**Terminal:**
```bash
cd src
python face_detection.py
```

**Expected:** Camera window opens with face detection

### 3. Test Full System

**Terminal:**
```bash
python main.py
```

**Expected:** Monitoring interface with all features active

---

## 🆘 Common VS Code Issues

### Issue: "Python not found"

**Solution:**
1. Press `Ctrl+Shift+P`
2. Type: **"Python: Select Interpreter"**
3. Choose Python 3.8 or higher
4. If none shown, install Python from python.org

### Issue: "pip not recognized"

**Solution:**
```bash
python -m pip install -r requirements.txt
```

### Issue: "ModuleNotFoundError"

**Solution:**
1. Make sure virtual environment is activated (shows `(venv)`)
2. Re-run:
   ```bash
   pip install -r requirements.txt
   ```

### Issue: "Cannot find camera"

**Solution:**
1. Check camera permissions
2. Try different camera index:
   ```bash
   python main.py --source 1
   ```

### Issue: Terminal not opening

**Solution:**
- Press `` Ctrl+` `` (backtick key)
- Or: **View → Terminal**

### Issue: Git not found

**Solution:**
1. Download Git: https://git-scm.com/download/win
2. Install with default settings
3. Restart VS Code

---

## ✅ Quick Start Checklist for VS Code

- [ ] VS Code installed
- [ ] Repository cloned
- [ ] Virtual environment created
- [ ] Dependencies installed
- [ ] Python interpreter selected
- [ ] `config.yaml` edited with App Password
- [ ] Email test successful
- [ ] Student faces collected
- [ ] Model trained
- [ ] System runs successfully

---

## 🎬 Quick Command Reference

Open **Terminal in VS Code** (`` Ctrl+` ``) and run:

```bash
# After cloning, set up everything:
python -m venv venv
venv\Scripts\activate              # Windows
# source venv/bin/activate         # Mac/Linux
pip install -r requirements.txt

# Configure email, then test:
python test_email_config.py

# Collect student data:
cd src
python collect_faces.py --name "Student Name" --images 30
python face_recognition.py train
cd ..

# Run the system:
python main.py
```

---

## 🎓 You're Ready!

### Your Smart Classroom Monitor in VS Code will:

✅ Detect faces in real-time  
✅ Recognize students  
✅ Monitor sleeping (5 seconds)  
✅ Monitor talking (5 seconds)  
✅ Detect proxy attendance  
✅ Detect mobile phones  
✅ Send alerts to teacher & parent  
✅ Generate daily reports  

---

## 📞 Quick Help

| Need | File |
|------|------|
| Email setup | `EMAIL_SETUP_GUIDE.md` |
| Quick reference | `QUICK_REFERENCE.md` |
| Full documentation | `README.md` |
| Clone instructions | `CLONE_INSTRUCTIONS.md` |

---

**Repository:** https://github.com/chatgpt638100-cpu/CLAUDE  
**Teacher:** srimidhuna47@gmail.com  
**Parent:** 02midhuna@gmail.com  

Happy Coding in VS Code! 💻✨
