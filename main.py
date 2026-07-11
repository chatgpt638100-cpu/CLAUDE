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
        
        # Initialize all components
        print("Initializing Smart Classroom Monitoring System...")
        
        # Face Detection
        print("  ✓ Loading Face Detector...")
        self.face_detector = FaceDetector(
            min_detection_confidence=self.config.get('face_detection_confidence', 0.6)
        )
        
        # Face Recognition
        print("  ✓ Loading Face Recognizer...")
        self.face_recognizer = FaceRecognizer(
            model_path=self.config.get('model_path', 'models/trained_knn_model.pkl')
        )
        
        # Anti-Proxy Verification
        print("  ✓ Loading Anti-Proxy Verifier...")
        self.anti_proxy = AntiProxyVerifier(
            ear_threshold=self.config.get('blink_threshold', 0.21),
            consec_frames=3,
            blink_threshold=self.config.get('required_blinks', 2)
        )
        
        # Behavior Analyzer
        print("  ✓ Loading Behavior Analyzer...")
        self.behavior_analyzer = BehaviorAnalyzer(
            ear_threshold=self.config.get('sleep_ear_threshold', 0.22),
            ear_consec_frames=self.config.get('sleep_frames', 25),
            mar_threshold=self.config.get('talk_mar_threshold', 0.6),
            mar_consec_frames=self.config.get('talk_frames', 3)
        )
        
        # Phone Detector
        print("  ✓ Loading Phone Detector...")
        self.phone_detector = PhoneDetector(
            model_path=self.config.get('yolo_model', 'yolov8n.pt'),
            confidence_threshold=self.config.get('phone_confidence', 0.5)
        )
        
        # Alert System
        print("  ✓ Loading Alert System...")
        self.alert_system = AlertSystem(self.config.get('alert_config', {}))
        
        # Application state
        self.mode = "MONITORING"  # MONITORING, VERIFICATION, ATTENDANCE
        self.recognized_faces = []
        self.frame_count = 0
        self.running = True
        
        print("\n✓ System Ready!\n")
    
    def run_monitoring_mode(self, video_source=0):
        """
        Run full classroom monitoring
        
        Args:
            video_source: Camera index or video file path
        """
        cap = cv2.VideoCapture(video_source)
        
        if not cap.isOpened():
            print(f"Error: Could not open video source {video_source}")
            return
        
        print("=" * 70)
        print("SMART CLASSROOM MONITORING SYSTEM - ACTIVE")
        print("=" * 70)
        print("\nControls:")
        print("  q - Quit")
        print("  a - Mark attendance for recognized students")
        print("  r - Generate daily report")
        print("  s - Show statistics")
        print("  v - Switch to verification mode")
        print("  SPACE - Pause/Resume\n")
        
        paused = False
        
        while self.running:
            if not paused:
                ret, frame = cap.read()
                if not ret:
                    break
                
                self.frame_count += 1
                
                # Process frame
                output_frame = self.process_frame(frame)
                
                # Display frame
                cv2.imshow('Smart Classroom Monitor', output_frame)
            else:
                cv2.waitKey(100)
            
            # Handle key presses
            key = cv2.waitKey(1) & 0xFF
            
            if key == ord('q'):
                print("\nShutting down system...")
                break
            elif key == ord(' '):
                paused = not paused
                print("PAUSED" if paused else "RESUMED")
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
        Process a single frame through all detection modules
        
        Args:
            frame: Input video frame
            
        Returns:
            Processed frame with overlays
        """
        output_frame = frame.copy()
        
        # 1. Face Detection
        self.face_detector.detect_faces(frame)
        face_crops = self.face_detector.get_face_crops(frame)
        
        # 2. Face Recognition
        if face_crops:
            self.recognized_faces = self.face_recognizer.recognize_multiple_faces(
                face_crops, 
                threshold=self.config.get('recognition_threshold', 0.6)
            )
        else:
            self.recognized_faces = []
        
        # 3. Behavior Analysis
        behavior_results = self.behavior_analyzer.analyze_frame(frame, self.recognized_faces)
        
        # 4. Phone Detection (every 3 frames for better detection)
        phone_incidents = []
        if self.frame_count % 3 == 0:
            self.phone_detector.detect_phones(frame)
            phone_incidents = self.phone_detector.match_phone_to_student(
                self.phone_detector.detections,
                self.recognized_faces
            )
        
        # 5. Generate Alerts
        self.check_and_generate_alerts(behavior_results, phone_incidents)
        
        # 6. Draw overlays
        output_frame = self.draw_comprehensive_overlay(
            output_frame,
            self.recognized_faces,
            behavior_results,
            phone_incidents
        )
        
        return output_frame
    
    def draw_comprehensive_overlay(self, frame, recognized_faces, behavior_results, phone_incidents):
        """Draw all information overlays on frame"""
        output_frame = frame.copy()
        
        # Draw recognized faces with IMPROVED DISPLAY
        for face in recognized_faces:
            x, y, w, h = face['bbox']
            name = face['name']
            confidence = face['confidence']
            
            # Color based on recognition
            color = (0, 255, 0) if name != 'Unknown' else (0, 165, 255)
            
            # Draw THICKER rectangular box around face
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
            
            # Sleeping status
            if result.get('is_sleeping'):
                sleep_text = "SLEEPING"
                if result.get('sleep_duration'):
                    sleep_text += f" ({result['sleep_duration']:.0f}s)"
                cv2.putText(
                    output_frame, sleep_text, (x - 50, status_y),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 0, 255), 2
                )
                status_y += 25
            
            # Talking status
            if result.get('is_talking'):
                talk_text = "TALKING"
                if result.get('talk_duration'):
                    talk_text += f" ({result['talk_duration']:.0f}s)"
                cv2.putText(
                    output_frame, talk_text, (x - 50, status_y),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 165, 255), 2
                )
        
        # Draw phone detections
        if phone_incidents:
            output_frame = self.phone_detector.draw_detections(output_frame, phone_incidents)
        
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
        
        # Behavior statistics
        behavior_summary = self.behavior_analyzer.get_behavior_summary()
        print(f"\nBehavior:")
        print(f"  Total Faces: {behavior_summary['total_faces']}")
        print(f"  Sleeping: {behavior_summary['sleeping']}")
        print(f"  Talking: {behavior_summary['talking']}")
        print(f"  Attentive: {behavior_summary['attentive']}")
        
        print("=" * 70 + "\n")
    
    def cleanup(self):
        """Cleanup resources"""
        print("\nCleaning up resources...")
        self.face_detector.close()
        self.anti_proxy.close()
        self.behavior_analyzer.close()
        self.phone_detector.close()
        print("✓ Cleanup complete\n")


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
    if args.config:
        import yaml
        with open(args.config, 'r') as f:
            config = yaml.safe_load(f)
    
    # Initialize and run system
    try:
        monitor = SmartClassroomMonitor(config)
        monitor.run_monitoring_mode(video_source)
    except KeyboardInterrupt:
        print("\n\nInterrupted by user")
    except Exception as e:
        print(f"\nError: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    main()
