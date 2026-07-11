"""
Mobile Phone Detection Module using YOLOv8
Detects unauthorized mobile phone usage in the classroom
"""
import cv2
import numpy as np
from datetime import datetime
import json
import os

try:
    from ultralytics import YOLO
    YOLO_AVAILABLE = True
except ImportError:
    YOLO_AVAILABLE = False
    print("Warning: ultralytics not installed. YOLOv8 detection will not work.")
    print("Install with: pip install ultralytics")


class PhoneDetector:
    """Mobile phone detector using YOLOv8"""
    
    # COCO dataset class IDs
    CELL_PHONE_CLASS_ID = 67  # 'cell phone' in COCO dataset
    
    def __init__(self, model_path='yolov8n.pt', confidence_threshold=0.5):
        """
        Initialize Phone Detector
        
        Args:
            model_path: Path to YOLOv8 model weights
            confidence_threshold: Minimum confidence for detection
        """
        self.model_path = model_path
        self.confidence_threshold = confidence_threshold
        self.model = None
        self.detections = []
        self.phone_usage_log = {}
        
        if not YOLO_AVAILABLE:
            print("YOLOv8 not available. Phone detection disabled.")
            return
        
        try:
            # Load YOLOv8 model
            self.model = YOLO(model_path)
            print(f"YOLOv8 model loaded: {model_path}")
        except Exception as e:
            print(f"Error loading YOLOv8 model: {e}")
            print("Make sure the model file exists or will be downloaded automatically.")
    
    def detect_phones(self, frame):
        """
        Detect mobile phones in frame
        
        Args:
            frame: Input video frame
            
        Returns:
            List of phone detections with bounding boxes
        """
        if not YOLO_AVAILABLE or self.model is None:
            return []
        
        self.detections = []
        
        try:
            # Run YOLOv8 inference with class filtering (only cell phones)
            results = self.model(frame, verbose=False, classes=[self.CELL_PHONE_CLASS_ID])
            
            # Process results - only cell phones will be returned due to filtering
            for result in results:
                boxes = result.boxes
                
                for box in boxes:
                    # Get class ID (will always be 67 due to filtering)
                    class_id = int(box.cls[0])
                    
                    # Get confidence
                    confidence = float(box.conf[0])
                    
                    if confidence >= self.confidence_threshold:
                        # Get bounding box coordinates
                        x1, y1, x2, y2 = box.xyxy[0].cpu().numpy()
                        x, y, w, h = int(x1), int(y1), int(x2 - x1), int(y2 - y1)
                        
                        detection = {
                            'bbox': (x, y, w, h),
                            'confidence': confidence,
                            'class': 'cell_phone',
                            'center': (x + w // 2, y + h // 2)
                        }
                        
                        self.detections.append(detection)
                        print(f"📱 MOBILE PHONE DETECTED! Confidence: {confidence:.2f}")
        
        except Exception as e:
            print(f"Detection error: {e}")
        
        return self.detections
    
    def match_phone_to_student(self, phone_detections, recognized_faces):
        """
        Match detected phones with nearby students
        
        Args:
            phone_detections: List of phone detection results
            recognized_faces: List of recognized face results with bboxes
            
        Returns:
            List of phone usage incidents with student names
        """
        incidents = []
        
        for phone in phone_detections:
            phone_center = phone['center']
            px, py = phone_center
            
            # Find closest student face
            min_distance = float('inf')
            closest_student = None
            
            for face in recognized_faces:
                if 'bbox' in face:
                    fx, fy, fw, fh = face['bbox']
                    face_center = (fx + fw // 2, fy + fh // 2)
                    
                    # Calculate distance
                    distance = np.sqrt(
                        (px - face_center[0]) ** 2 + (py - face_center[1]) ** 2
                    )
                    
                    # Check if phone is near face (within reasonable distance)
                    if distance < min_distance and distance < 300:  # 300 pixels threshold
                        min_distance = distance
                        closest_student = face
            
            incident = {
                'phone_bbox': phone['bbox'],
                'phone_confidence': phone['confidence'],
                'student_name': closest_student.get('name', 'Unknown') if closest_student else 'Unknown',
                'student_bbox': closest_student.get('bbox') if closest_student else None,
                'distance': min_distance if closest_student else None,
                'timestamp': datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            }
            
            incidents.append(incident)
            
            # Log the incident
            if closest_student and closest_student.get('name') != 'Unknown':
                self.log_phone_usage(incident)
        
        return incidents
    
    def log_phone_usage(self, incident):
        """
        Log phone usage incident
        
        Args:
            incident: Phone usage incident dictionary
        """
        student_name = incident['student_name']
        
        # Track continuous usage
        if student_name not in self.phone_usage_log:
            self.phone_usage_log[student_name] = {
                'start_time': datetime.now(),
                'detection_count': 0,
                'logged': False
            }
        
        self.phone_usage_log[student_name]['detection_count'] += 1
        
        # Log to file after certain threshold (e.g., 30 consecutive detections ~1 second)
        if (self.phone_usage_log[student_name]['detection_count'] >= 30 and 
            not self.phone_usage_log[student_name]['logged']):
            
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
            
            log_entry = {
                'timestamp': incident['timestamp'],
                'student_name': student_name,
                'behavior': 'phone_usage',
                'action': 'detected',
                'confidence': incident['phone_confidence']
            }
            
            logs.append(log_entry)
            
            with open(log_file, 'w') as f:
                json.dump(logs, f, indent=4)
            
            self.phone_usage_log[student_name]['logged'] = True
            
            print(f"[ALERT] {student_name} detected using mobile phone at {incident['timestamp']}")
    
    def draw_detections(self, frame, incidents=None):
        """
        Draw phone detections on frame
        
        Args:
            frame: Input frame
            incidents: List of phone usage incidents
            
        Returns:
            Frame with drawn detections
        """
        output_frame = frame.copy()
        
        if incidents is None:
            incidents = []
            for detection in self.detections:
                incidents.append({
                    'phone_bbox': detection['bbox'],
                    'phone_confidence': detection['confidence'],
                    'student_name': 'Unknown',
                    'student_bbox': None
                })
        
        for incident in incidents:
            # Draw phone bounding box
            x, y, w, h = incident['phone_bbox']
            confidence = incident['phone_confidence']
            
            # Red color for alert
            color = (0, 0, 255)
            
            # Draw box
            cv2.rectangle(output_frame, (x, y), (x + w, y + h), color, 3)
            
            # Draw label
            label = f"PHONE: {confidence:.2f}"
            cv2.putText(
                output_frame, label, (x, y - 10),
                cv2.FONT_HERSHEY_SIMPLEX, 0.6, color, 2
            )
            
            # Draw student name if available
            if incident['student_name'] != 'Unknown':
                student_label = f"User: {incident['student_name']}"
                cv2.putText(
                    output_frame, student_label, (x, y - 35),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 0, 255), 2
                )
                
                # Draw line connecting phone to student face if bbox available
                if incident['student_bbox']:
                    sx, sy, sw, sh = incident['student_bbox']
                    student_center = (sx + sw // 2, sy + sh // 2)
                    phone_center = (x + w // 2, y + h // 2)
                    cv2.line(output_frame, phone_center, student_center, (0, 0, 255), 2)
        
        return output_frame
    
    def get_detection_count(self):
        """Get number of detected phones"""
        return len(self.detections)
    
    def reset_usage_log(self):
        """Reset phone usage log"""
        self.phone_usage_log = {}
    
    def close(self):
        """Release resources"""
        pass


class PhoneDetectorFallback:
    """
    Fallback phone detector using traditional CV methods
    Used when YOLOv8 is not available
    """
    
    def __init__(self, confidence_threshold=0.5):
        """Initialize fallback detector"""
        self.confidence_threshold = confidence_threshold
        self.detections = []
        print("Using fallback phone detection (limited accuracy)")
        print("For better results, install: pip install ultralytics")
    
    def detect_phones(self, frame):
        """
        Detect phone-like rectangular objects (very basic)
        This is a placeholder - not production ready
        """
        self.detections = []
        
        # Convert to grayscale
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        
        # Edge detection
        edges = cv2.Canny(gray, 50, 150)
        
        # Find contours
        contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        
        for contour in contours:
            # Get bounding rectangle
            x, y, w, h = cv2.boundingRect(contour)
            
            # Filter by size and aspect ratio (typical phone dimensions)
            area = w * h
            if 2000 < area < 50000:  # Reasonable phone size
                aspect_ratio = h / w if w > 0 else 0
                if 1.2 < aspect_ratio < 2.5:  # Phone-like aspect ratio
                    detection = {
                        'bbox': (x, y, w, h),
                        'confidence': 0.3,  # Low confidence for fallback
                        'class': 'possible_phone',
                        'center': (x + w // 2, y + h // 2)
                    }
                    self.detections.append(detection)
        
        return self.detections
    
    def match_phone_to_student(self, phone_detections, recognized_faces):
        """Match phones to students (same as main detector)"""
        return []
    
    def draw_detections(self, frame, incidents=None):
        """Draw detections"""
        output_frame = frame.copy()
        for detection in self.detections:
            x, y, w, h = detection['bbox']
            cv2.rectangle(output_frame, (x, y), (x + w, y + h), (0, 165, 255), 2)
            cv2.putText(
                output_frame, "Possible Phone", (x, y - 10),
                cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 165, 255), 2
            )
        return output_frame
    
    def get_detection_count(self):
        """Get detection count"""
        return len(self.detections)
    
    def reset_usage_log(self):
        """Reset log"""
        pass
    
    def close(self):
        """Release resources"""
        pass


# Example usage
if __name__ == "__main__":
    print("=== Mobile Phone Detection Demo ===")
    print("\nDetecting cell phones using YOLOv8...")
    print("Press 'q' to quit\n")
    
    # Try to use YOLOv8, fallback if not available
    if YOLO_AVAILABLE:
        detector = PhoneDetector(
            model_path='yolov8n.pt',
            confidence_threshold=0.5
        )
    else:
        detector = PhoneDetectorFallback()
    
    cap = cv2.VideoCapture(0)
    
    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break
        
        # Detect phones
        detections = detector.detect_phones(frame)
        
        # Draw detections
        output_frame = detector.draw_detections(frame)
        
        # Display info
        phone_count = detector.get_detection_count()
        cv2.putText(
            output_frame, f"Phones Detected: {phone_count}", (10, 30),
            cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 255) if phone_count > 0 else (0, 255, 0), 2
        )
        
        if phone_count > 0:
            cv2.putText(
                output_frame, "ALERT: Mobile Phone Detected!", (10, 70),
                cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 0, 255), 2
            )
        
        cv2.imshow('Phone Detection', output_frame)
        
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
    
    cap.release()
    cv2.destroyAllWindows()
    detector.close()
