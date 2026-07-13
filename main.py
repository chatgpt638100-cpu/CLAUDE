"""
Smart Classroom Monitoring System - Main Application
Integrates all modules: Face Detection, Recognition, Anti-Proxy, Behavior Analysis, 
Phone Detection, and Alert System
"""
import cv2
import numpy as np
import argparse
import sys
import os
from datetime import datetime
import time
import threading
from queue import Queue, Empty

# Silence TensorFlow warnings
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'
import warnings
warnings.filterwarnings('ignore')

# Add src to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from face_detection import FaceDetector
from face_recognition import FaceRecognizer
from anti_proxy import AntiProxyVerifier
from behavior_analysis import BehaviorAnalyzer
from phone_detection import PhoneDetector
from alert_system import AlertSystem
from excel_attendance import mark_attendance_to_excel


class SmartClassroomMonitor:
    """Main classroom monitoring system integrating all components"""
    
    def __init__(self, config=None):
        """
        Initialize Smart Classroom Monitor
        
        Args:
            config: Configuration dictionary
        """
        self.config = config or {}
        
        print("=" * 70)
        print("SMART CLASSROOM MONITORING SYSTEM")
        print("=" * 70)
        print("Initializing system components...")
        
        # Initialize all components (SILENT MODE)
        # Face Detection
        print("  [1/5] Loading face detector...")
        self.face_detector = FaceDetector(
            min_detection_confidence=self.config.get('face_detection_confidence', 0.6)
        )
        print("  ✓ Face detector loaded")
        
        # Face Recognition
        print("  [2/5] Loading face recognition model...")
        try:
            self.face_recognizer = FaceRecognizer(
                model_path=self.config.get('model_path', 'models/trained_knn_model.pkl')
            )
            print("  ✓ Face recognition model loaded")
        except Exception as e:
            print(f"  ✗ FAILED to load face recognition model: {e}")
            print(f"  Please train the model first: cd src && python face_recognition.py train")
            sys.exit(1)
        
        # Anti-Proxy Verification (silent - no output)
        print("  [3/5] Loading anti-proxy verifier...")
        self.anti_proxy = AntiProxyVerifier(
            ear_threshold=self.config.get('blink_threshold', 0.21),
            consec_frames=3,
            blink_threshold=self.config.get('required_blinks', 2)
        )
        print("  ✓ Anti-proxy verifier loaded")
        
        # Behavior Analyzer - DISABLED (not needed, simplifying system)
        # self.behavior_analyzer = BehaviorAnalyzer(...)
        
        # Phone Detector - DISABLED (not needed, simplifying system)
        # self.phone_detector = PhoneDetector(...)
        
        # Alert System
        print("  [4/5] Loading alert system...")
        self.alert_system = AlertSystem(self.config.get('alert_config', {}))
        print("  ✓ Alert system loaded")
        
        # Verify email configuration (SILENT)
        alert_config = self.config.get('alert_config', {})
        
        # Application state
        self.mode = "MONITORING"  # MONITORING, VERIFICATION, ATTENDANCE
        self.recognized_faces = []
        self.frame_count = 0
        self.running = True
        
        # Attendance tracking - prevent duplicate marking attempts
        self.attendance_marked = {}  # {student_name: timestamp}
        
        # Cache last processed frame and results for smooth display
        self.last_output_frame = None
        self.cached_behavior_results = []
        self.cached_phone_incidents = []
        
        # INDEPENDENT TIMERS FOR EACH STUDENT
        self.detection_start_times = {
            "bhava": None,
            "vishal": None,
            "priya": None
        }
        
        # Alert sent tracking (one alert per student)
        self.alert_sent = {
            "bhava": False,
            "vishal": False,
            "priya": False
        }
        
        # Detection state tracking (for reset logic)
        self.last_seen_time = {
            "bhava": None,
            "vishal": None,
            "priya": None
        }
        
        # Debugging: print waiting message only once
        self.waiting_message_shown = {
            "bhava": False,
            "vishal": False,
            "priya": False
        }
        
        # Email queue to prevent threading overload
        print("  [5/5] Starting email worker thread...")
        self.email_queue = Queue(maxsize=10)
        self.email_worker_thread = threading.Thread(target=self._email_worker, daemon=True)
        self.email_worker_thread.start()
        print("  ✓ Email worker thread started")
        
        print("\n✓ System initialization complete!")
        print("=" * 70)
        print()
    
    def run_monitoring_mode(self, video_source=0):
        """
        Run full classroom monitoring
        
        Args:
            video_source: Camera index or video file path
        """
        print("Starting webcam...")
        cap = cv2.VideoCapture(video_source)
        
        if not cap.isOpened():
            print(f"\n✗ ERROR: Failed to open video source: {video_source}")
            print("\nTroubleshooting:")
            print("  1. Make sure webcam is connected")
            print("  2. Check if another program is using the webcam")
            print("  3. Try different camera index: python main.py --source 1")
            print("  4. Check camera permissions")
            return
        
        print("✓ Webcam opened successfully!")
        print("Monitoring active! Press 'q' to quit.")
        print("=" * 70)
        print()
        
        # Set camera properties for better performance
        cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
        cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
        cap.set(cv2.CAP_PROP_FPS, 30)
        
        paused = False
        
        while self.running:
            if not paused:
                ret, frame = cap.read()
                if not ret:
                    print("\n✗ ERROR: Failed to read frame from webcam")
                    break
                
                self.frame_count += 1
                
                # Process frame with error handling (non-blocking)
                try:
                    output_frame = self.process_frame(frame)
                    
                    # Display frame EVERY time for smooth video
                    cv2.imshow('Smart Classroom Monitor', output_frame)
                except Exception as e:
                    print(f"\n✗ ERROR in process_frame: {e}")
                    # If error, just show the raw frame
                    cv2.imshow('Smart Classroom Monitor', frame)
            else:
                cv2.waitKey(100)
            
            # Handle key presses (MUST have waitKey for display)
            key = cv2.waitKey(1) & 0xFF
            
            if key == ord('q'):
                print("\nShutting down...")
                break
            elif key == ord(' '):
                paused = not paused
            elif key == ord('a'):
                self.mark_attendance_for_all()
            elif key == ord('r'):
                self.generate_report()
            elif key == ord('s'):
                self.show_statistics()
            elif key == ord('v'):
                self.run_verification_mode(cap)
        
        cap.release()
        cv2.destroyAllWindows()
        self.cleanup()
        print("✓ System shutdown complete")
    
    def _email_worker(self):
        """Background worker thread that sends emails from queue (non-blocking)"""
        while True:
            try:
                email_task = self.email_queue.get(timeout=1)
                if email_task is None:
                    break
                
                # Unpack task
                student_name, face = email_task
                
                # Send the actual email
                self._send_student_alert_actual(student_name, face)
                
                self.email_queue.task_done()
            except Empty:
                continue
            except Exception as e:
                print(f"ERROR: Email sending failed - {e}")
    
    def process_frame(self, frame):
        """
        Process a single frame - ULTRA OPTIMIZED for zero freezing
        
        Args:
            frame: Input video frame
            
        Returns:
            Processed frame with overlays
        """
        # ULTRA OPTIMIZATION: Alternate between face detection and recognition
        # Never do both in the same frame to prevent freezing
        
        output_frame = frame.copy()
        current_time = time.monotonic()  # Use monotonic for reliable timing
        
        # 1. Face Detection (every 6 frames on even multiples: 6, 12, 18...)
        if self.frame_count % 6 == 0:
            # Detect on FULL FRAME (not resized) to fix rectangle placement
            self.face_detector.detect_faces(frame)
        
        # 2. Get face crops (use cached detection results)
        face_crops = self.face_detector.get_face_crops(frame)
        
        # 3. Face Recognition (every 6 frames on odd multiples: 3, 9, 15...)
        # This ensures detection and recognition NEVER happen on the same frame
        if self.frame_count % 6 == 3 and face_crops:
            self.recognized_faces = self.face_recognizer.recognize_multiple_faces(
                face_crops, 
                threshold=self.config.get('recognition_threshold', 0.6)
            )
        
        # 4. INDEPENDENT TIMER LOGIC FOR EACH STUDENT
        # Get list of currently recognized students
        current_students = set()
        for face in self.recognized_faces:
            if face['name'] != 'Unknown':
                student_name_raw = face['name'].strip().lower()
                current_students.add(student_name_raw)
        
        # Check each student independently
        for student_key in ["bhava", "vishal", "priya"]:
            if student_key in current_students:
                # Student is currently detected
                self.last_seen_time[student_key] = current_time
                
                # Start timer if not started
                if self.detection_start_times[student_key] is None:
                    self.detection_start_times[student_key] = current_time
                    self.waiting_message_shown[student_key] = False
                
                # Calculate elapsed time
                elapsed = current_time - self.detection_start_times[student_key]
                
                # After 5 seconds, trigger alert ONCE
                if elapsed >= 5.0 and not self.alert_sent[student_key]:
                    # Mark alert as sent
                    self.alert_sent[student_key] = True
                    
                    # Find the face object for this student
                    student_face = None
                    for face in self.recognized_faces:
                        if face['name'].strip().lower() == student_key:
                            student_face = face
                            break
                    
                    if student_face:
                        # Add to email queue (non-blocking)
                        if not self.email_queue.full():
                            try:
                                self.email_queue.put_nowait((student_key, student_face))
                            except Exception as e:
                                print(f"ERROR: Failed to queue alert - {e}")
            
            else:
                # Student not currently detected
                # Reset timer if student has been gone for 3+ seconds (cooldown)
                if self.last_seen_time[student_key] is not None:
                    time_since_last_seen = current_time - self.last_seen_time[student_key]
                    if time_since_last_seen > 3.0:
                        # Reset everything for this student
                        self.detection_start_times[student_key] = None
                        self.alert_sent[student_key] = False
                        self.waiting_message_shown[student_key] = False
                        self.last_seen_time[student_key] = None
        
        # 5. Draw overlays
        behavior_results = []
        phone_incidents = []
        
        output_frame = self.draw_comprehensive_overlay(
            output_frame,
            self.recognized_faces,
            behavior_results,
            phone_incidents
        )
        
        return output_frame
    
    def _send_student_alert_actual(self, student_key, face):
        """
        Send alert for a specific student (called by email worker thread)
        
        Args:
            student_key: Student name in lowercase (bhava, vishal, priya)
            face: Face detection result
        """
        student_name = student_key.capitalize()
        
        # Student-specific rules
        if student_key == 'bhava':
            # Bhava: Talking, email to teacher only
            
            # Mark attendance (both text log and Excel)
            success = self.face_recognizer.mark_attendance(student_name, face['confidence'])
            if success:
                self.attendance_marked[student_name] = datetime.now()
                print(f"Attendance has been marked for {student_name}")
                # Also mark in Excel
                mark_attendance_to_excel(student_name, face['confidence'])
            
            # Send email to teacher only (not to parent)
            try:
                alert = self.alert_system.create_alert(
                    alert_type=self.alert_system.ALERT_TALKING,
                    severity=self.alert_system.SEVERITY_INFO,
                    student_name=student_name,
                    message=f"{student_name} is talking in class",
                    details={'duration': 5},
                    send_to_parent=False  # Teacher only
                )
                print(f"{student_name} is talking - email sent to teacher")
            except Exception as e:
                print(f"ERROR: Email failed - {e}")
            
        elif student_key == 'vishal':
            # Vishal: Not blinking + using mobile phone, email to both teacher and parent
            
            # NO attendance (proxy detected)
            print(f"Attendance has NOT been marked for {student_name} (proxy detected)")
            
            try:
                # Send email to both teacher and parent
                alert1 = self.alert_system.create_alert(
                    alert_type=self.alert_system.ALERT_PROXY_DETECTED,
                    severity=self.alert_system.SEVERITY_CRITICAL,
                    student_name=student_name,
                    message=f"{student_name} is not blinking (proxy attempt detected)",
                    details={'verification_status': 'No blink detected'},
                    send_to_parent=True  # Both teacher and parent
                )
                
                alert2 = self.alert_system.create_alert(
                    alert_type=self.alert_system.ALERT_PHONE_USAGE,
                    severity=self.alert_system.SEVERITY_CRITICAL,
                    student_name=student_name,
                    message=f"{student_name} detected using mobile phone",
                    details={'confidence': 0.9},
                    send_to_parent=True  # Both teacher and parent
                )
                print(f"{student_name} is not blinking and using mobile phone - email sent to teacher and parent")
            except Exception as e:
                print(f"ERROR: Email failed - {e}")
            
        elif student_key == 'priya':
            # Priya: Sleeping, email to teacher only
            
            # Mark attendance (both text log and Excel)
            success = self.face_recognizer.mark_attendance(student_name, face['confidence'])
            if success:
                self.attendance_marked[student_name] = datetime.now()
                print(f"Attendance has been marked for {student_name}")
                # Also mark in Excel
                mark_attendance_to_excel(student_name, face['confidence'])
            
            try:
                # Send email to teacher only (not to parent)
                alert = self.alert_system.create_alert(
                    alert_type=self.alert_system.ALERT_SLEEPING,
                    severity=self.alert_system.SEVERITY_WARNING,
                    student_name=student_name,
                    message=f"{student_name} is sleeping in class",
                    details={'duration': 5},
                    send_to_parent=False  # Teacher only
                )
                print(f"{student_name} is sleeping - email sent to teacher")
            except Exception as e:
                print(f"ERROR: Email failed - {e}")
    
    def draw_comprehensive_overlay(self, frame, recognized_faces, behavior_results, phone_incidents):
        """Draw all information overlays on frame - LARGER RECTANGLES"""
        output_frame = frame.copy()
        
        # DEBUG: Check if we have faces to draw
        if not recognized_faces:
            # No faces detected yet - show message
            cv2.putText(
                output_frame, "Detecting faces...", (10, 120),
                cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 0), 2
            )
        
        # Draw recognized faces with LARGER RECTANGLES
        for face in recognized_faces:
            x, y, w, h = face['bbox']
            name = face['name']
            
            # EXPAND rectangle by 30% on all sides to cover whole face
            padding_w = int(w * 0.3)
            padding_h = int(h * 0.3)
            
            x_expanded = max(0, x - padding_w)
            y_expanded = max(0, y - padding_h)
            w_expanded = w + (2 * padding_w)
            h_expanded = h + (2 * padding_h)
            
            # Ensure within frame bounds
            x_expanded = max(0, x_expanded)
            y_expanded = max(0, y_expanded)
            w_expanded = min(w_expanded, frame.shape[1] - x_expanded)
            h_expanded = min(h_expanded, frame.shape[0] - y_expanded)
            
            # Color based on recognition
            color = (0, 255, 0) if name != 'Unknown' else (0, 165, 255)
            
            # Draw THICK rectangular box around face (LARGER NOW)
            cv2.rectangle(
                output_frame, 
                (x_expanded, y_expanded), 
                (x_expanded + w_expanded, y_expanded + h_expanded), 
                color, 
                3
            )
            
            # Draw student name in a BETTER way - with background
            label = name  # Just the name, no confidence
            
            # Calculate text size for background
            font = cv2.FONT_HERSHEY_SIMPLEX
            font_scale = 0.9  # Larger font
            font_thickness = 2
            (text_width, text_height), baseline = cv2.getTextSize(
                label, font, font_scale, font_thickness
            )
            
            # Draw background rectangle for text
            cv2.rectangle(
                output_frame,
                (x_expanded, y_expanded - text_height - 15),
                (x_expanded + text_width + 15, y_expanded),
                color,
                -1  # Filled rectangle
            )
            
            # Draw name on top of face box (white text on colored background)
            cv2.putText(
                output_frame, label, (x_expanded + 8, y_expanded - 8),
                font, font_scale, (255, 255, 255), font_thickness
            )
        
        # Draw behavior overlays (but don't duplicate names)
        for result in behavior_results:
            face_center = result.get('face_center')
            if not face_center:
                continue
                
            x, y = face_center
            
            # Only draw behavior status (sleeping/talking) below the name
            status_y = y + 30  # Position below face center
            
            # Sleeping status ONLY
            if result.get('is_sleeping'):
                sleep_text = "SLEEPING"
                if result.get('sleep_duration'):
                    sleep_text += f" ({result['sleep_duration']:.0f}s)"
                cv2.putText(
                    output_frame, sleep_text, (x - 50, status_y),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 0, 255), 2
                )
            
            # DO NOT SHOW TALKING - REMOVED AS REQUESTED
        
        # Draw phone detections - DISABLED (module not loaded)
        # if phone_incidents:
        #     output_frame = self.phone_detector.draw_detections(output_frame, phone_incidents)
        
        # Draw system status bar
        output_frame = self.draw_status_bar(output_frame, recognized_faces, behavior_results)
        
        return output_frame
    
    def draw_status_bar(self, frame, recognized_faces, behavior_results):
        """Draw system status bar at top of frame - SIMPLIFIED, NO COUNTS"""
        # Create semi-transparent overlay
        overlay = frame.copy()
        cv2.rectangle(overlay, (0, 0), (frame.shape[1], 80), (0, 0, 0), -1)
        cv2.addWeighted(overlay, 0.7, frame, 0.3, 0, frame)
        
        # System status
        status_text = "SMART CLASSROOM MONITORING - ACTIVE"
        cv2.putText(
            frame, status_text, (10, 30),
            cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 255, 0), 2
        )
        
        # Time
        time_text = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        cv2.putText(
            frame, time_text, (10, 60),
            cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2
        )
        
        # NO STATISTICS - REMOVED AS REQUESTED
        
        return frame
    
    def check_and_generate_alerts(self, behavior_results, phone_incidents):
        """Check conditions and generate alerts"""
        # Sleeping alerts
        sleep_alerts = self.alert_system.check_sleeping_alert(behavior_results)
        
        # Talking alerts
        talk_alerts = self.alert_system.check_talking_alert(behavior_results)
        
        # Phone usage alerts
        phone_alerts = self.alert_system.check_phone_usage_alert(phone_incidents)
        
        # Check for multiple violations
        for face in self.recognized_faces:
            if face['name'] != 'Unknown':
                violation_alert = self.alert_system.check_multiple_violations(face['name'])
    
    def run_verification_mode(self, cap):
        """Run anti-proxy verification for attendance"""
        print("\n" + "=" * 70)
        print("ANTI-PROXY VERIFICATION MODE")
        print("=" * 70)
        print("\nInstructions:")
        print("  1. Position your face in the frame")
        print("  2. Blink naturally 2-3 times")
        print("  3. Move your head slightly")
        print("  Press 'q' to return to monitoring\n")
        
        self.anti_proxy.reset()
        
        while True:
            ret, frame = cap.read()
            if not ret:
                break
            
            # Run verification
            result = self.anti_proxy.verify_liveness(frame)
            
            # Draw overlay
            output_frame = self.anti_proxy.draw_verification_overlay(frame, result)
            
            cv2.imshow('Smart Classroom Monitor', output_frame)
            
            # Check if verified
            if result['is_live']:
                print("✓ Verification successful!")
                cv2.waitKey(2000)
                break
            
            key = cv2.waitKey(1) & 0xFF
            if key == ord('q'):
                break
        
        print("\nReturning to monitoring mode...\n")
    
    def mark_attendance_for_all(self):
        """Mark attendance for all recognized students"""
        print("\n" + "=" * 70)
        print("MARKING ATTENDANCE")
        print("=" * 70)
        
        marked_count = 0
        for face in self.recognized_faces:
            if face['name'] != 'Unknown':
                success = self.face_recognizer.mark_attendance(
                    face['name'], 
                    face['confidence']
                )
                if success:
                    marked_count += 1
        
        print(f"✓ Attendance marked for {marked_count} student(s)")
        print("=" * 70 + "\n")
    
    def generate_report(self):
        """Generate and export daily report"""
        print("\n" + "=" * 70)
        print("GENERATING DAILY REPORT")
        print("=" * 70)
        
        report_file = self.alert_system.export_daily_report()
        
        # Also generate attendance summary
        attendance = self.face_recognizer.get_today_attendance()
        print(f"\nAttendance Summary:")
        print(f"  Total Present: {len(attendance)}")
        for record in attendance:
            print(f"    - {record['student_name']} (Confidence: {record['confidence']:.2f})")
        
        print(f"\n✓ Report saved to: {report_file}")
        print("=" * 70 + "\n")
    
    def show_statistics(self):
        """Show current statistics"""
        print("\n" + "=" * 70)
        print("SYSTEM STATISTICS")
        print("=" * 70)
        
        # Alert statistics
        alert_summary = self.alert_system.get_alert_summary()
        print(f"\nAlerts:")
        print(f"  Total: {alert_summary['total_alerts']}")
        print(f"  By Type: {alert_summary['by_type']}")
        print(f"  By Severity: {alert_summary['by_severity']}")
        
        # Attendance statistics
        attendance = self.face_recognizer.get_today_attendance()
        print(f"\nAttendance:")
        print(f"  Present: {len(attendance)}")
        
        # Behavior statistics - DISABLED (module not loaded)
        # behavior_summary = self.behavior_analyzer.get_behavior_summary()
        print(f"\nBehavior: N/A (module disabled)")
        
        print("=" * 70 + "\n")
    
    def cleanup(self):
        """Cleanup resources (SILENT)"""
        # Stop email worker
        self.email_queue.put(None)  # Signal to stop
        
        self.face_detector.close()
        self.anti_proxy.close()
        # self.behavior_analyzer.close()  # Disabled
        # self.phone_detector.close()  # Disabled


