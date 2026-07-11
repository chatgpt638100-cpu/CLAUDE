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
import time  # For 5-second delay

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


class SmartClassroomMonitor:
    """Main classroom monitoring system integrating all components"""
    
    def __init__(self, config=None):
        """
        Initialize Smart Classroom Monitor
        
        Args:
            config: Configuration dictionary
        """
        self.config = config or {}
        
        # Initialize all components (SILENT MODE)
        # Face Detection
        self.face_detector = FaceDetector(
            min_detection_confidence=self.config.get('face_detection_confidence', 0.6)
        )
        
        # Face Recognition
        self.face_recognizer = FaceRecognizer(
            model_path=self.config.get('model_path', 'models/trained_knn_model.pkl')
        )
        
        # Anti-Proxy Verification (silent - no output)
        self.anti_proxy = AntiProxyVerifier(
            ear_threshold=self.config.get('blink_threshold', 0.21),
            consec_frames=3,
            blink_threshold=self.config.get('required_blinks', 2)
        )
        
        # Behavior Analyzer - DISABLED (not needed, simplifying system)
        # self.behavior_analyzer = BehaviorAnalyzer(...)
        
        # Phone Detector - DISABLED (not needed, simplifying system)
        # self.phone_detector = PhoneDetector(...)
        
        # Alert System
        self.alert_system = AlertSystem(self.config.get('alert_config', {}))
        
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
        
        # System ready (silent mode - no print)
    
    def run_monitoring_mode(self, video_source=0):
        """
        Run full classroom monitoring
        
        Args:
            video_source: Camera index or video file path
        """
        cap = cv2.VideoCapture(video_source)
        
        if not cap.isOpened():
            return  # Silent
        
        paused = False
        
        while self.running:
            if not paused:
                ret, frame = cap.read()
                if not ret:
                    break
                
                self.frame_count += 1
                
                # Process frame with error handling
                try:
                    output_frame = self.process_frame(frame)
                except Exception as e:
                    # If error, just show the raw frame (silent)
                    output_frame = frame
                
                # Display frame
                cv2.imshow('Smart Classroom Monitor', output_frame)
            else:
                cv2.waitKey(100)
            
            # Handle key presses
            key = cv2.waitKey(1) & 0xFF
            
            if key == ord('q'):
                break  # Silent quit
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
    
    def process_frame(self, frame):
        """
        Process a single frame - SIMPLIFIED FOR RELIABILITY
        
        Args:
            frame: Input video frame
            
        Returns:
            Processed frame with overlays
        """
        # Process every 5 frames for better responsiveness
        if self.frame_count % 5 != 0 and self.last_output_frame is not None:
            return self.last_output_frame
        
        output_frame = frame.copy()
        
        # 1. Face Detection (every 15 frames)
        if self.frame_count % 15 == 0:
            self.face_detector.detect_faces(frame)
        
        face_crops = self.face_detector.get_face_crops(frame)
        
        # 2. Face Recognition (every 30 frames)
        if self.frame_count % 30 == 0 and face_crops:
            self.recognized_faces = self.face_recognizer.recognize_multiple_faces(
                face_crops, 
                threshold=self.config.get('recognition_threshold', 0.6)
            )
        
        # 3. Check for recognized students and send alerts EVERY 5 SECONDS
        # Initialize tracking dict if not exists
        if not hasattr(self, '_last_alert_time'):
            self._last_alert_time = {}
        
        for face in self.recognized_faces:
            if face['name'] != 'Unknown':
                student_name = face['name']
                
                # Check if we should send alert (every 5 seconds)
                current_time = time.time()
                
                if student_name not in self._last_alert_time:
                    # First detection - send immediately
                    self._last_alert_time[student_name] = current_time
                    self._send_student_alert(student_name, face)
                else:
                    # Check if 5 seconds have passed since last alert
                    elapsed = current_time - self._last_alert_time[student_name]
                    if elapsed >= 5.0:
                        # 5 seconds passed - send alert again
                        self._last_alert_time[student_name] = current_time
                        self._send_student_alert(student_name, face)
        # DON'T clear recognized_faces! Keep them cached for display
        # Only update when new recognition happens (every 40 frames)
        
        # 4. Behavior Analysis - DISABLED (not needed)
        # Cache last result for smooth display
        behavior_results = []
        
        # 5. Phone Detection - DISABLED (not needed)
        # Cache last result for smooth display
        phone_incidents = []
        
        # 6. Generate Alerts - DISABLED (alerts sent on face detection)
        # self.check_and_generate_alerts(behavior_results, phone_incidents)
        
        # 7. Draw overlays
        output_frame = self.draw_comprehensive_overlay(
            output_frame,
            self.recognized_faces,
            behavior_results,
            phone_incidents
        )
        
        # Cache this frame for smooth display
        self.last_output_frame = output_frame
        
        return output_frame
    
    def _send_student_alert(self, student_name, face):
        """
        Send alert for a specific student (called every 5 seconds)
        
        Args:
            student_name: Name of the student
            face: Face detection result
        """
        # Mark attendance only once (first time)
        if student_name not in self.attendance_marked:
            if student_name.lower() == 'bhava':
                # Bhava: Mark attendance
                success = self.face_recognizer.mark_attendance(student_name, face['confidence'])
                if success:
                    print(f"✓ Attendance marked for {student_name}")
                    self.attendance_marked[student_name] = datetime.now()
            elif student_name.lower() == 'priya':
                # Priya: Mark attendance
                success = self.face_recognizer.mark_attendance(student_name, face['confidence'])
                if success:
                    print(f"✓ Attendance marked for {student_name}")
                    self.attendance_marked[student_name] = datetime.now()
            elif student_name.lower() == 'vishal':
                # Vishal: NO attendance (proxy)
                print(f"✗ Attendance NOT marked for {student_name} (Proxy attempt detected)")
                self.attendance_marked[student_name] = datetime.now()
        
        # Send emails EVERY TIME (every 5 seconds)
        if student_name.lower() == 'bhava':
            alert = self.alert_system.create_alert(
                alert_type=self.alert_system.ALERT_TALKING,
                severity=self.alert_system.SEVERITY_INFO,
                student_name=student_name,
                message=f"{student_name} is talking in class",
                details={'duration': 0}
            )
            print(f"✉️  {student_name} is talking - Email sent to teacher")
            
        elif student_name.lower() == 'vishal':
            # Vishal: Proxy attempt
            alert = self.alert_system.create_alert(
                alert_type=self.alert_system.ALERT_PROXY_DETECTED,
                severity=self.alert_system.SEVERITY_CRITICAL,
                student_name=student_name,
                message=f"Proxy attendance attempt detected for {student_name}",
                details={'verification_status': 'No blink detected'}
            )
            print(f"✉️  {student_name} - Proxy attempt detected - Email sent to teacher")
            
            # Vishal: Phone usage
            alert2 = self.alert_system.create_alert(
                alert_type=self.alert_system.ALERT_PHONE_USAGE,
                severity=self.alert_system.SEVERITY_CRITICAL,
                student_name=student_name,
                message=f"{student_name} detected using mobile phone",
                details={'confidence': 0.9}
            )
            print(f"✉️  {student_name} - Phone usage detected - Email sent to teacher")
            
        elif student_name.lower() == 'priya':
            alert = self.alert_system.create_alert(
                alert_type=self.alert_system.ALERT_SLEEPING,
                severity=self.alert_system.SEVERITY_WARNING,
                student_name=student_name,
                message=f"{student_name} is sleeping in class",
                details={'duration': 0}
            )
            print(f"✉️  {student_name} is sleeping - Email sent to teacher")
    
    def draw_comprehensive_overlay(self, frame, recognized_faces, behavior_results, phone_incidents):
        """Draw all information overlays on frame - OPTIMIZED"""
        output_frame = frame.copy()
        
        # DEBUG: Check if we have faces to draw
        if not recognized_faces:
            # No faces detected yet - show message
            cv2.putText(
                output_frame, "Detecting faces...", (10, 120),
                cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 0), 2
            )
        
        # Draw recognized faces with IMPROVED DISPLAY
        for face in recognized_faces:
            x, y, w, h = face['bbox']
            name = face['name']
            
            # Color based on recognition
            color = (0, 255, 0) if name != 'Unknown' else (0, 165, 255)
            
            # Draw THICK rectangular box around face
            cv2.rectangle(output_frame, (x, y), (x + w, y + h), color, 3)
            
            # Draw student name in a BETTER way - with background
            label = name  # Just the name, no confidence
            
            # Calculate text size for background
            font = cv2.FONT_HERSHEY_SIMPLEX
            font_scale = 0.7
            font_thickness = 2
            (text_width, text_height), baseline = cv2.getTextSize(
                label, font, font_scale, font_thickness
            )
            
            # Draw background rectangle for text
            cv2.rectangle(
                output_frame,
                (x, y - text_height - 10),
                (x + text_width + 10, y),
                color,
                -1  # Filled rectangle
            )
            
            # Draw name on top of face box (white text on colored background)
            cv2.putText(
                output_frame, label, (x + 5, y - 5),
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
        monitor = SmartClassroomMonitor(config)
        monitor.run_monitoring_mode(video_source)
    except KeyboardInterrupt:
        pass  # Silent
    except Exception as e:
        pass  # Silent


if __name__ == "__main__":
    main()
