# Fix: Excel Files Not Being Created

## The Problem

You're seeing JSON files but no Excel files because **openpyxl is not installed**.

## The Solution (2 Minutes)

### Step 1: Install openpyxl

Open your terminal/command prompt in VS Code and run:

```bash
pip install openpyxl
```

Or if that doesn't work, try:
```bash
pip3 install openpyxl
```

Or on Windows with Python launcher:
```bash
py -m pip install openpyxl
```

### Step 2: Verify Installation

```bash
python -c "import openpyxl; print('✓ Installed:', openpyxl.__version__)"
```

You should see: `✓ Installed: 3.1.x`

### Step 3: Test Excel Export

```bash
python src/excel_attendance.py
```

This will create a test Excel file in `data/attendance_excel/`

### Step 4: Run Your System

```bash
python main.py
```

Now Excel files will be created automatically! 📊

---

## ✅ How to Verify It's Working

### When the system runs, you should see:

**Console output:**
```
Attendance has been marked for Bhava
✓ Attendance exported to Excel: data/attendance_excel/Attendance_2026-07-13.xlsx
```

### Check for the Excel file:

1. Navigate to: `data/attendance_excel/`
2. You should see: `Attendance_2026-07-13.xlsx` (with today's date)
3. Open it with Excel, Google Sheets, or any spreadsheet program

---

## ⚠️ If You See This Warning:

```
Warning: openpyxl not installed. Excel export will not work.
Install with: pip install openpyxl
```

**This means openpyxl is NOT installed.** Follow Step 1 above.

---

## 🔍 Troubleshooting

### "pip: command not found"

Try:
```bash
python -m pip install openpyxl
```
or
```bash
python3 -m pip install openpyxl
```

### "No module named 'openpyxl'" when running

You may have multiple Python versions. Make sure to:
1. Use the same Python that runs your script
2. Check which Python: `which python` or `where python`
3. Install for that specific Python

### Multiple Python Versions

If you have multiple Python versions:

```bash
# Find your Python
python --version
python3 --version

# Install for the correct one
python3.11 -m pip install openpyxl  # Use your version
```

### Permission Denied

On Mac/Linux, use `sudo`:
```bash
sudo pip install openpyxl
```

On Windows, run Command Prompt as Administrator.

### Behind a Proxy/Firewall

```bash
pip install --proxy http://your-proxy:port openpyxl
```

---

## 📋 Full Installation Check

Run this to install ALL requirements (including openpyxl):

```bash
pip install -r requirements.txt
```

This installs:
- ✅ opencv-python (camera & face detection)
- ✅ mediapipe (facial landmarks)
- ✅ openpyxl (Excel export) ← This is what you need
- ✅ numpy, pandas (data processing)
- ✅ ultralytics (YOLO for phone detection)
- ✅ And more...

---

## 🎯 Quick Fix Summary

1. Open terminal in VS Code (Ctrl + `)
2. Run: `pip install openpyxl`
3. Test: `python src/excel_attendance.py`
4. Run system: `python main.py`
5. Check: `data/attendance_excel/Attendance_2026-07-13.xlsx`

**That's it!** Excel files will now be created automatically! 🎉

---

## Why JSON Files?

The system may create JSON files for configuration, but attendance should be in **both**:
- ✅ Excel files (`.xlsx`) - Easy to view and edit
- ✅ Text logs (`.txt`) - System backup

If you only see JSON files, it means openpyxl wasn't installed when the system ran.

---

## Test Without Running Full System

Want to test just the Excel export?

```bash
cd src
python excel_attendance.py
```

This creates a sample Excel file with test data (Bhava and Vishal).

---

## After Installing openpyxl

Everything will work automatically! No code changes needed. Just:

1. Install openpyxl (Step 1)
2. Run `python main.py`
3. Excel files will be created in `data/attendance_excel/`

The system will show:
```
✓ Attendance exported to Excel: data/attendance_excel/Attendance_2026-07-13.xlsx
```

Instead of:
```
Excel export unavailable - openpyxl not installed
```

---

## 📊 What the Excel File Looks Like

Once working, you'll get a professional Excel file:

**File:** `Attendance_2026-07-13.xlsx`

**Contents:**
| Date       | Time     | Student Name | Status  | Confidence |
|------------|----------|--------------|---------|------------|
| 2026-07-13 | 09:15:32 | Bhava        | present | 0.89       |
| 2026-07-13 | 09:15:35 | Priya        | present | 0.92       |
| 2026-07-13 | 09:16:10 | Bhava        | present | 0.91       |

**Features:**
- ✅ Blue header with white text
- ✅ Auto-adjusted column widths
- ✅ Professional formatting
- ✅ Ready to open in Excel/Sheets

---

## Need Help?

If you still don't see Excel files after installing openpyxl:

1. Check console output for error messages
2. Verify installation: `python -c "import openpyxl"`
3. Make sure you're using the correct Python version
4. Try running: `python test_system.py`

Everything is coded and ready - you just need openpyxl installed! 🚀
