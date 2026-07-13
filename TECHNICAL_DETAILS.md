# Technical Details - EAR, MAR, and Algorithms

## 📊 **Confusion Matrix - NOT USED**

**Answer:** You are **NOT using a confusion matrix** in this project.

### **What You're Using Instead:**

**K-Nearest Neighbors (KNN) Classifier** for face recognition:
- Location: `src/face_recognition.py`
- Algorithm: `sklearn.neighbors.KNeighborsClassifier`
- No confusion matrix generated

**Why No Confusion Matrix?**
- Confusion matrices are used for **evaluating model performance** on test data
- Your system does **real-time recognition** without formal testing/validation
- You train once and deploy (no accuracy evaluation phase)

---

## 👁️ **EAR (Eye Aspect Ratio)**

### **What is EAR?**
**Eye Aspect Ratio** - measures how open/closed the eyes are.

### **Formula:**
```
EAR = (||p2-p6|| + ||p3-p5||) / (2 * ||p1-p4||)
```

Where:
- `||p2-p6||` = vertical distance (top to bottom of eye)
- `||p3-p5||` = vertical distance (middle of eye)
- `||p1-p4||` = horizontal distance (left to right corner)

### **EAR Threshold Values in Your System:**

#### **1. Sleep Detection (Behavior Analysis)**
**File:** `src/behavior_analysis.py`
```python
ear_threshold = 0.22  # Default value
```

**Usage:**
- **EAR < 0.22** → Eyes are **closed** (sleeping detected)
- **EAR > 0.22** → Eyes are **open** (awake)

**When Triggered:**
- Eyes closed for **25 consecutive frames** (about 0.8 seconds at 30fps)
- Then marked as **sleeping**

#### **2. Blink Detection (Anti-Proxy)**
**File:** `src/anti_proxy.py`
```python
ear_threshold = 0.21  # Default value
```

**Usage:**
- **EAR < 0.21** → Eyes **closing** (blink detected)
- **EAR > 0.21** → Eyes **open**

**When Triggered:**
- Eyes below threshold for **3 consecutive frames**
- Then eyes open again → Counted as **1 blink**
- Need **1 blink within 8 seconds** to verify live person

---

## 👄 **MAR (Mouth Aspect Ratio)**

### **What is MAR?**
**Mouth Aspect Ratio** - measures how open the mouth is.

### **Formula:**
```
MAR = (||p2-p8|| + ||p3-p7|| + ||p4-p6||) / (2 * ||p1-p5||)
```

Where:
- Vertical distances = mouth opening height (top to bottom lip)
- Horizontal distance = mouth width (left to right corner)

### **MAR Threshold Value:**

**File:** `src/behavior_analysis.py`
```python
mar_threshold = 0.6  # Default value (not currently used)
```

**Current Implementation:**
Your system uses a **different threshold** for talking detection:
```python
is_mouth_very_wide = mar_current > 0.5  # Teeth showing threshold
```

**Usage:**
- **MAR > 0.5** → Mouth **VERY WIDE open** (teeth showing - talking)
- **MAR < 0.5** → Mouth **closed or slightly open** (not talking)

**When Triggered:**
- Mouth wide open for **3 consecutive frames**
- Duration tracked in seconds
- Alert sent after **5 seconds** of continuous talking

---

## 📋 **Summary Table**

| Metric | Threshold | Purpose | Location |
|--------|-----------|---------|----------|
| **EAR (Sleep)** | **< 0.22** | Detect closed eyes (sleeping) | `behavior_analysis.py` |
| **EAR (Blink)** | **< 0.21** | Detect eye closing (blink) | `anti_proxy.py` |
| **MAR (Talking)** | **> 0.5** | Detect wide mouth (talking) | `behavior_analysis.py` |

---

## 🎯 **How These Values Work**

### **EAR Values (Eye Aspect Ratio)**

**Typical Values:**
- **0.30 - 0.35** = Eyes **wide open**
- **0.20 - 0.25** = Eyes **partially closed** or **blinking**
- **< 0.20** = Eyes **fully closed** (sleeping)

**Your Thresholds:**
- **0.21** for blink detection (anti-proxy)
- **0.22** for sleep detection (behavior)

**Why these values?**
- Researched standard values from computer vision papers
- Work well for most people
- Can be adjusted in `config/config.yaml`

### **MAR Values (Mouth Aspect Ratio)**

**Typical Values:**
- **0.1 - 0.3** = Mouth **closed**
- **0.3 - 0.5** = Mouth **slightly open** (normal speech)
- **> 0.5** = Mouth **VERY wide open** (yelling, teeth showing)

**Your Threshold:**
- **0.5** for talking detection (teeth showing)

