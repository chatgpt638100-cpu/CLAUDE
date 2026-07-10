"""
Anti-Proxy Verification Module
Uses MediaPipe Face Mesh and blink detection to verify live person
Prevents attendance fraud through photos or videos
"""
import cv2
import numpy as np
import mediapipe as mp
from collections import deque
from datetime import datetime
import time


class AntiProxyVerifier:
    """Anti-proxy verification using liveness detection"""
    
    # Eye landmarks indices for MediaPipe Face Mesh
    LEFT_EYE_INDICES = [33, 160, 158, 133, 153, 144]
    RIGHT_EYE_INDICES = [362, 385, 387, 263, 373, 380]
    
    # Additional landmarks for comprehensive liveness check
    FACE_OVAL_INDICES = [10, 338, 297, 332, 284, 251, 389, 356, 454, 323, 361, 288,
                         397, 365, 379, 378, 400, 377, 152, 148, 176, 149, 150, 136,
                         172, 58, 132, 93, 234, 127, 162, 21, 54, 103, 67, 109]
    
    def __init__(self, ear_threshold=0.21, consec_frames=3, blink_threshold=2):
        """
        Initialize Anti-Proxy Verifier
        
        Args:
            ear_threshold: Eye Aspect Ratio threshold for blink detection
            consec_frames: Consecutive frames below threshold to count as blink
            blink_threshold: Minimum blinks required for verification
        """
        self.mp_face_mesh = mp.solutions.face_mesh
        self.face_mesh = self.mp_face_mesh.FaceMesh(
            max_num_faces=1,
            refine_landmarks=True,
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5
        )
        
        self.ear_threshold = ear_threshold
        self.consec_frames = consec_frames
        self.blink_threshold = blink_threshold
        
        # Tracking variables
        self.blink_counter = 0
        self.frame_counter = 0
        self.total_blinks = 0
        self.verification_start_time = None
        self.verification_timeout = 10  # seconds
        
        # History for motion detection
        self.ear_history = deque(maxlen=30)
        self.head_pose_history = deque(maxlen=30)
        
        self.is_live = False
        self.verification_status = "Not Started"
    
    def calculate_eye_aspect_ratio(self, eye_landmarks):
        """
        Calculate Eye Aspect Ratio (EAR)
        EAR = (||p2-p6|| + ||p3-p5||) / (2 * ||p1-p4||)
        
        Args:
            eye_landmarks: List of 6 eye landmark points
            
        Returns:
            Eye aspect ratio value
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
        
        # Calculate EAR
        ear = (vertical1 + vertical2) / (2.0 * horizontal)
        
        return ear
    
    def extract_eye_landmarks(self, face_landmarks, eye_indices, frame_width, frame_height):
        """Extract eye landmark coordinates"""
        eye_points = []
        for idx in eye_indices:
            landmark = face_landmarks.landmark[idx]
            x = int(landmark.x * frame_width)
            y = int(landmark.y * frame_height)
            eye_points.append((x, y))
        return eye_points
    
    def detect_head_movement(self, face_landmarks, frame_width, frame_height):
        """
        Detect head movement to verify liveness
        
        Returns:
            Head pose variation score
        """
        # Use nose tip and other key points for head pose estimation
        nose_tip = face_landmarks.landmark[1]
        left_eye = face_landmarks.landmark[33]
        right_eye = face_landmarks.landmark[263]
        
        # Calculate relative positions
        nose_x = nose_tip.x * frame_width
        nose_y = nose_tip.y * frame_height
        
        left_eye_x = left_eye.x * frame_width
        right_eye_x = right_eye.x * frame_width
        
        # Calculate head tilt and position
        eye_center_x = (left_eye_x + right_eye_x) / 2
        head_tilt = nose_x - eye_center_x
        
        # Store in history
        self.head_pose_history.append((nose_x, nose_y, head_tilt))
        
        # Calculate movement variation
        if len(self.head_pose_history) >= 10:
            positions = np.array(list(self.head_pose_history))
            variation = np.std(positions, axis=0).sum()
            return variation
        
        return 0
    
    def check_depth_cues(self, face_landmarks, frame_width, frame_height):
        """
        Check for 3D depth cues that indicate real face vs photo
        
        Returns:
            Depth score (higher = more likely real)
        """
        # Get face oval landmarks
        oval_points = []
        for idx in self.FACE_OVAL_INDICES[:10]:  # Use subset for efficiency
            landmark = face_landmarks.landmark[idx]
            oval_points.append([landmark.x, landmark.y, landmark.z])
        
        oval_points = np.array(oval_points)
        
        # Calculate depth variation (z-coordinate variation)
        depth_variation = np.std(oval_points[:, 2])
        
        # Real faces have more depth variation than flat photos
        return depth_variation
    
    def verify_liveness(self, frame):
        """
        Main liveness verification function
        
        Args:
            frame: Input video frame
            
        Returns:
            Dictionary with verification results
        """
        # Initialize verification if first time
        if self.verification_start_time is None:
            self.verification_start_time = time.time()
            self.total_blinks = 0
            self.verification_status = "Verifying..."
        
        # Check timeout
        elapsed_time = time.time() - self.verification_start_time
        if elapsed_time > self.verification_timeout:
            if self.total_blinks < self.blink_threshold:
                self.verification_status = "Failed - Insufficient blinks"
                self.is_live = False
            return self.get_verification_result()
        
        # Convert to RGB
        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        
        # Process frame
        results = self.face_mesh.process(rgb_frame)
        
        if not results.multi_face_landmarks:
            self.verification_status = "No face detected"
            return self.get_verification_result()
        
        face_landmarks = results.multi_face_landmarks[0]
        frame_height, frame_width = frame.shape[:2]
        
        # Extract eye landmarks
        left_eye = self.extract_eye_landmarks(
            face_landmarks, self.LEFT_EYE_INDICES, frame_width, frame_height
        )
        right_eye = self.extract_eye_landmarks(
            face_landmarks, self.RIGHT_EYE_INDICES, frame_width, frame_height
        )
        
        # Calculate EAR for both eyes
        left_ear = self.calculate_eye_aspect_ratio(left_eye)
        right_ear = self.calculate_eye_aspect_ratio(right_eye)
        avg_ear = (left_ear + right_ear) / 2.0
        
        self.ear_history.append(avg_ear)
        
        # Detect blink
        if avg_ear < self.ear_threshold:
            self.frame_counter += 1
        else:
            if self.frame_counter >= self.consec_frames:
                self.total_blinks += 1
                print(f"Blink detected! Total blinks: {self.total_blinks}")
            self.frame_counter = 0
        
        # Check head movement
        head_movement = self.detect_head_movement(face_landmarks, frame_width, frame_height)
        
        # Check depth cues
        depth_score = self.check_depth_cues(face_landmarks, frame_width, frame_height)
        
        # Verification logic
        if self.total_blinks >= self.blink_threshold:
            # Additional checks for robustness
            if head_movement > 5:  # Some head movement detected
                self.verification_status = "Verified - Live Person"
                self.is_live = True
            elif depth_score > 0.01:  # 3D face detected
                self.verification_status = "Verified - Live Person"
                self.is_live = True
            else:
                self.verification_status = "Verifying - Move your head slightly"
        else:
            blinks_needed = self.blink_threshold - self.total_blinks
            self.verification_status = f"Blink {blinks_needed} more time(s)"
        
        return self.get_verification_result(
            frame, face_landmarks, left_eye, right_eye, avg_ear, 
            head_movement, depth_score
        )
    
    def get_verification_result(self, frame=None, face_landmarks=None, 
                               left_eye=None, right_eye=None, avg_ear=None,
                               head_movement=0, depth_score=0):
        """Get current verification result"""
        elapsed_time = 0
        if self.verification_start_time:
            elapsed_time = time.time() - self.verification_start_time
        
        result = {
            'is_live': self.is_live,
            'status': self.verification_status,
            'blinks': self.total_blinks,
            'required_blinks': self.blink_threshold,
            'elapsed_time': elapsed_time,
            'timeout': self.verification_timeout,
            'avg_ear': avg_ear if avg_ear else 0,
            'head_movement': head_movement,
            'depth_score': depth_score,
            'face_landmarks': face_landmarks,
            'left_eye': left_eye,
            'right_eye': right_eye
        }
        
        return result
    
    def draw_verification_overlay(self, frame, result):
        """
        Draw verification information on frame
        
        Args:
            frame: Input frame
            result: Verification result dictionary
            
        Returns:
            Frame with overlay
        """
        output_frame = frame.copy()
        
        # Draw status
        status_color = (0, 255, 0) if result['is_live'] else (0, 165, 255)
        cv2.putText(
            output_frame, f"Status: {result['status']}", (10, 30),
            cv2.FONT_HERSHEY_SIMPLEX, 0.7, status_color, 2
        )
        
        # Draw blink counter
        cv2.putText(
            output_frame, 
            f"Blinks: {result['blinks']}/{result['required_blinks']}", 
            (10, 60),
            cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2
        )
        
        # Draw timer
        time_remaining = result['timeout'] - result['elapsed_time']
        cv2.putText(
            output_frame, f"Time: {time_remaining:.1f}s", (10, 90),
            cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2
        )
        
        # Draw EAR value
        if result['avg_ear'] > 0:
            ear_text = f"EAR: {result['avg_ear']:.3f}"
            cv2.putText(
                output_frame, ear_text, (10, 120),
                cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1
            )
        
        # Draw eye landmarks if available
        if result['left_eye'] and result['right_eye']:
            for point in result['left_eye']:
                cv2.circle(output_frame, point, 2, (0, 255, 0), -1)
            for point in result['right_eye']:
                cv2.circle(output_frame, point, 2, (0, 255, 0), -1)
        
        # Draw verification icon
        if result['is_live']:
            # Draw checkmark
            cv2.putText(
                output_frame, "✓ VERIFIED", (frame.shape[1] - 200, 40),
                cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 255, 0), 2
            )
        
        return output_frame
    
    def reset(self):
        """Reset verification state"""
        self.blink_counter = 0
        self.frame_counter = 0
        self.total_blinks = 0
        self.verification_start_time = None
        self.is_live = False
        self.verification_status = "Not Started"
        self.ear_history.clear()
        self.head_pose_history.clear()
    
    def close(self):
        """Release resources"""
        self.face_mesh.close()


# Example usage
if __name__ == "__main__":
    print("=== Anti-Proxy Verification Demo ===")
    print("\nInstructions:")
    print("1. Look at the camera")
    print("2. Blink naturally 2-3 times")
    print("3. Move your head slightly")
    print("4. Press 'r' to restart verification")
    print("5. Press 'q' to quit\n")
    
    verifier = AntiProxyVerifier(
        ear_threshold=0.21,
        consec_frames=3,
        blink_threshold=2
    )
    
    cap = cv2.VideoCapture(0)
    
    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break
        
        # Verify liveness
        result = verifier.verify_liveness(frame)
        
        # Draw overlay
        output_frame = verifier.draw_verification_overlay(frame, result)
        
        # Show frame
        cv2.imshow('Anti-Proxy Verification', output_frame)
        
        # Handle keys
        key = cv2.waitKey(1) & 0xFF
        if key == ord('q'):
            break
        elif key == ord('r'):
            print("\nRestarting verification...")
            verifier.reset()
        
        # Auto-reset after successful verification
        if result['is_live'] and result['elapsed_time'] > 3:
            print("\n✓ Verification successful! Resetting in 2 seconds...")
            cv2.waitKey(2000)
            verifier.reset()
    
    cap.release()
    cv2.destroyAllWindows()
    verifier.close()
