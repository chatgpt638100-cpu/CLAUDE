# Training Guide - Which Files Are Used

## 📸 Files Used for Training

Your Smart Classroom system uses **student face images** stored in the `data/students/` folder for training.

---

## 🗂️ Training Data Structure

```
data/students/
├── Bhava/              ← Folder for Bhava's face images
│   ├── Bhava_1.jpg
│   ├── Bhava_2.jpg
│   ├── Bhava_3.jpg
│   └── ... (10-30 images)
│
├── Vishal/             ← Folder for Vishal's face images
│   ├── Vishal_1.jpg
│   ├── Vishal_2.jpg
│   ├── Vishal_3.jpg
│   └── ... (10-30 images)
│
└── Priya/              ← Folder for Priya's face images
    ├── Priya_1.jpg
    ├── Priya_2.jpg
    ├── Priya_3.jpg
    └── ... (10-30 images)
```

**Each student needs:**
- ✅ Their own folder with their name
- ✅ 10-30 face images (JPG format)
- ✅ Different angles and expressions for better accuracy

---

## 🎯 Complete Training Process

### **Step 1: Collect Face Images**

Run this command for each student:

```bash
python src/collect_faces.py --name Bhava --images 30
python src/collect_faces.py --name Vishal --images 30
python src/collect_faces.py --name Priya --images 30
```

**What happens:**
- Opens your webcam
- Press **SPACE** to capture each image
- Captures 30 images per student
- Saves to `data/students/[student_name]/`

**Or collect for all students in one session:**

```bash
python src/collect_faces.py --batch Bhava Vishal Priya
```

### **Step 2: Train the Model**

After collecting all face images:

```bash
cd src
python face_recognition.py train
```

**What happens:**
- Reads all images from `data/students/` folder
- Extracts facial features from each image
- Trains a KNN (K-Nearest Neighbors) classifier
- Saves the trained model to `models/trained_knn_model.pkl`

**Console output:**
```
=== Face Recognition Training ===
Loading training data from: data/students
  Loading images for: Bhava
    Loaded 30 images
  Loading images for: Vishal
    Loaded 30 images
  Loading images for: Priya
    Loaded 30 images
Loaded 90 training samples for 3 students
Training KNN classifier...
✓ Model trained successfully

Model trained successfully with 3 students:
  - Bhava
  - Vishal
  - Priya
```

### **Step 3: Run the System**

```bash
python main.py
```

The system now uses the trained model to recognize faces!

---

## 📊 Files Involved in Training

### **Input Files (Training Data):**
| Location | Description | Required |
|----------|-------------|----------|
| `data/students/Bhava/*.jpg` | Bhava's face images | ✅ Yes |
| `data/students/Vishal/*.jpg` | Vishal's face images | ✅ Yes |
| `data/students/Priya/*.jpg` | Priya's face images | ✅ Yes |

### **Output File (Trained Model):**
| Location | Description |
|----------|-------------|
| `models/trained_knn_model.pkl` | Trained face recognition model |

### **Scripts Used:**
| Script | Purpose |
|--------|---------|
| `src/collect_faces.py` | Collects face images from webcam |
| `src/face_recognition.py train` | Trains the model using collected images |

---

## 🔍 Check Your Training Data

To see which students are registered and how many images each has:

```bash
python src/collect_faces.py --list
```

**Output:**
```
=== Registered Students (3) ===
  - Bhava: 30 images
  - Priya: 25 images
  - Vishal: 28 images
```

---

## ⚠️ Common Training Issues

### **"No training data found"**

**Problem:** The `data/students/` folder is empty

**Solution:**
```bash
# Collect face images first
python src/collect_faces.py --name Bhava --images 30
python src/collect_faces.py --name Vishal --images 30
python src/collect_faces.py --name Priya --images 30

# Then train
cd src
python face_recognition.py train
```

### **"Model NOT found"**

**Problem:** You haven't trained the model yet

**Solution:**
```bash
cd src
python face_recognition.py train
```

### **Poor Recognition Accuracy**

**Problem:** Not enough training images or poor quality images

**Solutions:**
- ✅ Collect more images (30+ per student)
- ✅ Use good lighting
- ✅ Capture different angles (front, left, right)
- ✅ Include different expressions (smiling, neutral, talking)
- ✅ Remove glasses/hats if possible

### **Wrong Student Recognized**

**Problem:** Students look similar or insufficient training data

**Solutions:**
1. **Re-collect images** with better quality:
   ```bash
   # Delete old images
   rm -rf data/students/Bhava/*
   
   # Collect new images
   python src/collect_faces.py --name Bhava --images 50
   ```

2. **Retrain the model:**
   ```bash
   cd src
   python face_recognition.py train
   ```

---

## 🔄 Re-training the Model

### When to Re-train:

- ✅ Added a new student
- ✅ Collected more images for existing students
- ✅ Recognition accuracy is poor
- ✅ Student's appearance changed significantly

### How to Re-train:

1. **Add/update face images** in `data/students/`
2. **Run training again:**
   ```bash
   cd src
   python face_recognition.py train
   ```
3. The old model will be **overwritten** with the new one

---

## 📋 Quick Reference

### Collect Images:
```bash
python src/collect_faces.py --name "Student Name" --images 30
```

### Train Model:
```bash
cd src
python face_recognition.py train
```

### Check Registered Students:
```bash
python src/collect_faces.py --list
```

### Test Recognition:
```bash
cd src
python face_recognition.py
```
(Opens webcam to test face recognition)

### Run Full System:
```bash
python main.py
```

---

## 🎓 Technical Details

### What Gets Trained:

**Algorithm:** K-Nearest Neighbors (KNN) Classifier

**Features Used:**
- Face images are resized to 100x100 pixels
- Converted to grayscale
- Histogram equalization applied
- Flattened into a feature vector (10,000 features)
- Normalized to 0-1 range

**Model Storage:**
- Trained model saved as: `models/trained_knn_model.pkl`
- Contains KNN classifier and label encoder
- File size: ~1-5 MB (depends on number of students)

**Training Time:**
- 30 images per student, 3 students = ~5-10 seconds
- Depends on your CPU speed

---

## ✅ Training Checklist

Before running `python main.py`:

- [ ] Face images collected for all students (10-30 each)
- [ ] Images saved in `data/students/[student_name]/` folders
- [ ] Model trained (`cd src && python face_recognition.py train`)
- [ ] Model file exists at `models/trained_knn_model.pkl`
- [ ] Test recognition works (`cd src && python face_recognition.py`)

Once all checked, you're ready to run: `python main.py`

---

## 🎯 Summary

**Training Files:**
- **Input:** Images in `data/students/[student_name]/*.jpg`
- **Output:** Trained model at `models/trained_knn_model.pkl`

**Training Process:**
1. Collect faces: `python src/collect_faces.py`
2. Train model: `cd src && python face_recognition.py train`
3. Run system: `python main.py`

That's it! The model learns to recognize students from their face images! 🎓✨
