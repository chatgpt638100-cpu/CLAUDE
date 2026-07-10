"""
Face Detection Module using OpenCV and MediaPipe
Detects faces in video frames for further processing
"""
import cv2
import mediapipe as mp
import numpy as np


class FaceDetector:
    """Face detection using MediaPipe Face Detection and OpenCV"""
    
    def __init__(self, min_detection_confidence=0.7, model_selection=0):
        """
        Initialize Face Detector
        
        Args:
            min_detection_confidence: Minimum confidence for detection (0.0-1.0)
            model_selection: 0 for short-range (within 2m), 1 for full-range
        """
        self.mp_face_detection = mp.solutions.face_detection
        self.mp_drawing = mp.solutions.drawing_utils
        
        self.face_detection = self.mp_face_detection.FaceDetection(
            min_detection_confidence=min_detection_confidence,
            model_selection=model_selection
        )
        
        self.detected_faces = []
    
    def detect_faces(self, frame):
        """
        Detect faces in the given frame
        
        Args:
            frame: Input image/frame (BGR format)
            
        Returns:
            List of face bounding boxes [(x, y, w, h), ...]
            Processed frame with detections
        """
        # Convert BGR to RGB
        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        
        # Process the frame
        results = self.face_detection.process(rgb_frame)
        
        self.detected_faces = []
        frame_height, frame_width = frame.shape[:2]
        
        if results.detections:
            for detection in results.detections:
                # Get bounding box
                bboxC = detection.location_data.relative_bounding_box
                
                # Convert to pixel coordinates
                x = int(bboxC.xmin * frame_width)
                y = int(bboxC.ymin * frame_height)
                w = int(bboxC.width * frame_width)
                h = int(bboxC.height * frame_height)
                
                # Ensure coordinates are within frame bounds
                x = max(0, x)
                y = max(0, y)
                w = min(w, frame_width - x)
                h = min(h, frame_height - y)
                
                # Get confidence score
                confidence = detection.score[0]
                
                self.detected_faces.append({
                    'bbox': (x, y, w, h),
                    'confidence': confidence
                })
        
        return self.detected_faces
    
    def draw_detections(self, frame, draw_landmarks=True):
        """
        Draw bounding boxes around detected faces
        
        Args:
            frame: Input frame
            draw_landmarks: Whether to draw facial landmarks
            
        Returns:
            Frame with drawn detections
        """
        output_frame = frame.copy()
        
        for face in self.detected_faces:
            x, y, w, h = face['bbox']
            confidence = face['confidence']
            
            # Draw bounding box
            color = (0, 255, 0)  # Green
            cv2.rectangle(output_frame, (x, y), (x + w, y + h), color, 2)
            
            # Draw confidence score
            label = f"Face: {confidence:.2f}"
            cv2.putText(
                output_frame, label, (x, y - 10),
                cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2
            )
        
        return output_frame
    
    def get_face_crops(self, frame, padding=20):
        """
        Extract cropped face regions from frame
        
        Args:
            frame: Input frame
            padding: Padding around face bounding box
            
        Returns:
            List of cropped face images
        """
        face_crops = []
        frame_height, frame_width = frame.shape[:2]
        
        for face in self.detected_faces:
            x, y, w, h = face['bbox']
            
            # Add padding
            x1 = max(0, x - padding)
            y1 = max(0, y - padding)
            x2 = min(frame_width, x + w + padding)
            y2 = min(frame_height, y + h + padding)
            
            # Crop face
            face_crop = frame[y1:y2, x1:x2]
            
            if face_crop.size > 0:
                face_crops.append({
                    'image': face_crop,
                    'bbox': (x, y, w, h),
                    'confidence': face['confidence']
                })
        
        return face_crops
    
    def get_num_faces(self):
        """Get number of detected faces"""
        return len(self.detected_faces)
    
    def close(self):
        """Release resources"""
        self.face_detection.close()


class FaceDetectorHaar:
    """Alternative face detector using OpenCV Haar Cascades (faster but less accurate)"""
    
    def __init__(self, scale_factor=1.1, min_neighbors=5, min_size=(30, 30)):
        """
        Initialize Haar Cascade face detector
        
        Args:
            scale_factor: Image pyramid scale factor
            min_neighbors: Minimum number of neighbors for detection
            min_size: Minimum face size
        """
        self.face_cascade = cv2.CascadeClassifier(
            cv2.data.haarcascades + 'haarcascade_frontalface_default.xml'
        )
        self.scale_factor = scale_factor
        self.min_neighbors = min_neighbors
        self.min_size = min_size
        self.detected_faces = []
    
    def detect_faces(self, frame):
        """Detect faces using Haar Cascades"""
        # Convert to grayscale
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        
        # Detect faces
        faces = self.face_cascade.detectMultiScale(
            gray,
            scaleFactor=self.scale_factor,
            minNeighbors=self.min_neighbors,
            minSize=self.min_size
        )
        
        self.detected_faces = []
        for (x, y, w, h) in faces:
            self.detected_faces.append({
                'bbox': (x, y, w, h),
                'confidence': 1.0  # Haar doesn't provide confidence
            })
        
        return self.detected_faces
    
    def draw_detections(self, frame):
        """Draw bounding boxes around detected faces"""
        output_frame = frame.copy()
        
        for face in self.detected_faces:
            x, y, w, h = face['bbox']
            cv2.rectangle(output_frame, (x, y), (x + w, y + h), (0, 255, 0), 2)
            cv2.putText(
                output_frame, "Face", (x, y - 10),
                cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2
            )
        
        return output_frame
    
    def get_face_crops(self, frame, padding=20):
        """Extract cropped face regions"""
        face_crops = []
        frame_height, frame_width = frame.shape[:2]
        
        for face in self.detected_faces:
            x, y, w, h = face['bbox']
            
            # Add padding
            x1 = max(0, x - padding)
            y1 = max(0, y - padding)
            x2 = min(frame_width, x + w + padding)
            y2 = min(frame_height, y + h + padding)
            
            # Crop face
            face_crop = frame[y1:y2, x1:x2]
            
            if face_crop.size > 0:
                face_crops.append({
                    'image': face_crop,
                    'bbox': (x, y, w, h),
                    'confidence': face['confidence']
                })
        
        return face_crops
    
    def get_num_faces(self):
        """Get number of detected faces"""
        return len(self.detected_faces)


# Example usage
if __name__ == "__main__":
    # Initialize detector
    detector = FaceDetector(min_detection_confidence=0.6)
    
    # Open webcam
    cap = cv2.VideoCapture(0)
    
    print("Face Detection Demo - Press 'q' to quit")
    
    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break
        
        # Detect faces
        faces = detector.detect_faces(frame)
        
        # Draw detections
        output_frame = detector.draw_detections(frame)
        
        # Display info
        cv2.putText(
            output_frame, f"Faces: {len(faces)}", (10, 30),
            cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2
        )
        
        # Show frame
        cv2.imshow('Face Detection', output_frame)
        
        # Exit on 'q'
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
    
    cap.release()
    cv2.destroyAllWindows()
    detector.close()
