"""
Face Collection Script
Helps collect face images for training the recognition system
"""
import cv2
import os
from face_detection import FaceDetector
import argparse


def collect_face_images(student_name, num_images=30, output_dir='data/students'):
    """
    Collect face images for a student
    
    Args:
        student_name: Name of the student
        num_images: Number of images to collect
        output_dir: Output directory
    """
    # Get the project root directory (one level up from src/)
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    
    # Create full path to output directory
    full_output_dir = os.path.join(project_root, output_dir)
    student_dir = os.path.join(full_output_dir, student_name)
    os.makedirs(student_dir, exist_ok=True)
    
    print(f"Saving images to: {student_dir}")
    
    # Initialize face detector
    detector = FaceDetector(min_detection_confidence=0.7)
    
    # Open webcam
    cap = cv2.VideoCapture(0)
    
    if not cap.isOpened():
        print("Error: Could not open webcam")
        return
    
    print(f"\n=== Collecting face images for {student_name} ===")
    print(f"Target: {num_images} images")
    print("\nInstructions:")
    print("- Position your face in the frame")
    print("- Press SPACE to capture an image")
    print("- Press 'q' to quit")
    print("- Try different angles and expressions for better accuracy")
    
    collected = 0
    
    while collected < num_images:
        ret, frame = cap.read()
        if not ret:
            break
        
        # Detect faces
        faces = detector.detect_faces(frame)
        
        # Draw detections
        output_frame = detector.draw_detections(frame)
        
        # Display progress
        progress_text = f"Collected: {collected}/{num_images}"
        cv2.putText(output_frame, progress_text, (10, 30),
                   cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)
        
        if len(faces) == 0:
            status = "No face detected - please face the camera"
            color = (0, 0, 255)
        elif len(faces) == 1:
            status = "Ready - Press SPACE to capture"
            color = (0, 255, 0)
        else:
            status = "Multiple faces detected - ensure only one person"
            color = (0, 165, 255)
        
        cv2.putText(output_frame, status, (10, 70),
                   cv2.FONT_HERSHEY_SIMPLEX, 0.6, color, 2)
        
        cv2.imshow('Face Collection', output_frame)
        
        key = cv2.waitKey(1) & 0xFF
        
        if key == ord(' ') and len(faces) == 1:
            # Capture image
            face_crops = detector.get_face_crops(frame)
            if face_crops:
                face_img = face_crops[0]['image']
                
                # Save image
                img_path = os.path.join(student_dir, f"{student_name}_{collected + 1}.jpg")
                cv2.imwrite(img_path, face_img)
                
                collected += 1
                print(f"Captured image {collected}/{num_images}")
        
        elif key == ord('q'):
            print("\nCollection cancelled by user")
            break
    
    cap.release()
    cv2.destroyAllWindows()
    detector.close()
    
    if collected > 0:
        print(f"\n✓ Successfully collected {collected} images for {student_name}")
        print(f"  Saved to: {student_dir}")
    else:
        print("\n✗ No images collected")


def batch_collect(student_names, num_images=30):
    """
    Collect faces for multiple students in sequence
    
    Args:
        student_names: List of student names
        num_images: Number of images per student
    """
    print(f"\n=== Batch Face Collection ===")
    print(f"Students: {len(student_names)}")
    print(f"Images per student: {num_images}")
    print("\nPress any key to start...")
    
    for i, name in enumerate(student_names):
        print(f"\n[{i+1}/{len(student_names)}] Collecting for: {name}")
        input("Press Enter when ready...")
        collect_face_images(name, num_images)


def list_students(data_dir='data/students'):
    """List all students in the database"""
    # Get the project root directory
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    full_data_dir = os.path.join(project_root, data_dir)
    
    if not os.path.exists(full_data_dir):
        print(f"No student data found at: {full_data_dir}")
        return
    
    student_dirs = [d for d in os.listdir(full_data_dir) 
                   if os.path.isdir(os.path.join(full_data_dir, d))]
    
    if not student_dirs:
        print("No students registered.")
        return
    
    print(f"\n=== Registered Students ({len(student_dirs)}) ===")
    for student in sorted(student_dirs):
        student_path = os.path.join(full_data_dir, student)
        image_count = len([f for f in os.listdir(student_path) 
                          if f.lower().endswith(('.jpg', '.jpeg', '.png'))])
        print(f"  - {student}: {image_count} images")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Collect face images for training')
    parser.add_argument('--name', type=str, help='Student name')
    parser.add_argument('--images', type=int, default=30, help='Number of images to collect')
    parser.add_argument('--batch', nargs='+', help='Collect for multiple students')
    parser.add_argument('--list', action='store_true', help='List registered students')
    
    args = parser.parse_args()
    
    if args.list:
        list_students()
    elif args.batch:
        batch_collect(args.batch, args.images)
    elif args.name:
        collect_face_images(args.name, args.images)
    else:
        print("Face Collection Tool")
        print("\nUsage:")
        print("  Collect for one student:")
        print("    python collect_faces.py --name 'John Doe' --images 30")
        print("\n  Collect for multiple students:")
        print("    python collect_faces.py --batch 'John Doe' 'Jane Smith' 'Bob Johnson'")
        print("\n  List registered students:")
        print("    python collect_faces.py --list")