**Why this value?**
- Detects **exaggerated mouth opening** (teeth visible)
- Avoids false positives from normal facial expressions
- Specifically designed for your requirement: "mouth wide open showing teeth"

---

## 🔬 **Where Values Are Used**

### **1. Main System Configuration**
**File:** `main.py` (line 72-74)
```python
self.anti_proxy = AntiProxyVerifier(
    ear_threshold=self.config.get('blink_threshold', 0.21),  # EAR for blink
    consec_frames=3,
    blink_threshold=self.config.get('required_blinks', 2)
)
```

### **2. Behavior Analysis**
**File:** `behavior_analysis.py` (line 34-37)
```python
def __init__(self, 
             ear_threshold=0.22,        # Sleep detection threshold
             ear_consec_frames=25,      # Frames before marking as sleeping
             mar_threshold=0.6,         # Talking detection threshold (not used)
             mar_consec_frames=3):      # Frames before marking as talking
```

**Actual Talking Detection:**
```python
# Line 267-268
is_mouth_very_wide = mar_current > 0.5  # Teeth showing threshold
```

### **3. Anti-Proxy Verification**
**File:** `anti_proxy.py` (line 26-31)
```python
def __init__(self, ear_threshold=0.21, consec_frames=3, blink_threshold=1):
    """
    Args:
        ear_threshold: Eye Aspect Ratio threshold for blink detection
        consec_frames: Consecutive frames below threshold to count as blink
        blink_threshold: Minimum blinks required for verification
    """
```

---

## 🎓 **Student-Specific Detection Logic**

### **Bhava (Talking Detection)**
- **Metric:** MAR > 0.5
- **Duration:** 5 seconds continuous
- **Trigger:** Mouth wide open showing teeth
- **Action:** Email to teacher

### **Vishal (Proxy Detection)**
- **Metric:** EAR < 0.21 (no blink)
- **Duration:** 8 seconds without blink
- **Trigger:** No eye closing detected
- **Action:** NO attendance + Email to teacher AND parents

### **Priya (Sleeping Detection)**
- **Metric:** EAR < 0.22
- **Duration:** 25 frames (~0.8 seconds)
- **Trigger:** Eyes closed continuously
- **Action:** Email to teacher

---

## 🔧 **How to Adjust Thresholds**

### **Method 1: Config File (Recommended)**

Edit `config/config.yaml`:
```yaml
# Eye Aspect Ratio for blink detection
blink_threshold: 0.21

# Required number of blinks
required_blinks: 2

# Sleep detection
ear_threshold: 0.22

# Talking detection
mar_threshold: 0.5
```

### **Method 2: Code Change**

**For EAR (blink detection):**
Edit `main.py` line 72:
```python
ear_threshold=0.21,  # Change this value
```

**For EAR (sleep detection):**
Edit `behavior_analysis.py` line 34:
```python
ear_threshold=0.22,  # Change this value
```

**For MAR (talking detection):**
Edit `behavior_analysis.py` line 267:
```python
is_mouth_very_wide = mar_current > 0.5  # Change 0.5 to your value
```

---

## 📊 **Algorithm Summary**

### **Face Recognition Algorithm**
- **Type:** K-Nearest Neighbors (KNN)
- **Features:** Flattened pixel values (100x100 grayscale)
- **Training:** Supervised learning on student face images
- **Prediction:** Find K closest matches in feature space
- **No confusion matrix used**

### **Behavior Detection Algorithms**

**Sleep Detection:**
1. Calculate EAR for both eyes
2. Average the values
3. If EAR < 0.22 for 25 frames → Sleeping

**Blink Detection:**
1. Calculate EAR for both eyes
2. If EAR < 0.21 for 3 frames → Eye closing
3. Then EAR > 0.21 → Eye opening
4. Count as 1 blink

**Talking Detection:**
1. Calculate MAR from mouth landmarks
2. If MAR > 0.5 (very wide mouth) → Talking
3. Track duration in seconds

---

## 📖 **References**

### **EAR (Eye Aspect Ratio)**
- Based on: "Real-Time Eye Blink Detection using Facial Landmarks"
- Paper: Soukupová and Čech (2016)
- Standard threshold: 0.2 - 0.25

### **MAR (Mouth Aspect Ratio)**
- Adapted from EAR concept
- Applied to mouth landmarks
- Custom threshold for your use case

---

## 💡 **Key Takeaways**

1. **NO confusion matrix** - using KNN classifier without formal evaluation
2. **EAR = 0.21-0.22** - for eye closing detection (blink/sleep)
3. **MAR = 0.5** - for wide mouth detection (talking/teeth showing)
4. **MediaPipe Face Mesh** - provides 468 facial landmarks
5. **Real-time processing** - no batch evaluation needed

---

That's the complete technical breakdown! 🎓✨
