"""
Quick System Test - Verify everything is working
Run this to check if model, config, and all components are ready
"""
import os
import sys

print("=" * 70)
print("SMART CLASSROOM MONITORING SYSTEM - DIAGNOSTIC TEST")
print("=" * 70)

# Add src to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

# Test 1: Check model file
print("\n[1/6] Checking model file...")
model_path = os.path.join(os.path.dirname(__file__), 'models', 'trained_knn_model.pkl')
if os.path.exists(model_path):
    file_size = os.path.getsize(model_path)
    print(f"  ✓ Model found: {model_path}")
    print(f"  ✓ File size: {file_size:,} bytes")
else:
    print(f"  ✗ Model NOT found at: {model_path}")
    print(f"  → Run: cd src && python face_recognition.py train")

# Test 2: Check student data
print("\n[2/6] Checking student data...")
students_dir = os.path.join(os.path.dirname(__file__), 'data', 'students')
if os.path.exists(students_dir):
    students = [d for d in os.listdir(students_dir) if os.path.isdir(os.path.join(students_dir, d))]
    if students:
        print(f"  ✓ Found {len(students)} students:")
        for student in students:
            student_path = os.path.join(students_dir, student)
            images = [f for f in os.listdir(student_path) if f.lower().endswith(('.jpg', '.jpeg', '.png'))]
            print(f"    - {student}: {len(images)} images")
    else:
        print(f"  ✗ No student folders found in: {students_dir}")
else:
    print(f"  ✗ Students directory not found: {students_dir}")

# Test 3: Check config file
print("\n[3/6] Checking configuration...")
config_path = os.path.join(os.path.dirname(__file__), 'config', 'config.yaml')
if os.path.exists(config_path):
    print(f"  ✓ Config found: {config_path}")
    
    # Parse config
    try:
        import yaml
        with open(config_path, 'r') as f:
            config = yaml.safe_load(f)
        
        # Check email config
        alert_config = config.get('alert_config', {})
        if alert_config.get('enable_email_alerts'):
            email_password = alert_config.get('email_password', '')
            if email_password and email_password != 'YOUR_APP_PASSWORD_HERE':
                print(f"  ✓ Email alerts configured")
                print(f"    Sender: {alert_config.get('email_sender')}")
                recipients = alert_config.get('email_recipients', [])
                print(f"    Recipients: {len(recipients)}")
                for recipient in recipients:
                    print(f"      - {recipient}")
            else:
                print(f"  ⚠ Email alerts enabled but password not set")
                print(f"    Edit config.yaml line 54: email_password")
        else:
            print(f"  ⚠ Email alerts disabled in config")
    except Exception as e:
        print(f"  ✗ Error reading config: {e}")
else:
    print(f"  ✗ Config not found: {config_path}")

# Test 4: Test model loading
print("\n[4/6] Testing model loading...")
try:
    from face_recognition import FaceRecognizer
    recognizer = FaceRecognizer()
    if recognizer.knn_model is not None:
        print(f"  ✓ Model loaded successfully")
        print(f"  ✓ Student profiles: {len(recognizer.student_names)}")
        for name in recognizer.student_names:
            print(f"    - {name}")
    else:
        print(f"  ✗ Model not loaded (knn_model is None)")
except Exception as e:
    print(f"  ✗ Error loading model: {e}")

# Test 5: Test face detector
print("\n[5/6] Testing face detector...")
try:
    from face_detection import FaceDetector
    detector = FaceDetector()
    print(f"  ✓ Face detector initialized")
except Exception as e:
    print(f"  ✗ Error initializing face detector: {e}")

# Test 6: Test alert system
print("\n[6/6] Testing alert system...")
try:
    from alert_system import AlertSystem
    alert_system = AlertSystem(config.get('alert_config', {}) if 'config' in locals() else {})
    print(f"  ✓ Alert system initialized")
    print(f"    Email alerts: {'enabled' if alert_system.config.get('enable_email_alerts') else 'disabled'}")
except Exception as e:
    print(f"  ✗ Error initializing alert system: {e}")

# Summary
print("\n" + "=" * 70)
print("DIAGNOSTIC SUMMARY")
print("=" * 70)

model_ok = os.path.exists(model_path)
config_ok = os.path.exists(config_path)
students_ok = os.path.exists(students_dir) and len(os.listdir(students_dir)) > 0

if model_ok and config_ok and students_ok:
    print("\n✅ ALL CHECKS PASSED - System is ready!")
    print("\nRun the system:")
    print("  python main.py")
else:
    print("\n⚠️ SOME CHECKS FAILED - Fix issues above")
    if not model_ok:
        print("\n  → Train model: cd src && python face_recognition.py train")
    if not config_ok:
        print("\n  → Config file missing")
    if not students_ok:
        print("\n  → Add student images to data/students/")

print("\n" + "=" * 70)
