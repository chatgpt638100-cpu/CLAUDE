# Quick Start Guide

Get the Smart Classroom Monitoring System running in 5 minutes!

## 🚀 Quick Setup

### Step 1: Install Dependencies (2 minutes)
```bash
pip install -r requirements.txt
```

### Step 2: Collect Student Faces (2-3 minutes per student)
```bash
cd src
python collect_faces.py --name "Student Name" --images 30
```

Follow the on-screen instructions:
- Position your face in the frame
- Press SPACE to capture images
- Try different angles

### Step 3: Train the Model (30 seconds)
```bash
python face_recognition.py train
```

### Step 4: Run the System! (immediate)
```bash
cd ..
python main.py
```

## 🎮 Controls While Running

| Key | Action |
|-----|--------|
| `q` | Quit |
| `a` | Mark attendance |
| `r` | Generate report |
| `s` | Show statistics |
| `v` | Verification mode |
| `SPACE` | Pause/Resume |

## 📋 What Happens Next?

1. **Camera starts** - You'll see live video
2. **Faces detected** - Green boxes around detected faces
3. **Recognition active** - Names appear above faces
4. **Behavior monitored** - Sleeping/talking detected automatically
5. **Alerts generated** - Violations logged in real-time

## 📁 Where to Find Results?

- **Attendance**: `data/attendance_logs/YYYY-MM-DD.json`
- **Behaviors**: `data/behavior_logs/YYYY-MM-DD.json`
- **Alerts**: `data/alerts/YYYY-MM-DD.json`
- **Reports**: `data/reports/report_YYYY-MM-DD.json`

## ⚙️ Quick Configuration

Edit `config/config.yaml` to change:
- Recognition confidence threshold
- Behavior detection sensitivity
- Alert thresholds
- Email notifications

## 🆘 Common Issues

### Camera not working?
```bash
# Try different camera index
python main.py --source 1
```

### Model not found?
Make sure you ran the training step (Step 3)

### Low FPS?
- Close other applications
- Reduce video resolution
- Use `--no-phone` flag to disable phone detection

## 🎯 Next Steps

1. **Add more students**: Repeat Step 2 for each student
2. **Configure alerts**: Edit `config/config.yaml`
3. **Review data**: Check the `data/` folders for logs
4. **Generate reports**: Press `r` during monitoring

## 💡 Tips for Best Results

1. **Good lighting** - Ensure classroom is well-lit
2. **Camera position** - Mount camera to capture all students
3. **Multiple angles** - Collect face data from various angles
4. **Regular updates** - Retrain model when adding new students
5. **Test thoroughly** - Run demo modes before actual deployment

## 📚 Need More Help?

See the full README.md for:
- Detailed documentation
- Advanced configuration
- Troubleshooting guide
- API reference

---

Happy monitoring! 🎓
