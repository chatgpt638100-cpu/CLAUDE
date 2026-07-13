"""
Reset Attendance Script
Deletes all attendance files to allow fresh attendance marking
"""
import os
import glob
from datetime import datetime

def reset_attendance():
    """Delete all attendance files (JSON and Excel)"""
    
    print("=" * 70)
    print("RESET ATTENDANCE")
    print("=" * 70)
    print()
    
    # Paths
    json_logs_dir = "data/attendance_logs"
    excel_dir = "data/attendance_excel"
    
    # Track deleted files
    deleted_count = 0
    
    # Delete JSON logs
    print("[1/2] Deleting JSON attendance logs...")
    if os.path.exists(json_logs_dir):
        json_files = glob.glob(os.path.join(json_logs_dir, "*.json"))
        for file in json_files:
            try:
                os.remove(file)
                print(f"  ✓ Deleted: {file}")
                deleted_count += 1
            except Exception as e:
                print(f"  ✗ Failed to delete {file}: {e}")
    else:
        print(f"  ⊘ Directory not found: {json_logs_dir}")
    
    # Delete Excel files
    print("\n[2/2] Deleting Excel attendance files...")
    if os.path.exists(excel_dir):
        excel_files = glob.glob(os.path.join(excel_dir, "*.xlsx"))
        for file in excel_files:
            try:
                os.remove(file)
                print(f"  ✓ Deleted: {file}")
                deleted_count += 1
            except Exception as e:
                print(f"  ✗ Failed to delete {file}: {e}")
    else:
        print(f"  ⊘ Directory not found: {excel_dir}")
    
    print()
    print("=" * 70)
    
    if deleted_count > 0:
        print(f"✓ SUCCESS! Deleted {deleted_count} file(s)")
        print()
        print("Attendance has been reset!")
        print("You can now run the system and mark attendance again:")
        print("  python main.py")
    else:
        print("⊘ No attendance files found to delete")
        print("System is already clean - ready for fresh attendance marking")
    
    print("=" * 70)


def reset_today_only():
    """Delete only today's attendance files"""
    
    print("=" * 70)
    print("RESET TODAY'S ATTENDANCE")
    print("=" * 70)
    print()
    
    date_str = datetime.now().strftime("%Y-%m-%d")
    
    # Paths
    json_file = f"data/attendance_logs/{date_str}.json"
    excel_file = f"data/attendance_excel/Attendance_{date_str}.xlsx"
    
    deleted_count = 0
    
    # Delete JSON
    if os.path.exists(json_file):
        try:
            os.remove(json_file)
            print(f"✓ Deleted JSON: {json_file}")
            deleted_count += 1
        except Exception as e:
            print(f"✗ Failed to delete JSON: {e}")
    else:
        print(f"⊘ JSON file not found: {json_file}")
    
    # Delete Excel
    if os.path.exists(excel_file):
        try:
            os.remove(excel_file)
            print(f"✓ Deleted Excel: {excel_file}")
            deleted_count += 1
        except Exception as e:
            print(f"✗ Failed to delete Excel: {e}")
    else:
        print(f"⊘ Excel file not found: {excel_file}")
    
    print()
    print("=" * 70)
    
    if deleted_count > 0:
        print(f"✓ SUCCESS! Reset today's attendance ({date_str})")
        print()
        print("You can now mark attendance again for today:")
        print("  python main.py")
    else:
        print("⊘ No attendance files found for today")
    
    print("=" * 70)


def list_attendance_files():
    """List all attendance files"""
    
    print("=" * 70)
    print("ATTENDANCE FILES")
    print("=" * 70)
    print()
    
    # JSON files
    print("[JSON Logs]")
    json_logs_dir = "data/attendance_logs"
    if os.path.exists(json_logs_dir):
        json_files = sorted(glob.glob(os.path.join(json_logs_dir, "*.json")))
        if json_files:
            for file in json_files:
                size = os.path.getsize(file)
                print(f"  - {file} ({size} bytes)")
        else:
            print("  (no files)")
    else:
        print("  (directory not found)")
    
    # Excel files
    print("\n[Excel Files]")
    excel_dir = "data/attendance_excel"
    if os.path.exists(excel_dir):
        excel_files = sorted(glob.glob(os.path.join(excel_dir, "*.xlsx")))
        if excel_files:
            for file in excel_files:
                size = os.path.getsize(file)
                print(f"  - {file} ({size} bytes)")
        else:
            print("  (no files)")
    else:
        print("  (directory not found)")
    
    print()
    print("=" * 70)


if __name__ == "__main__":
    import sys
    
    print()
    
    if len(sys.argv) > 1:
        command = sys.argv[1].lower()
        
        if command == "all":
            reset_attendance()
        elif command == "today":
            reset_today_only()
        elif command == "list":
            list_attendance_files()
        else:
            print("Invalid command!")
            print()
            print("Usage:")
            print("  python reset_attendance.py all      # Delete all attendance files")
            print("  python reset_attendance.py today    # Delete today's files only")
            print("  python reset_attendance.py list     # List all attendance files")
    else:
        # Interactive mode
        print("=" * 70)
        print("ATTENDANCE RESET TOOL")
        print("=" * 70)
        print()
        print("What would you like to do?")
        print()
        print("  1) Delete ALL attendance files")
        print("  2) Delete TODAY'S files only")
        print("  3) List all files (don't delete)")
        print("  4) Cancel")
        print()
        
        choice = input("Enter choice (1-4): ").strip()
        print()
        
        if choice == "1":
            confirm = input("Delete ALL attendance files? (yes/no): ").strip().lower()
            if confirm == "yes":
                reset_attendance()
            else:
                print("Cancelled")
        elif choice == "2":
            confirm = input("Delete TODAY'S files only? (yes/no): ").strip().lower()
            if confirm == "yes":
                reset_today_only()
            else:
                print("Cancelled")
        elif choice == "3":
            list_attendance_files()
        else:
            print("Cancelled")