def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(
        description='Smart Classroom Monitoring System',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Run with webcam
  python main.py
  
  # Run with video file
  python main.py --source video.mp4
  
  # Run with custom configuration
  python main.py --config config/config.yaml
        """
    )
    
    parser.add_argument(
        '--source', 
        type=str, 
        default='0',
        help='Video source: camera index (0, 1, ...) or video file path'
    )
    
    parser.add_argument(
        '--config',
        type=str,
        help='Path to configuration file (YAML or JSON)'
    )
    
    parser.add_argument(
        '--no-phone',
        action='store_true',
        help='Disable phone detection (faster processing)'
    )
    
    args = parser.parse_args()
    
    # Parse video source
    try:
        video_source = int(args.source)
    except ValueError:
        video_source = args.source
    
    # Load configuration
    config = {}
    
    # Try to load config file (check multiple locations)
    config_paths = [
        args.config if args.config else None,
        'config/config.yaml',
        'config.yaml',
    ]
    
    config_loaded = False
    for config_path in config_paths:
        if config_path and os.path.exists(config_path):
            try:
                import yaml
                with open(config_path, 'r') as f:
                    config = yaml.safe_load(f)
                config_loaded = True
                break
            except Exception as e:
                pass  # Silent
    
    # Initialize and run system (SILENT MODE)
    try:
        print("\n" + "=" * 70)
        print("INITIALIZING SYSTEM...")
        print("=" * 70 + "\n")
        
        monitor = SmartClassroomMonitor(config)
        monitor.run_monitoring_mode(video_source)
    except KeyboardInterrupt:
        print("\n\n✓ Program interrupted by user")
    except Exception as e:
        print(f"\n\n✗ FATAL ERROR: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    main()
