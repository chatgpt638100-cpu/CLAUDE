"""
Utility functions for the Smart Classroom Monitoring System
"""
import cv2
import numpy as np
from datetime import datetime
import os
import json


def create_directory(path):
    """Create directory if it doesn't exist"""
    if not os.path.exists(path):
        os.makedirs(path)


def get_timestamp():
    """Get current timestamp"""
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")


def get_date():
    """Get current date"""
    return datetime.now().strftime("%Y-%m-%d")


def save_log(log_data, log_type="attendance"):
    """Save log data to JSON file"""
    log_dir = f"data/{log_type}_logs"
    create_directory(log_dir)
    
    filename = f"{log_dir}/{get_date()}.json"
    
    # Load existing logs if file exists
    if os.path.exists(filename):
        with open(filename, 'r') as f:
            logs = json.load(f)
    else:
        logs = []
    
    logs.append(log_data)
    
    with open(filename, 'w') as f:
        json.dump(logs, f, indent=4)


def draw_text(frame, text, position, font_scale=0.6, color=(255, 255, 255), 
              thickness=2, bg_color=(0, 0, 0)):
    """Draw text with background on frame"""
    font = cv2.FONT_HERSHEY_SIMPLEX
    
    # Get text size
    (text_width, text_height), baseline = cv2.getTextSize(
        text, font, font_scale, thickness
    )
    
    x, y = position
    
    # Draw background rectangle
    cv2.rectangle(
        frame,
        (x, y - text_height - baseline),
        (x + text_width, y + baseline),
        bg_color,
        -1
    )
    
    # Draw text
    cv2.putText(
        frame, text, (x, y),
        font, font_scale, color, thickness
    )


def draw_bbox(frame, bbox, label, color=(0, 255, 0)):
    """Draw bounding box with label"""
    x, y, w, h = bbox
    cv2.rectangle(frame, (x, y), (x + w, y + h), color, 2)
    draw_text(frame, label, (x, y - 10), color=color, bg_color=(0, 0, 0))


def calculate_distance(point1, point2):
    """Calculate Euclidean distance between two points"""
    return np.sqrt((point1[0] - point2[0])**2 + (point1[1] - point2[1])**2)


def calculate_ear(eye_landmarks):
    """
    Calculate Eye Aspect Ratio (EAR) for sleep detection
    EAR = (||p2-p6|| + ||p3-p5||) / (2 * ||p1-p4||)
    """
    # Vertical distances
    vertical1 = calculate_distance(eye_landmarks[1], eye_landmarks[5])
    vertical2 = calculate_distance(eye_landmarks[2], eye_landmarks[4])
    
    # Horizontal distance
    horizontal = calculate_distance(eye_landmarks[0], eye_landmarks[3])
    
    # Calculate EAR
    ear = (vertical1 + vertical2) / (2.0 * horizontal)
    
    return ear


def calculate_mar(mouth_landmarks):
    """
    Calculate Mouth Aspect Ratio (MAR) for talking detection
    MAR = (||p2-p8|| + ||p3-p7|| + ||p4-p6||) / (2 * ||p1-p5||)
    """
    # Vertical distances
    vertical1 = calculate_distance(mouth_landmarks[1], mouth_landmarks[7])
    vertical2 = calculate_distance(mouth_landmarks[2], mouth_landmarks[6])
    vertical3 = calculate_distance(mouth_landmarks[3], mouth_landmarks[5])
    
    # Horizontal distance
    horizontal = calculate_distance(mouth_landmarks[0], mouth_landmarks[4])
    
    # Calculate MAR
    mar = (vertical1 + vertical2 + vertical3) / (2.0 * horizontal)
    
    return mar


def resize_frame(frame, width=640):
    """Resize frame while maintaining aspect ratio"""
    height = int(frame.shape[0] * (width / frame.shape[1]))
    return cv2.resize(frame, (width, height))


def convert_mediapipe_to_opencv(landmarks, frame_width, frame_height):
    """Convert MediaPipe normalized coordinates to OpenCV pixel coordinates"""
    points = []
    for landmark in landmarks:
        x = int(landmark.x * frame_width)
        y = int(landmark.y * frame_height)
        points.append((x, y))
    return points
