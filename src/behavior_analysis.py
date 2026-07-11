"""
Behavior Analysis Module
Detects talking (using MAR - Mouth Aspect Ratio) and sleeping (using EAR - Eye Aspect Ratio)
"""
import cv2
import numpy as np
import mediapipe as mp
from collections import deque
from datetime import datetime
import json
import os


class BehaviorAnalyzer:
    """Analyze student behavior: talking and sleeping detection"""
    
    # MediaPipe Face Mesh landmark indices
    LEFT_EYE_INDICES = [33, 160, 158, 133, 153, 144]
    RIGHT_EYE_INDICES = [362, 385, 387, 263, 373, 380]
    
    # Mouth landmarks for MAR calculation
    MOUTH_INDICES = [
        61,  # Left corner
        291, # Right corner
        0,   # Top center
        17,  # Bottom center
        39,  # Upper lip left
        269, # Upper lip right
        78,  # Lower lip left
        308  # Lower lip right
    ]
    
    def __init__(self, 
                 ear_threshold=0.22,        # Sleep detection threshold
                 ear_consec_frames=25,      # Frames before marking as sleeping
                 mar_threshold=0.6,         # Talking detection threshold
                 mar_consec_frames=3):      # Frames before marking as talking
        """
        Initialize Behavior Analyzer
        
        Args:
            ear_threshold: Eye Aspect Ratio threshold for sleep detection
            ear_consec_frames: Consecutive frames to confirm sleeping
            mar_threshold: Mouth Aspect Ratio threshold for talking
            mar_consec_frames: Consecutive frames to confirm talking
        """
        self.mp_face_mesh = mp.solutions.face_mesh
        self.face_mesh = self.mp_face_mesh.FaceMesh(
            max_num_faces=10,
            refine_landmarks=True,
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5
        )
        
        # Sleep detection parameters
        self.ear_threshold = ear_threshold
        self.ear_consec_frames = ear_consec_frames
        
        # Talking detection parameters
        self.mar_threshold = mar_threshold
        self.mar_consec_frames = mar_consec_frames
        
        # Tracking for multiple faces
        self.face_behaviors = {}  # Track behavior per face
        
        # History tracking
        self.behavior_log = []
    
    def calculate_ear(self, eye_landmarks):
        """
        Calculate Eye Aspect Ratio (EAR)
        EAR = (||p2-p6|| + ||p3-p5||) / (2 * ||p1-p4||)
        
        Args:
            eye_landmarks: List of 6 eye landmark points [(x,y), ...]
            
        Returns:
            Eye Aspect Ratio value
        """
        # Vertical distances
        vertical1 = np.linalg.norm(
            np.array(eye_landmarks[1]) - np.array(eye_landmarks[5])
        )
        vertical2 = np.linalg.norm(
            np.array(eye_landmarks[2]) - np.array(eye_landmarks[4])
        )
        
        # Horizontal distance
        horizontal = np.linalg.norm(
            np.array(eye_landmarks[0]) - np.array(eye_landmarks[3])
        )
        
        if horizontal == 0:
            return 0
        
        # Calculate EAR
        ear = (vertical1 + vertical2) / (2.0 * horizontal)
        
        return ear
    
    def calculate_mar(self, mouth_landmarks):
        """
        Calculate Mouth Aspect Ratio (MAR)
        MAR = (||p2-p8|| + ||p3-p7|| + ||p4-p6||) / (2 * ||p1-p5||)
        
        Args:
            mouth_landmarks: List of 8 mouth landmark points [(x,y), ...]
            
        Returns:
            Mouth Aspect Ratio value
        """
        # Vertical distances (mouth opening height)
        vertical1 = np.linalg.norm(
            np.array(mouth_landmarks[2]) - np.array(mouth_landmarks[3])
        )
        vertical2 = np.linalg.norm(
            np.array(mouth_landmarks[4]) - np.array(mouth_landmarks[7])
        )
        vertical3 = np.linalg.norm(
            np.array(mouth_landmarks[5]) - np.array(mouth_landmarks[6])
        )
        
        # Horizontal distance (mouth width)
        horizontal = np.linalg.norm(
            np.array(mouth_landmarks[0]) - np.array(mouth_landmarks[1])
        )
        
        if horizontal == 0:
            return 0
        
        # Calculate MAR
        mar = (vertical1 + vertical2 + vertical3) / (2.0 * horizontal)
        
        return mar
    
    def extract_landmarks(self, face_landmarks, indices, frame_width, frame_height):
        """Extract specific landmark coordinates"""
        points = []
        for idx in indices:
            landmark = face_landmarks.landmark[idx]
            x = int(landmark.x * frame_width)
            y = int(landmark.y * frame_height)
            points.append((x, y))
        return points
    
    def get_face_center(self, face_landmarks, frame_width, frame_height):
        """Get center point of face for tracking"""
        nose_tip = face_landmarks.landmark[1]
        x = int(nose_tip.x * frame_width)
        y = int(nose_tip.y * frame_height)
        return (x, y)
    
    def analyze_frame(self, frame, recognized_faces=None):
        """
        Analyze frame for behavior detection
        
        Args:
            frame: Input video frame
            recognized_faces: Optional list of recognized face info with names
            
        Returns:
            List of behavior analysis results per face
        """
        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = self.face_mesh.process(rgb_frame)
        
        frame_height, frame_width = frame.shape[:2]
        behavior_results = []
        
        if not results.multi_face_landmarks:
            return behavior_results
        
        for face_idx, face_landmarks in enumerate(results.multi_face_landmarks):
            # Get face center for tracking
            face_center = self.get_face_center(face_landmarks, frame_width, frame_height)
            face_id = f"face_{face_idx}"
            
            # Match with recognized face if available
            student_name = "Unknown"
            if recognized_faces:
                for rec_face in recognized_faces:
                    rec_bbox = rec_face.get('bbox')
                    if rec_bbox:
                        rx, ry, rw, rh = rec_bbox
                        # Check if face center is within recognized face bbox
                        if (rx <= face_center[0] <= rx + rw and 
                            ry <= face_center[1] <= ry + rh):
                            student_name = rec_face.get('name', 'Unknown')
                            break
            
            # Initialize tracking for new face
            if face_id not in self.face_behaviors:
                self.face_behaviors[face_id] = {
                    'ear_frame_counter': 0,
                    'mar_frame_counter': 0,
                    'is_sleeping': False,
                    'is_talking': False,
                    'sleep_start_time': None,
                    'talk_start_time': None,
                    'ear_history': deque(maxlen=30),
                    'mar_history': deque(maxlen=30),
                    'student_name': student_name
                }
            
            behavior = self.face_behaviors[face_id]
            behavior['student_name'] = student_name  # Update name
            
            # Extract eye landmarks
            left_eye = self.extract_landmarks(
                face_landmarks, self.LEFT_EYE_INDICES, frame_width, frame_height
            )
            right_eye = self.extract_landmarks(
                face_landmarks, self.RIGHT_EYE_INDICES, frame_width, frame_height
            )
            
            # Calculate EAR for both eyes
            left_ear = self.calculate_ear(left_eye)
            right_ear = self.calculate_ear(right_eye)
            avg_ear = (left_ear + right_ear) / 2.0
            
            behavior['ear_history'].append(avg_ear)
            
            # Extract mouth landmarks
            mouth = self.extract_landmarks(
                face_landmarks, self.MOUTH_INDICES, frame_width, frame_height
            )
            
            # Calculate MAR
            mar = self.calculate_mar(mouth)
            behavior['mar_history'].append(mar)
            
            # Sleep detection logic
            if avg_ear < self.ear_threshold:
                behavior['ear_frame_counter'] += 1
                
                if behavior['ear_frame_counter'] >= self.ear_consec_frames:
                    if not behavior['is_sleeping']:
                        behavior['is_sleeping'] = True
                        behavior['sleep_start_time'] = datetime.now()
                        self.log_behavior(student_name, 'sleeping', 'started')
            else:
                if behavior['is_sleeping']:
                    behavior['is_sleeping'] = False
                    self.log_behavior(student_name, 'sleeping', 'stopped')
                behavior['ear_frame_counter'] = 0
                behavior['sleep_start_time'] = None
            
            # Talking detection logic - MUCH STRICTER with DEBUG
            if len(behavior['mar_history']) >= 15:
                # Calculate standard deviation and range of recent MAR values
                recent_mars = list(behavior['mar_history'])[-15:]
                mar_std = np.std(recent_mars)
                mar_mean = np.mean(recent_mars)
                mar_max = np.max(recent_mars)
                mar_min = np.min(recent_mars)
                mar_range = mar_max - mar_min
                
                # DEBUG: Print MAR values once per second
                if not hasattr(self, '_last_debug_time'):
                    self._last_debug_time = datetime.now()
                
                if (datetime.now() - self._last_debug_time).total_seconds() >= 1.0:
                    print(f"[MAR DEBUG] {student_name}: std={mar_std:.4f} range={mar_range:.4f} mean={mar_mean:.4f}")
                    self._last_debug_time = datetime.now()
                
                # VERY STRICT THRESHOLDS - All three must be true
                is_mouth_moving = mar_std > 0.12  # Very high variability required
                has_wide_range = mar_range > 0.25  # Very wide opening required
                is_mouth_open_enough = mar_mean > 0.30  # Higher mean threshold
                
                if is_mouth_moving and has_wide_range and is_mouth_open_enough:
                    behavior['mar_frame_counter'] += 1
                    
                    if behavior['mar_frame_counter'] >= self.mar_consec_frames:
                        if not behavior['is_talking']:
                            behavior['is_talking'] = True
                            behavior['talk_start_time'] = datetime.now()
                            print(f"🗣️ TALKING DETECTED: {student_name} (std:{mar_std:.4f}, range:{mar_range:.4f})")
                            self.log_behavior(student_name, 'talking', 'started')
                else:
                    if behavior['is_talking']:
                        behavior['is_talking'] = False
                        print(f"✓ Talking stopped: {student_name}")
                        self.log_behavior(student_name, 'talking', 'stopped')
                    behavior['mar_frame_counter'] = 0
            else:
                behavior['mar_frame_counter'] = 0
                behavior['talk_start_time'] = None
                behavior['talk_start_time'] = None
            
            # Compile results
            behavior_result = {
                'face_id': face_id,
                'face_center': face_center,
                'student_name': student_name,
                'is_sleeping': behavior['is_sleeping'],
                'is_talking': behavior['is_talking'],
                'ear': avg_ear,
                'mar': mar,
                'left_eye': left_eye,
                'right_eye': right_eye,
                'mouth': mouth,
                'sleep_duration': None,
                'talk_duration': None
            }
            
            # Calculate durations
            if behavior['sleep_start_time']:
                duration = (datetime.now() - behavior['sleep_start_time']).total_seconds()
                behavior_result['sleep_duration'] = duration
            
            if behavior['talk_start_time']:
                duration = (datetime.now() - behavior['talk_start_time']).total_seconds()
                behavior_result['talk_duration'] = duration
            
            behavior_results.append(behavior_result)
        
        return behavior_results
    
    def log_behavior(self, student_name, behavior_type, action):
        """
        Log behavior event
        
        Args:
            student_name: Name of student
            behavior_type: 'sleeping' or 'talking'
            action: 'started' or 'stopped'
        """
        log_entry = {
            'timestamp': datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            'student_name': student_name,
            'behavior': behavior_type,
            'action': action
        }
        
        self.behavior_log.append(log_entry)
        
        # Save to file
        log_dir = 'data/behavior_logs'
        os.makedirs(log_dir, exist_ok=True)
        
        date_str = datetime.now().strftime("%Y-%m-%d")
        log_file = os.path.join(log_dir, f"{date_str}.json")
        
        # Load existing logs
        if os.path.exists(log_file):
            with open(log_file, 'r') as f:
                logs = json.load(f)
        else:
            logs = []
        
        logs.append(log_entry)
        
        with open(log_file, 'w') as f:
            json.dump(logs, f, indent=4)
        
        print(f"[{log_entry['timestamp']}] {student_name} {action} {behavior_type}")
    
    def draw_behavior_overlay(self, frame, behavior_results):
        """
        Draw behavior analysis overlay on frame
        
        Args:
            frame: Input frame
            behavior_results: List of behavior analysis results
            
        Returns:
            Frame with overlay
        """
        output_frame = frame.copy()
        
        for result in behavior_results:
            x, y = result['face_center']
            
            # Draw eye landmarks
            if result['left_eye']:
                for point in result['left_eye']:
                    cv2.circle(output_frame, point, 1, (0, 255, 0), -1)
            if result['right_eye']:
                for point in result['right_eye']:
                    cv2.circle(output_frame, point, 1, (0, 255, 0), -1)
            
            # Draw mouth landmarks
            if result['mouth']:
                for point in result['mouth']:
                    cv2.circle(output_frame, point, 1, (255, 0, 255), -1)
            
            # Draw behavior status
            status_y = y - 20
            
            # Student name
            if result['student_name'] != 'Unknown':
                cv2.putText(
                    output_frame, result['student_name'], (x - 50, status_y),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 2
                )
                status_y += 25
            
            # Sleeping status
            if result['is_sleeping']:
                sleep_text = f"SLEEPING"
                if result['sleep_duration']:
                    sleep_text += f" ({result['sleep_duration']:.0f}s)"
                cv2.putText(
                    output_frame, sleep_text, (x - 50, status_y),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 255), 2
                )
                status_y += 20
            
            # Talking status
            if result['is_talking']:
                talk_text = f"TALKING"
                if result['talk_duration']:
                    talk_text += f" ({result['talk_duration']:.0f}s)"
                cv2.putText(
                    output_frame, talk_text, (x - 50, status_y),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 165, 255), 2
                )
            
            # Draw EAR and MAR values (debug info)
            debug_y = y + 30
            cv2.putText(
                output_frame, f"EAR: {result['ear']:.3f}", (x - 50, debug_y),
                cv2.FONT_HERSHEY_SIMPLEX, 0.4, (255, 255, 255), 1
            )
            cv2.putText(
                output_frame, f"MAR: {result['mar']:.3f}", (x - 50, debug_y + 15),
                cv2.FONT_HERSHEY_SIMPLEX, 0.4, (255, 255, 255), 1
            )
        
        return output_frame
    
    def get_behavior_summary(self):
        """Get summary of detected behaviors"""
        sleeping_count = sum(
            1 for b in self.face_behaviors.values() if b['is_sleeping']
        )
        talking_count = sum(
            1 for b in self.face_behaviors.values() if b['is_talking']
        )
        
        return {
            'total_faces': len(self.face_behaviors),
            'sleeping': sleeping_count,
            'talking': talking_count,
            'attentive': len(self.face_behaviors) - sleeping_count - talking_count
        }
    
    def reset(self):
        """Reset behavior tracking"""
        self.face_behaviors = {}
        self.behavior_log = []
    
    def close(self):
        """Release resources"""
        self.face_mesh.close()


# Example usage
if __name__ == "__main__":
    print("=== Behavior Analysis Demo ===")
    print("\nMonitoring for:")
    print("  - Sleeping (closed eyes)")
    print("  - Talking (mouth movement)")
    print("\nPress 'q' to quit\n")
    
    analyzer = BehaviorAnalyzer(
        ear_threshold=0.22,
        ear_consec_frames=25,
        mar_threshold=0.6,
        mar_consec_frames=3
    )
    
    cap = cv2.VideoCapture(0)
    
    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break
        
        # Analyze behaviors
        behavior_results = analyzer.analyze_frame(frame)
        
        # Draw overlay
        output_frame = analyzer.draw_behavior_overlay(frame, behavior_results)
        
        # Draw summary
        summary = analyzer.get_behavior_summary()
        summary_text = (
            f"Faces: {summary['total_faces']} | "
            f"Sleeping: {summary['sleeping']} | "
            f"Talking: {summary['talking']} | "
            f"Attentive: {summary['attentive']}"
        )
        cv2.putText(
            output_frame, summary_text, (10, 30),
            cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2
        )
        
        cv2.imshow('Behavior Analysis', output_frame)
        
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
    
    cap.release()
    cv2.destroyAllWindows()
    analyzer.close()
