# YOLOv8 Usage - Complete Technical Details

## 📱 **Where YOLOv8 is Used**

**YOLOv8** (You Only Look Once version 8) is used for **mobile phone detection** in your Smart Classroom system.

**Location:** `src/phone_detection.py`

---

## 🎯 **What YOLOv8 Does**

### **Purpose:**
Detects mobile phones being used by students in the classroom.

### **Detection Target:**
- **Object:** Cell phones / Mobile phones
- **COCO Class ID:** 67 ('cell phone' in COCO dataset)

### **Use Case:**
- Detect when **Vishal** is using a mobile phone
- Send alert email to teacher and parents
- Part of the multi-violation detection system

---

## 🔧 **YOLOv8 Implementation Details**

### **1. Model Information**

**Model File:** `yolov8n.pt`
- **Type:** YOLOv8 Nano (smallest, fastest version)
- **Size:** ~6 MB
- **Speed:** Real-time detection (30+ FPS)
- **Accuracy:** Good for common objects like phones

**Model Variants Available:**
- `yolov8n.pt` - Nano (fastest, used in your system)
- `yolov8s.pt` - Small
- `yolov8m.pt` - Medium
- `yolov8l.pt` - Large
- `yolov8x.pt` - Extra Large (most accurate, slowest)

### **2. Library**

**Package:** `ultralytics`
```bash
pip install ultralytics
```

**Import:**
```python
from ultralytics import YOLO
```

### **3. Confidence Threshold**

**File:** `src/phone_detection.py` line 26
```python
confidence_threshold = 0.5  # Default
```

**Meaning:**
- Detection confidence must be **≥ 0.5** (50%) to be counted
- Lower = more detections but more false positives
- Higher = fewer false positives but might miss phones

---

## 📊 **How YOLOv8 Works in Your System**

### **Step 1: Initialization**
```python
# src/phone_detection.py line 46-47
self.model = YOLO('yolov8n.pt')
```

**What Happens:**
- Loads pre-trained YOLOv8 Nano model
- If model file doesn't exist, automatically downloads it from Ultralytics
- Model is trained on COCO dataset (80 common object classes)

### **Step 2: Frame Processing**
```python
# src/phone_detection.py line 72-74
results = self.model(
    small_frame, 
    verbose=False, 
    classes=[67]  # Only detect cell phones
)
```

**Optimizations:**
1. **Frame Resizing:** Reduces frame to 50% size for faster processing
2. **Class Filtering:** Only detects class ID 67 (cell phones)
3. **Silent Mode:** No console output (`verbose=False`)

### **Step 3: Detection Result**
```python
# src/phone_detection.py line 87-93
detection = {
    'bbox': (x, y, w, h),      # Bounding box coordinates
    'confidence': confidence,   # Detection confidence (0-1)
    'class': 'cell_phone',     # Object class
    'center': (x + w//2, y + h//2)  # Center point
}
```

### **Step 4: Matching Phone to Student**
```python
# src/phone_detection.py line 106-139
# Calculates distance between phone and each detected face
# Matches phone to closest student (within 300 pixels)
```

**Logic:**
- Finds center of phone bounding box
- Finds center of each student's face
- Calculates Euclidean distance
- Matches to closest student within 300 pixel radius

---

## 🎓 **Student-Specific Usage**

### **Vishal Detection Logic:**
When Vishal is detected:
1. **YOLOv8 detects phone** near Vishal's face
2. **Distance check:** Phone within 300 pixels of face
3. **Alert triggered:** Email sent to teacher AND parents
4. **No attendance marked** (proxy + phone violation)

**File Reference:** `main.py` (Vishal section)

---

## 📋 **COCO Dataset Class ID 67**

**COCO Dataset:** Common Objects in Context
- 80 object classes
- Class 67 = "cell phone"

**Other Classes in COCO (for reference):**
- 0: person
- 1: bicycle
- 2: car
- 39: bottle
- 67: cell phone ← **Used in your system**
- 73: laptop

---

## ⚙️ **Configuration Parameters**

### **Model Path**
```python
model_path = 'yolov8n.pt'
```
- Looks for model in current directory
- Downloads automatically if not found

### **Confidence Threshold**
```python
confidence_threshold = 0.5
```
- **0.5 = 50% confidence** required
- Balanced between accuracy and false positives

### **Detection Class**
```python
CELL_PHONE_CLASS_ID = 67
```
- COCO dataset class for cell phones
- Only this class is detected (ignores other objects)

### **Distance Threshold**
```python
distance < 300  # pixels
```
- Maximum distance to match phone to student
- 300 pixels = reasonable proximity to face

---

## 🚀 **Performance Optimizations**

### **1. Frame Scaling**
```python
scale = 0.5
small_frame = cv2.resize(frame, None, fx=scale, fy=scale)
```
**Why:** Processing 640x480 instead of 1280x960 = 4x faster

### **2. Class Filtering**
```python
results = self.model(small_frame, classes=[67])
```
**Why:** Only detect phones, ignore other 79 classes = faster

### **3. Silent Mode**
```python
verbose=False
```
**Why:** No console spam during detection

### **4. Detection Threshold**
```python
if confidence >= self.confidence_threshold:
```
**Why:** Filter out low-confidence false positives

---

## 📊 **Detection Workflow**

```
Video Frame (640x480)
        ↓
Resize to 50% (320x240) for speed
        ↓
YOLOv8 Inference (class 67 only)
        ↓
Filter by confidence ≥ 0.5
        ↓
Scale bounding box back to original size
        ↓
Match phone to nearest student face
        ↓
Create incident report
        ↓
Log to JSON file
        ↓
Send alert email (if student known)
```

