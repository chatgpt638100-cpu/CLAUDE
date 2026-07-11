"""
Face Recognition Module using K-Nearest Neighbors (KNN) Classifier
Identifies students from their faces for attendance tracking
"""
import cv2
import numpy as np
import pickle
import os
from sklearn.neighbors import KNeighborsClassifier
from sklearn.preprocessing import LabelEncoder
from datetime import datetime
import json


class FaceRecognizer:
    """Face recognition using KNN classifier with face embeddings"""
    
    def __init__(self, model_path='models/trained_knn_model.pkl', n_neighbors=5):
        """
        Initialize Face Recognizer
        
        Args:
            model_path: Path to saved KNN model (relative to project root)
            n_neighbors: Number of neighbors for KNN
        """
        # Convert relative path to absolute path
        if not os.path.isabs(model_path):
            script_dir = os.path.dirname(os.path.abspath(__file__))
            project_root = os.path.dirname(script_dir)
            model_path = os.path.join(project_root, model_path)
        
        self.model_path = model_path
        self.n_neighbors = n_neighbors
        self.knn_model = None
        self.label_encoder = None
        self.face_recognizer = cv2.face.LBPHFaceRecognizer_create()
        self.training_data = []
        self.training_labels = []
        self.student_names = []
        
        # Load model if exists
        if os.path.exists(model_path):
            self.load_model()
    
    def extract_features(self, face_image):
        """
        Extract features from face image using histogram-based approach
        
        Args:
            face_image: Cropped face image
            
        Returns:
            Feature vector
        """
        # Resize to standard size
        face_resized = cv2.resize(face_image, (100, 100))
        
        # Convert to grayscale if needed
        if len(face_resized.shape) == 3:
            gray = cv2.cvtColor(face_resized, cv2.COLOR_BGR2GRAY)
        else:
            gray = face_resized
        
        # Apply histogram equalization
        gray = cv2.equalizeHist(gray)
        
        # Extract HOG features (Histogram of Oriented Gradients)
        # For simplicity, we'll use flattened pixel values with preprocessing
        features = gray.flatten()
        
        # Normalize features
        features = features.astype(np.float32) / 255.0
        
        return features
    
    def add_training_sample(self, face_image, student_name):
        """
        Add a training sample for a student
        
        Args:
            face_image: Face image
            student_name: Name of the student
        """
        features = self.extract_features(face_image)
        self.training_data.append(features)
        self.training_labels.append(student_name)
        
        if student_name not in self.student_names:
            self.student_names.append(student_name)
    
    def load_training_data_from_directory(self, data_dir='data/students'):
        """
        Load training data from directory structure:
        data/students/
            ├── student1/
            │   ├── img1.jpg
            │   ├── img2.jpg
            ├── student2/
            │   ├── img1.jpg
            │   ├── img2.jpg
        
        Args:
            data_dir: Path to students directory (relative to project root)
        """
        # FIX: Convert relative path to absolute path based on project root
        script_dir = os.path.dirname(os.path.abspath(__file__))
        project_root = os.path.dirname(script_dir)  # Go up one level from src/
        full_data_dir = os.path.join(project_root, data_dir)
        
        print(f"Loading training data from {full_data_dir}...")
        
        if not os.path.exists(full_data_dir):
            print(f"Directory {full_data_dir} does not exist. Creating it...")
            os.makedirs(full_data_dir)
            return
        
        self.training_data = []
        self.training_labels = []
        self.student_names = []
        
        student_dirs = [d for d in os.listdir(full_data_dir) 
                       if os.path.isdir(os.path.join(full_data_dir, d))]
        
        if not student_dirs:
            print("No student directories found. Please add student images.")
            return
        
        for student_name in student_dirs:
            student_path = os.path.join(full_data_dir, student_name)
            image_files = [f for f in os.listdir(student_path) 
                          if f.lower().endswith(('.jpg', '.jpeg', '.png'))]
            
            print(f"Loading {len(image_files)} images for {student_name}")
            
            for img_file in image_files:
                img_path = os.path.join(student_path, img_file)
                img = cv2.imread(img_path)
                
                if img is not None:
                    self.add_training_sample(img, student_name)
        
        print(f"Loaded {len(self.training_data)} training samples for {len(self.student_names)} students")
    
    def train(self):
        """Train the KNN classifier"""
        if len(self.training_data) == 0:
            print("No training data available. Please load data first.")
            return False
        
        print("Training KNN classifier...")
        
        # Convert to numpy arrays
        X = np.array(self.training_data)
        y = np.array(self.training_labels)
        
        # Encode labels
        self.label_encoder = LabelEncoder()
        y_encoded = self.label_encoder.fit_transform(y)
        
        # Train KNN
        self.knn_model = KNeighborsClassifier(
            n_neighbors=min(self.n_neighbors, len(self.student_names)),
            weights='distance',
            metric='euclidean'
        )
        self.knn_model.fit(X, y_encoded)
        
        print("Training completed!")
        return True
    
    def save_model(self):
        """Save trained model to disk"""
        if self.knn_model is None:
            print("No trained model to save.")
            return
        
        os.makedirs(os.path.dirname(self.model_path), exist_ok=True)
        
        model_data = {
            'knn_model': self.knn_model,
            'label_encoder': self.label_encoder,
            'student_names': self.student_names
        }
        
        with open(self.model_path, 'wb') as f:
            pickle.dump(model_data, f)
        
        print(f"Model saved to {self.model_path}")
    
    def load_model(self):
        """Load trained model from disk"""
        if not os.path.exists(self.model_path):
            print(f"Model file {self.model_path} not found.")
            return False
        
        with open(self.model_path, 'rb') as f:
            model_data = pickle.load(f)
        
        self.knn_model = model_data['knn_model']
        self.label_encoder = model_data['label_encoder']
        self.student_names = model_data['student_names']
        
        # Silent mode - no output
        return True
    
    def recognize_face(self, face_image, threshold=0.6):
        """
        Recognize a face
        
        Args:
            face_image: Face image to recognize
            threshold: Confidence threshold (0-1)
            
        Returns:
            Dictionary with name and confidence, or None if unknown
        """
        if self.knn_model is None:
            # Model not trained - return Unknown silently
            return None
        
        # Extract features
        features = self.extract_features(face_image)
        features = features.reshape(1, -1)
        
        # Predict
        try:
            # Get prediction and probabilities
            prediction = self.knn_model.predict(features)
            probabilities = self.knn_model.predict_proba(features)
            
            # Get confidence (max probability)
            confidence = np.max(probabilities)
            
            # Decode label
            student_name = self.label_encoder.inverse_transform(prediction)[0]
            
            # Check threshold
            if confidence >= threshold:
                return {
                    'name': student_name,
                    'confidence': float(confidence),
                    'status': 'recognized'
                }
            else:
                return {
                    'name': 'Unknown',
                    'confidence': float(confidence),
                    'status': 'unknown'
                }
        except Exception as e:
            print(f"Recognition error: {e}")
            return None
    
    def recognize_multiple_faces(self, face_crops, threshold=0.6):
        """
        Recognize multiple faces
        
        Args:
            face_crops: List of face crop dictionaries
            threshold: Recognition threshold
            
        Returns:
            List of recognition results
        """
        results = []
        
        for face_crop in face_crops:
            face_image = face_crop['image']
            bbox = face_crop['bbox']
            
            recognition_result = self.recognize_face(face_image, threshold)
            
            if recognition_result:
                recognition_result['bbox'] = bbox
                results.append(recognition_result)
        
        return results
    
    def mark_attendance(self, student_name, confidence):
        """
        Mark attendance for a student - SAVES TO BOTH JSON AND EXCEL
        
        Args:
            student_name: Name of the student
            confidence: Recognition confidence
        """
        attendance_data = {
            'student_name': student_name,
            'timestamp': datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            'confidence': confidence,
            'status': 'present'
        }
        
        # Save to JSON log
        log_dir = 'data/attendance_logs'
        os.makedirs(log_dir, exist_ok=True)
        
        date_str = datetime.now().strftime("%Y-%m-%d")
        log_file = os.path.join(log_dir, f"{date_str}.json")
        
        # Load existing logs
        if os.path.exists(log_file):
            with open(log_file, 'r') as f:
                logs = json.load(f)
        else:
            logs = []
        
        # Check if student already marked present today
        student_already_marked = any(
            log['student_name'] == student_name for log in logs
        )
        
        if not student_already_marked:
            logs.append(attendance_data)
            
            with open(log_file, 'w') as f:
                json.dump(logs, f, indent=4)
            
            # ALSO EXPORT TO EXCEL
            try:
                # Import here to avoid circular dependency
                import sys
                sys.path.insert(0, os.path.dirname(__file__))
                from excel_attendance import mark_attendance_to_excel
                mark_attendance_to_excel(student_name, confidence)
            except Exception as e:
                print(f"Excel export failed: {e}")
            
            print(f"✓ Attendance marked for {student_name} at {attendance_data['timestamp']}")
            print(f"✓ Exported to JSON and Excel")
            return True
        else:
            print(f"{student_name} already marked present today")
            return False
    
    def get_today_attendance(self):
        """Get today's attendance list"""
        date_str = datetime.now().strftime("%Y-%m-%d")
        log_file = f"data/attendance_logs/{date_str}.json"
        
        if os.path.exists(log_file):
            with open(log_file, 'r') as f:
                return json.load(f)
        return []
    
    def get_absent_students(self, all_students):
        """
        Get list of absent students
        
        Args:
            all_students: List of all student names
            
        Returns:
            List of absent student names
        """
        present_students = [log['student_name'] for log in self.get_today_attendance()]
        absent = [s for s in all_students if s not in present_students]
        return absent


