# Clear Attendance Data - Step by Step

## ⚠️ **Most Common Issue: Excel File is Open**

If you have the Excel file open, it **CANNOT be deleted**!

### **Solution:**
1. **Close Excel completely** (not just the file - close Excel program)
2. Then delete the files
3. Or use the reset script

---

## ✅ **Method 1: Manual Deletion (Easiest)**

### **Step 1: Close Excel**
- Close **all Excel windows**
- Make sure Excel is not running in the background

### **Step 2: Delete Files in File Explorer**

Navigate to your project folder and delete:

1. **JSON files:**
   - Go to: `data/attendance_logs/`
   - Delete all `.json` files

2. **Excel files:**
   - Go to: `data/attendance_excel/`
   - Delete all `.xlsx` files

### **Step 3: Verify Files are Gone**

Check both folders are empty (or files are deleted)

### **Step 4: Run System**
```bash
python main.py
```

Fresh attendance will be marked!

---

## ✅ **Method 2: Use Reset Script**

```bash
python reset_attendance.py all
```

**If it says "Permission denied":**
- Close Excel
- Run the script again

---

## ✅ **Method 3: Delete via Command Line**

### **Windows (PowerShell):**
```powershell
# Close Excel first!
Remove-Item data\attendance_logs\*.json -Force
Remove-Item data\attendance_excel\*.xlsx -Force
```

### **Mac/Linux:**
```bash
# Close Excel first!
rm -f data/attendance_logs/*.json
rm -f data/attendance_excel/*.xlsx
```

---

## 🔍 **Check if Files are Really Deleted**

### **Windows:**
```powershell
# Check JSON files
dir data\attendance_logs\

# Check Excel files
dir data\attendance_excel\
```

Should show: "File Not Found" or empty directory

### **Mac/Linux:**
```bash
# Check JSON files
ls data/attendance_logs/

# Check Excel files
ls data/attendance_excel/
```

Should show: empty or just `.gitkeep`

---

## ⚠️ **Why Data Might Not Clear**

### **Problem 1: Excel File is Open**
**Symptom:** Script says "Permission denied" or file won't delete

**Solution:**
1. Close Excel completely
2. Check Task Manager (Windows) or Activity Monitor (Mac) for Excel processes
3. End any Excel processes
4. Try deleting again

### **Problem 2: File is Locked**
**Symptom:** "File is being used by another process"

**Solution:**
1. Restart your computer
2. Try deleting again before running any programs

### **Problem 3: Wrong Directory**
**Symptom:** Script says "No files found" but data still exists

**Solution:**
1. Make sure you're in the correct project directory
2. Run: `pwd` (Mac/Linux) or `cd` (Windows) to check current directory
3. Navigate to your CLAUDE project folder

### **Problem 4: Files Re-appear After Deletion**
**Symptom:** Delete files, but old data shows up again

**Solution:**
This happens if:
1. You didn't delete the JSON file (only deleted Excel)
2. The system loads JSON and recreates Excel from it

**Fix:** Delete **BOTH** JSON and Excel files:
```bash
# Delete both at once
rm data/attendance_logs/*.json data/attendance_excel/*.xlsx
```

---

## 📊 **How Attendance Files Work**

### **JSON File** (Primary Storage)
- Location: `data/attendance_logs/2026-07-13.json`
- Contains: List of attendance records
- **This is the master file** - system checks this to prevent duplicates

### **Excel File** (Export for Viewing)
- Location: `data/attendance_excel/Attendance_2026-07-13.xlsx`
- Contains: Same data as JSON, but in Excel format
- Created/updated when attendance is marked

### **Relationship:**
```
Attendance Marked
      ↓
  Save to JSON (primary)
      ↓
  Export to Excel (copy)
```

**To fully reset:** Delete **BOTH** JSON and Excel files!

---

## 🎯 **Complete Reset Procedure**

### **1. Stop the System**
If `python main.py` is running:
- Press `q` to quit
- Close the window

### **2. Close Excel**
- Close all Excel windows
- Close Excel program completely

### **3. Delete Files**

**Using Script:**
```bash
python reset_attendance.py all
```

**Or Manually:**
- Delete: `data/attendance_logs/*.json`
- Delete: `data/attendance_excel/*.xlsx`

### **4. Verify Deletion**
```bash
ls data/attendance_logs/      # Should be empty (or just .gitkeep)
ls data/attendance_excel/     # Should be empty (or just .gitkeep)
```

### **5. Run System**
```bash
python main.py
```

### **6. Test**
- Face the camera
- Wait 5 seconds for recognition
- Check console: "Attendance has been marked for [Name]"
- Check folder: Fresh Excel file created

---

## 🔄 **Testing Workflow**

To test multiple times in one day:

```bash
# 1. Run system
python main.py

# 2. Test attendance (wait 5 seconds)

# 3. Stop (press 'q')

# 4. Close Excel if you opened it

# 5. Reset
python reset_attendance.py all

# 6. Repeat from step 1
```

---

## ✅ **Quick Checklist**

Before resetting attendance:

- [ ] Stop the system (`python main.py`)
- [ ] Close Excel completely
- [ ] Close any programs viewing the files
- [ ] Delete JSON files: `data/attendance_logs/*.json`
- [ ] Delete Excel files: `data/attendance_excel/*.xlsx`
- [ ] Verify files are gone
- [ ] Run system again

---

## 🆘 **Still Having Issues?**

If data is still not clearing:

1. **Restart your computer** (nuclear option but works!)
2. Delete files before running anything else
3. Run the system

**Or check:**
```bash
# Show what files exist
python reset_attendance.py list

# Shows exact files that need to be deleted
```

---

## 📝 **Summary**

**The issue:** Excel file is usually open when you try to delete it

**The fix:**
1. **Close Excel**
2. Delete files (script or manually)
3. Run system

**Remember:** You must delete **BOTH** JSON and Excel files to fully reset!

---

## 💡 **Pro Tip**

If you're testing frequently, create a batch script:

**Windows (reset.bat):**
```bat
@echo off
echo Closing Excel...
taskkill /F /IM EXCEL.EXE 2>nul
timeout /t 1 /nobreak >nul
echo Deleting files...
del /F /Q data\attendance_logs\*.json 2>nul
del /F /Q data\attendance_excel\*.xlsx 2>nul
echo Done! Ready to run main.py
```

**Mac/Linux (reset.sh):**
```bash
#!/bin/bash
echo "Closing Excel..."
killall "Microsoft Excel" 2>/dev/null
sleep 1
echo "Deleting files..."
rm -f data/attendance_logs/*.json
rm -f data/attendance_excel/*.xlsx
echo "Done! Ready to run main.py"
```

Then just run:
- Windows: `reset.bat`
- Mac/Linux: `bash reset.sh`

---

That's it! Now you can easily clear attendance data! 🎉