---

## 🎯 **YOLOv8 vs Other Methods**

### **Why YOLOv8?**
✅ **Real-time:** 30+ FPS on CPU
✅ **Accurate:** Pre-trained on millions of images
✅ **Easy to use:** One-line detection
✅ **Pre-trained:** No need to train from scratch
✅ **Auto-download:** Model downloads automatically

### **Alternatives (Not Used):**
- Traditional CV (Haar Cascades) - less accurate
- Faster R-CNN - slower but more accurate
- SSD - similar speed, less accurate
- Custom CNN - requires training data

---

## 🔍 **Detection Output Example**

```python
{
    'phone_bbox': (450, 200, 80, 150),     # x, y, width, height
    'phone_confidence': 0.87,               # 87% confidence
    'student_name': 'Vishal',               # Matched student
    'student_bbox': (400, 150, 120, 160),  # Face bounding box
    'distance': 89.4,                       # Pixels from face to phone
    'timestamp': '2026-07-13 10:30:45'     # Detection time
}
```

---

## 📁 **File Structure**

```
CLAUDE/
├── src/
│   └── phone_detection.py        ← YOLOv8 implementation
├── models/
│   └── yolov8n.pt               ← Model weights (auto-downloaded)
├── data/
│   └── behavior_logs/
│       └── 2026-07-13.json      ← Phone usage logs
└── requirements.txt             ← ultralytics>=8.0.0
```

---

## 🛠️ **Installation**

### **Install YOLOv8 Package:**
```bash
pip install ultralytics
```

### **Model Download:**
Model is downloaded automatically on first run:
```
Downloading yolov8n.pt from https://github.com/ultralytics/assets/releases/download/v0.0.0/yolov8n.pt
```

---

## 🎨 **Visualization**

When phone is detected, the system draws:
- ✅ **Red bounding box** around phone
- ✅ **"PHONE: 0.87"** label (with confidence)
- ✅ **Student name** above phone
- ✅ **Red line** connecting phone to student face

**File:** `phone_detection.py` lines 242-283

---

## 📝 **Logging**

### **Phone Usage Log:**
**Location:** `data/behavior_logs/2026-07-13.json`

**Format:**
```json
{
    "timestamp": "2026-07-13 10:30:45",
    "student_name": "Vishal",
    "behavior": "phone_usage",
    "action": "detected",
    "confidence": 0.87
}
```

### **Threshold for Logging:**
- Requires **30 consecutive detections** (~1 second at 30 FPS)
- Prevents logging random false positives
- Only logs once per continuous usage session

---

## ⚠️ **Current Status in Your System**

### **Phone Detection is DISABLED in main.py**

**Reason:** Lines 76-77 in main.py show:
```python
# Behavior Analyzer - DISABLED (not needed, simplifying system)
# Phone Detector - DISABLED (not needed, simplifying system)
```

**To Enable:**
Uncomment the phone detector initialization in `main.py`

---

## 🔧 **How to Adjust YOLOv8 Settings**

### **Change Confidence Threshold:**
Edit `src/phone_detection.py` line 26:
```python
confidence_threshold = 0.5  # Change to 0.3 (more detections) or 0.7 (fewer false positives)
```

### **Change Model Version:**
Edit `src/phone_detection.py` line 26:
```python
model_path = 'yolov8s.pt'  # Use small model (more accurate, slower)
```

### **Change Distance Threshold:**
Edit `src/phone_detection.py` line 138:
```python
if distance < min_distance and distance < 300:  # Change 300 to larger/smaller value
```

---

## 📚 **YOLOv8 Technical Specs**

### **Architecture:**
- **Backbone:** CSPDarknet53
- **Neck:** PANet
- **Head:** YOLOv8 detection head
- **Input Size:** 640x640 (automatically resized)
- **Output:** Bounding boxes + confidence scores

### **Training Data:**
- **Dataset:** COCO (Common Objects in Context)
- **Images:** 118,000 training images
- **Classes:** 80 object categories
- **Annotations:** Over 1 million object instances

### **Performance (YOLOv8n):**
- **Speed:** ~45 FPS on CPU
- **mAP:** 37.3% (on COCO val2017)
- **Parameters:** 3.2M
- **Model Size:** ~6 MB

---

## 🎯 **Vishal's Multi-Violation Detection**

When **both** are detected:
1. ❌ **No blink** (EAR < 0.21 for 8 seconds) → Proxy detected
2. 📱 **Phone detected** (YOLOv8 class 67) → Phone usage

**Result:**
- ❌ Attendance NOT marked
- 📧 Email to teacher: "Proxy detected"
- 📧 Email to parents: "Proxy detected"
- 📧 Email to teacher: "Using phone"
- 📧 Email to parents: "Using phone"

---

## 💡 **Key Takeaways**

1. **YOLOv8 is used for phone detection only**
2. **Model:** YOLOv8 Nano (`yolov8n.pt`)
3. **Class:** COCO class 67 (cell phone)
4. **Confidence:** ≥ 0.5 (50%)
5. **Speed:** Real-time (30+ FPS)
6. **Auto-download:** Model downloads on first run
7. **Currently:** Disabled in main.py (commented out)
8. **Student:** Primarily for Vishal's phone detection

---

## 🔗 **References**

### **YOLOv8 Documentation:**
- Official Docs: https://docs.ultralytics.com/
- GitHub: https://github.com/ultralytics/ultralytics
- Paper: "YOLOv8: Real-time Object Detection"

### **COCO Dataset:**
- Website: https://cocodataset.org/
- Classes: https://cocodataset.org/#explore
- Class 67: cell phone

---

That's everything about YOLOv8 in your system! 📱🎯✨