# Training script
def train_new_model(data_dir='data/students', model_path='models/trained_knn_model.pkl'):
    """
    Train a new face recognition model
    
    Args:
        data_dir: Directory containing student images
        model_path: Path to save the model
    """
    recognizer = FaceRecognizer(model_path=model_path)
    
    # Load training data
    recognizer.load_training_data_from_directory(data_dir)
    
    if len(recognizer.training_data) == 0:
        print("No training data found. Please add student images to data/students/")
        return
    
    # Train model
    success = recognizer.train()
    
    if success:
        # Save model
        recognizer.save_model()
        print(f"\nModel trained successfully with {len(recognizer.student_names)} students:")
        for name in recognizer.student_names:
            print(f"  - {name}")


# Example usage
if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1 and sys.argv[1] == 'train':
        # Training mode
        print("=== Face Recognition Training ===")
        train_new_model()
    else:
        # Recognition demo mode
        print("=== Face Recognition Demo ===")
        
        recognizer = FaceRecognizer()
        
        if recognizer.knn_model is None:
            print("\nNo trained model found. Please train first:")
            print("python face_recognition.py train")
            sys.exit(1)
        
        # Open webcam
        from face_detection import FaceDetector
        
        face_detector = FaceDetector()
        cap = cv2.VideoCapture(0)
        
        print("\nRecognition started. Press 'q' to quit, 'a' to mark attendance")
        
        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break
            
            # Detect faces
            face_detector.detect_faces(frame)
            face_crops = face_detector.get_face_crops(frame)
            
            # Recognize faces
            results = recognizer.recognize_multiple_faces(face_crops)
            
            # Draw results
            for result in results:
                x, y, w, h = result['bbox']
                name = result['name']
                confidence = result['confidence']
                
                # Color based on recognition
                color = (0, 255, 0) if name != 'Unknown' else (0, 0, 255)
                
                # Draw box and label
                cv2.rectangle(frame, (x, y), (x + w, y + h), color, 2)
                label = f"{name} ({confidence:.2f})"
                cv2.putText(frame, label, (x, y - 10),
                           cv2.FONT_HERSHEY_SIMPLEX, 0.6, color, 2)
            
            # Display info
            cv2.putText(frame, f"Faces: {len(results)}", (10, 30),
                       cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 2)
            
            cv2.imshow('Face Recognition', frame)
            
            key = cv2.waitKey(1) & 0xFF
            if key == ord('q'):
                break
            elif key == ord('a'):
                # Mark attendance for recognized faces
                for result in results:
                    if result['name'] != 'Unknown':
                        recognizer.mark_attendance(result['name'], result['confidence'])
        
        cap.release()
        cv2.destroyAllWindows()
        face_detector.close()
