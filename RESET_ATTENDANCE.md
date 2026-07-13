# How to Reset Attendance (Allow Re-Marking)

## 🔄 When You Need This

You want to:
- ✅ Delete attendance data
- ✅ Allow the system to mark attendance again for the same students
- ✅ Test the system multiple times in one day

---

## 📝 Current Behavior

The system prevents **duplicate attendance** on the same day by checking:
1. **JSON file:** `data/attendance_logs/2026-07-13.json`
2. **Excel file:** `data/attendance_excel/Attendance_2026-07-13.xlsx`

If a student is already in the JSON file, the system says:
```
Bhava already marked present today
```

---

## ✅ **Method 1: Delete Attendance Files (Quick Reset)**

To allow re-marking attendance, delete both files:

### **On Windows (Command Prompt or PowerShell):**
```bash
# Delete JSON logs
del data\attendance_logs\*.json

# Delete Excel files
del data\attendance_excel\*.xlsx
```

### **On Mac/Linux (Terminal):**
```bash
# Delete JSON logs
rm data/attendance_logs/*.json

# Delete Excel files
rm data/attendance_excel/*.xlsx
```

### **Or use File Explorer:**
1. Navigate to `data/attendance_logs/`
2. Delete all `.json` files
3. Navigate to `data/attendance_excel/`
4. Delete all `.xlsx` files

---

## ✅ **Method 2: Delete Today's Files Only**

To keep old records but reset today:

### **Windows:**
```bash
del data\attendance_logs\2026-07-13.json
del data\attendance_excel\Attendance_2026-07-13.xlsx
```

### **Mac/Linux:**
```bash
rm data/attendance_logs/2026-07-13.json
rm data/attendance_excel/Attendance_2026-07-13.xlsx
```

Replace `2026-07-13` with today's date.

---

## ✅ **Method 3: Use Reset Script (Easiest)**

I'll create a script for you:

```bash
python reset_attendance.py
```

This will:
- ✅ Delete all attendance files
- ✅ Clear the system cache
- ✅ Allow fresh attendance marking

---

## 🔄 **After Deleting Files**

1. **Restart the system:**
   ```bash
   python main.py
   ```

2. **Attendance can be marked again** for all students

3. **New files will be created:**
   - `data/attendance_logs/2026-07-13.json`
   - `data/attendance_excel/Attendance_2026-07-13.xlsx`

---

## 📊 **What Gets Reset**

When you delete the files:

### **JSON File** (`data/attendance_logs/2026-07-13.json`)
```json
[
    {
        "student_name": "Bhava",
        "timestamp": "2026-07-13 09:15:32",
        "confidence": 0.89,
        "status": "present"
    }
]
```
**Deleted** → System can mark Bhava again

### **Excel File** (`data/attendance_excel/Attendance_2026-07-13.xlsx`)
All attendance entries deleted → Fresh Excel file will be created

---

## ⚠️ **Important Notes**

### **Files Are Checked on Each Mark**
The system checks the JSON file **every time** before marking attendance:
- If student found in file → "Already marked present today"
- If student NOT in file → Mark attendance + add to file

### **Both JSON and Excel Are Updated Together**
When attendance is marked:
1. ✅ Added to JSON file
2. ✅ Added to Excel file
3. Both are kept in sync

### **System Restarts**
You **don't need to restart** the system after deleting files. Just:
1. Delete the files
2. The system will create new ones when attendance is marked next

---

## 🎯 **Testing Workflow**

### **For Testing Multiple Times:**

1. **Run system:**
   ```bash
   python main.py
   ```

2. **Test attendance marking** (wait 5 seconds for recognition)

3. **Stop system** (press 'q')

4. **Delete attendance files:**
   ```bash
   rm data/attendance_logs/*.json
   rm data/attendance_excel/*.xlsx
   ```

5. **Run system again** and repeat

---

## 📁 **File Locations**

### **JSON Logs:**
```
data/attendance_logs/
├── 2026-07-13.json    ← Today's attendance (JSON format)
├── 2026-07-12.json    ← Previous days
└── ...
```

### **Excel Files:**
```
data/attendance_excel/
├── Attendance_2026-07-13.xlsx    ← Today's attendance (Excel format)
├── Attendance_2026-07-12.xlsx    ← Previous days
└── ...
```

---

## 🔧 **Backup Before Deleting**

If you want to keep records before resetting:

### **Backup:**
```bash
# Create backup folder
mkdir data/backup

# Copy files
cp data/attendance_logs/*.json data/backup/
cp data/attendance_excel/*.xlsx data/backup/
```

### **Then delete:**
```bash
rm data/attendance_logs/*.json
rm data/attendance_excel/*.xlsx
```

---

## 📝 **Summary**

### **To Reset Attendance:**
1. Stop the system (press 'q')
2. Delete files:
   - `data/attendance_logs/*.json`
   - `data/attendance_excel/*.xlsx`
3. Run system again: `python main.py`
4. Attendance can be marked again for all students

### **Quick Command (Mac/Linux):**
```bash
rm data/attendance_logs/*.json data/attendance_excel/*.xlsx && python main.py
```

### **Quick Command (Windows PowerShell):**
```powershell
Remove-Item data\attendance_logs\*.json, data\attendance_excel\*.xlsx; python main.py
```

---

## 🎓 **Understanding the Logic**

The code checks in `face_recognition.py`:

```python
# Check if student already marked present today
student_already_marked = any(
    log['student_name'] == student_name for log in logs
)

if not student_already_marked:
    # Mark attendance (add to JSON and Excel)
    logs.append(attendance_data)
    mark_attendance_to_excel(student_name, confidence)
else:
    print(f"{student_name} already marked present today")
```

**To allow re-marking:** Just delete the JSON file (or both JSON + Excel)!

---

That's it! Delete the files and you can mark attendance again! 🔄✨
