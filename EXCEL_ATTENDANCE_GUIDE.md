# Excel Attendance Guide

## Overview
Your Smart Classroom system now automatically marks attendance in an Excel spreadsheet when students are detected.

## How It Works

### Automatic Excel Recording
When a student is detected and attendance is marked:
1. **Text log** - Created in `data/attendance_logs/` (as before)
2. **Excel file** - Created in `data/attendance_excel/` (NEW!)

### Excel File Details

**File Location:** `data/attendance_excel/Attendance_YYYY-MM-DD.xlsx`

**File Format:**
- One file per day (automatically named with current date)
- Professional formatting with headers
- Columns: Date, Time, Student Name, Status, Confidence

**Example:**
```
| Date       | Time     | Student Name | Status  | Confidence |
|------------|----------|--------------|---------|------------|
| 2026-07-13 | 09:15:32 | Bhava        | present | 0.89       |
| 2026-07-13 | 09:15:35 | Priya        | present | 0.92       |
| 2026-07-13 | 09:16:10 | Bhava        | present | 0.91       |
```

### Which Students Get Marked

Based on your requirements:
- ✅ **Bhava** - Attendance marked (even when talking)
- ❌ **Vishal** - NO attendance marked (proxy detected - not blinking)
- ✅ **Priya** - Attendance marked (even when sleeping)

## Viewing the Excel File

1. Open Windows File Explorer
2. Navigate to your project folder
3. Go to: `data/attendance_excel/`
4. Open the file: `Attendance_2026-07-13.xlsx` (today's date)
5. You can open it with:
   - Microsoft Excel
   - Google Sheets (upload the file)
   - LibreOffice Calc
   - Any spreadsheet program

## Features

### Professional Formatting
- **Blue header row** with white text
- **Bold headers**
- **Auto-adjusted column widths**
- **Centered headers**

### Daily Files
- Each day creates a NEW Excel file
- File name includes the date: `Attendance_YYYY-MM-DD.xlsx`
- Easy to organize and archive

### Append Mode
- If the file for today already exists, new attendance entries are **appended**
- No data is lost or overwritten
- All attendance records are preserved

## Testing Excel Export

To test that Excel attendance is working:

```bash
# Run the test script
python test_system.py
```

Or test just the Excel module:

```bash
cd src
python excel_attendance.py
```

This will create a sample Excel file to verify everything is working.

## Troubleshooting

### "Excel export unavailable - openpyxl not installed"

Install the required package:
```bash
pip install openpyxl
```

Or reinstall all requirements:
```bash
pip install -r requirements.txt
```

### Excel file not created

1. Check that `openpyxl` is installed:
   ```bash
   pip list | grep openpyxl
   ```

2. Check the console output - it should say:
   ```
   ✓ Attendance exported to Excel: data/attendance_excel/Attendance_2026-07-13.xlsx
   ```

3. Verify the directory exists:
   - The system creates `data/attendance_excel/` automatically
   - Check if the folder was created

### Cannot open Excel file

The file is in `.xlsx` format (modern Excel format):
- Works with Excel 2007 and newer
- Works with Google Sheets
- Works with LibreOffice Calc
- If you have an older version of Excel, you may need to update

## Example Console Output

When attendance is marked, you'll see:

```
Attendance has been marked for Bhava
✓ Attendance exported to Excel: data/attendance_excel/Attendance_2026-07-13.xlsx
```

## Summary

✅ **Nothing changed** - Everything works the same as before
✅ **Added feature** - Attendance is now also saved to Excel
✅ **Automatic** - No extra steps needed
✅ **Professional** - Formatted Excel files ready to use
✅ **Daily files** - Easy to organize by date

Your system now provides attendance data in two formats:
1. **Text logs** - For system records
2. **Excel files** - For easy viewing, editing, and sharing
