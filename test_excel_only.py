"""
Test Excel Export ONLY
Quick test to see if openpyxl is working and Excel files are created
"""
import sys
import os

# Add src to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

print("=" * 70)
print("TESTING EXCEL EXPORT")
print("=" * 70)

# Test 1: Check if openpyxl is installed
print("\n[1/3] Checking openpyxl installation...")
try:
    import openpyxl
    print(f"  ✓ openpyxl is installed (version {openpyxl.__version__})")
    openpyxl_installed = True
except ImportError:
    print("  ✗ openpyxl is NOT installed")
    print("\n  → Install it: pip install openpyxl")
    openpyxl_installed = False

# Test 2: Check if excel_attendance.py exists
print("\n[2/3] Checking excel_attendance.py module...")
excel_module_path = os.path.join(os.path.dirname(__file__), 'src', 'excel_attendance.py')
if os.path.exists(excel_module_path):
    print(f"  ✓ excel_attendance.py exists at: {excel_module_path}")
else:
    print(f"  ✗ excel_attendance.py NOT found at: {excel_module_path}")

# Test 3: Try to import and use the function
print("\n[3/3] Testing Excel export function...")
if openpyxl_installed:
    try:
        from excel_attendance import mark_attendance_to_excel
        print("  ✓ Successfully imported mark_attendance_to_excel")
        
        # Try to create a test Excel file
        print("\n  Creating test Excel file...")
        result = mark_attendance_to_excel("Test Student", 0.95)
        
        if result:
            print("  ✓ Excel export function executed successfully!")
            
            # Check if file was created
            import datetime
            date_str = datetime.datetime.now().strftime("%Y-%m-%d")
            expected_file = f"data/attendance_excel/Attendance_{date_str}.xlsx"
            
            if os.path.exists(expected_file):
                file_size = os.path.getsize(expected_file)
                print(f"  ✓ Excel file created: {expected_file}")
                print(f"  ✓ File size: {file_size} bytes")
                print("\n  📊 SUCCESS! Excel files ARE being created!")
            else:
                print(f"  ✗ Excel file NOT found at: {expected_file}")
                print("\n  Checking if directory exists...")
                excel_dir = "data/attendance_excel"
                if os.path.exists(excel_dir):
                    files = os.listdir(excel_dir)
                    print(f"  Files in {excel_dir}: {files}")
                else:
                    print(f"  ✗ Directory does not exist: {excel_dir}")
        else:
            print("  ✗ Excel export function returned False")
    except ImportError as e:
        print(f"  ✗ Failed to import: {e}")
    except Exception as e:
        print(f"  ✗ Error during test: {e}")
        import traceback
        traceback.print_exc()
else:
    print("  ⊘ Skipped (openpyxl not installed)")

print("\n" + "=" * 70)
print("TEST COMPLETE")
print("=" * 70)

# Final summary
print("\n📋 SUMMARY:")
if openpyxl_installed:
    print("  ✅ openpyxl is installed")
    print("  ✅ Ready to create Excel files")
    print("\n  Next step: Run python main.py")
    print("  Excel files will be created in: data/attendance_excel/")
else:
    print("  ❌ openpyxl is NOT installed")
    print("\n  FIX: Run this command:")
    print("  pip install openpyxl")
    print("\n  Then run this test again:")
    print("  python test_excel_only.py")

print("=" * 70)
