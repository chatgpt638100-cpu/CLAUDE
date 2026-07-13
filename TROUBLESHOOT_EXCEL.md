# Troubleshooting: No Excel Files Created

## 🔍 Quick Diagnosis

Run this test to find out why Excel files aren't being created:

```bash
python test_excel_only.py
```

This will tell you **exactly** what's wrong.

---

## ✅ Step-by-Step Fix

### Step 1: Install openpyxl

```bash
pip install openpyxl
```

Or:
```bash
pip3 install openpyxl
```

Or on Windows:
```bash
py -m pip install openpyxl
```

### Step 2: Verify Installation

```bash
python -c "import openpyxl; print('Installed:', openpyxl.__version__)"
```

You should see: `Installed: 3.1.x`

### Step 3: Run Test

```bash
python test_excel_only.py
```

This creates a test Excel file to verify everything works.

### Step 4: Check Output

Navigate to `data/attendance_excel/` and you should see:
- `Attendance_2026-07-13.xlsx` (with today's date)

### Step 5: Run Main System

```bash
python main.py
```

Excel files will now be created automatically when attendance is marked!

---

## 🐛 Common Issues

### Issue 1: "No module named 'openpyxl'"

**Cause:** openpyxl not installed

**Fix:**
```bash
pip install openpyxl
```

### Issue 2: "Warning: openpyxl not installed"

**Cause:** openpyxl not installed OR installed in different Python environment

**Fix:**
1. Check which Python you're using:
   ```bash
   which python
   python --version
   ```

2. Install for that specific Python:
   ```bash
   python -m pip install openpyxl
   ```

### Issue 3: Excel file created but empty

**Cause:** Attendance not being marked (face not recognized)

**Fix:**
1. Make sure faces are being detected
2. Check if model is trained:
   ```bash
   ls -lh models/trained_knn_model.pkl
   ```
3. If model doesn't exist, train it:
   ```bash
   cd src
   python face_recognition.py train
   ```

### Issue 4: Permission denied when creating file

**Cause:** No write permissions for `data/` directory

**Fix:**
```bash
chmod -R 755 data/
```

Or on Windows, run as Administrator.

### Issue 5: Multiple Python versions

**Cause:** openpyxl installed for Python 3.9 but running with Python 3.11

**Fix:**
1. Find your Python:
   ```bash
   which python3
   ```

2. Install for that version:
   ```bash
   python3 -m pip install openpyxl
   ```

3. Always use the same Python:
   ```bash
   python3 main.py
   ```

---

## 📊 How to Verify Excel is Working

### Method 1: Run Test Script

```bash
python test_excel_only.py
```

**Expected output:**
```
========================================================================
TESTING EXCEL EXPORT
========================================================================

[1/3] Checking openpyxl installation...
  ✓ openpyxl is installed (version 3.1.2)

[2/3] Checking excel_attendance.py module...
  ✓ excel_attendance.py exists

[3/3] Testing Excel export function...
  ✓ Successfully imported mark_attendance_to_excel
  Creating test Excel file...
  ✓ Excel export function executed successfully!
  ✓ Excel file created: data/attendance_excel/Attendance_2026-07-13.xlsx
  ✓ File size: 8432 bytes

  📊 SUCCESS! Excel files ARE being created!
```

### Method 2: Check Console During main.py

When running `python main.py`, look for:

**✅ Good (working):**
```
Attendance has been marked for Bhava
✓ Attendance exported to Excel: data/attendance_excel/Attendance_2026-07-13.xlsx
```

**❌ Bad (not working):**
```
Attendance has been marked for Bhava
Excel export unavailable - openpyxl not installed
```

### Method 3: Check Files Manually

```bash
# Navigate to project folder
cd data/attendance_excel/

# List files
ls -lh

# You should see:
# Attendance_2026-07-13.xlsx
```

---

## 🔧 Manual Excel Test

If the test script doesn't work, try this manual test:

```bash
cd src
python
```

Then in Python:

```python
from excel_attendance import mark_attendance_to_excel

# Create test entry
mark_attendance_to_excel("Manual Test", 0.99)

# Check result
import os
print(os.listdir('../data/attendance_excel/'))
```

You should see the Excel file listed.

---

## 📝 What Console Should Show

When the system is running and Excel is working properly:

```
Attendance has been marked for Bhava
✓ Attendance exported to Excel: data/attendance_excel/Attendance_2026-07-13.xlsx
```

**NOT:**
```
Excel export unavailable - openpyxl not installed
```

---

## 🎯 Complete Reinstall (If Nothing Works)

If you're still having issues:

```bash
# 1. Reinstall all requirements
pip uninstall -y openpyxl
pip install -r requirements.txt

# 2. Verify openpyxl
python -c "import openpyxl; print('OK')"

# 3. Test Excel
python test_excel_only.py

# 4. Run system
python main.py
```

---

## 🆘 Still Not Working?

If Excel files still aren't being created after all this:

1. **Check console output** when running `python main.py`
2. **Look for error messages** about Excel or openpyxl
3. **Run test script:** `python test_excel_only.py`
4. **Share the output** so we can diagnose further

### Provide This Information:

```bash
# 1. Python version
python --version

# 2. openpyxl status
pip list | grep openpyxl

# 3. Test result
python test_excel_only.py

# 4. Directory contents
ls -la data/attendance_excel/

# 5. Main.py output (first 30 lines)
python main.py 2>&1 | head -30
```

---

## ✅ Success Checklist

- [ ] openpyxl installed (`pip list | grep openpyxl`)
- [ ] Test script passes (`python test_excel_only.py`)
- [ ] Test Excel file created in `data/attendance_excel/`
- [ ] Can open test file in Excel/Sheets
- [ ] Console shows "✓ Attendance exported to Excel" when running main.py
- [ ] New Excel files appear in `data/attendance_excel/` with today's date

Once all checked, Excel attendance is working! 📊✨
