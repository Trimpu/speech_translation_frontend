# Speech Translation App - Usage Guide

## 🎉 Successfully Deployed!

Your multilingual speech translation app is now running with both frontend and backend components.

## 🔧 Current Status

### ✅ Backend (Flask API)
- **Status**: Running on `http://localhost:5000`
- **Features**: 
  - Whisper model loaded for speech recognition
  - Azure Translator API configured and tested
  - Support for multiple audio formats (MP3, WAV, M4A, etc.)

### ✅ Frontend (Flutter Web App)
- **Status**: Running on `http://localhost:3000`
- **Features**:
  - Modern responsive UI
  - Audio recording capability
  - File upload support
  - Real-time API status monitoring
  - Multi-language translation

## 🚀 How to Use

### 1. Open the App
- The Flutter web app is running at: `http://localhost:3000`
- You should see the "Speech Translation" interface

### 2. Check Connection Status
- Look for the cloud icon in the top-right corner
- ✅ Green = Backend connected
- ❌ Red = Backend disconnected

### 3. Select Target Language
- Choose your desired translation language from the dropdown
- Default: Hindi (hi)
- Available: 100+ languages supported by Azure Translator

### 4. Record or Upload Audio

#### Option A: Record Audio
1. Tap the large microphone button
2. Allow microphone permissions when prompted
3. Speak clearly into your microphone
4. Tap the stop button when finished

#### Option B: Upload Audio File
1. Click "Choose File" button
2. Select an audio file (MP3, WAV, M4A, MP4, MPEG, MPGA, WEBM)
3. Maximum file size: 25MB

### 5. Process Audio
1. Click "Transcribe & Translate" button
2. Wait for processing (usually 10-30 seconds)
3. View results in the Results section

## 📋 Expected Results

The app will display:
- **Detected Language**: Auto-detected source language
- **Original Text**: Transcribed speech in original language
- **Translation**: Text translated to your selected target language

## 🔧 Troubleshooting

### Backend Issues
- If the cloud icon shows red, restart the backend:
  ```bash
  cd ../speech_translation_backend
  python app.py
  ```

### Frontend Issues
- If the web app doesn't load, restart Flutter:
  ```bash
  flutter run -d chrome --web-hostname localhost --web-port 3000
  ```

### Permission Issues
- **Microphone**: Grant microphone access when prompted
- **File Access**: Ensure browser allows file uploads

### Audio Issues
- Ensure your microphone is working
- Test with different audio formats if upload fails
- Check file size (must be under 25MB)

## 🎯 Testing the Complete Workflow

1. **Health Check**: Verify green cloud icon
2. **Language Selection**: Choose "Spanish" (es)
3. **Record**: Record yourself saying "Hello, how are you?"
4. **Process**: Click "Transcribe & Translate"
5. **Expected Results**:
   - Detected Language: English
   - Original Text: "Hello, how are you?"
   - Translation: "Hola, ¿cómo estás?"

## 📱 Mobile Development

To run on mobile devices:

### Android
```bash
flutter run -d android
```

### iOS
```bash
flutter run -d ios
```

**Note**: Mobile development requires additional setup (Android Studio/Xcode)

## 🔍 API Endpoints (for developers)

- `GET /health` - Check backend status
- `GET /languages` - Get available languages  
- `POST /transcribe` - Upload audio for processing

## 🛠 Development Commands

### Flutter Commands
```bash
flutter run              # Run on default device
flutter build web        # Build for web
flutter test             # Run tests
flutter analyze          # Code analysis
```

### Backend Commands
```bash
python app.py            # Start Flask server
curl http://localhost:5000/health  # Test health endpoint
```

## 🎨 Customization

### UI Theme
Edit `lib/theme/app_theme.dart` to customize:
- Colors
- Fonts
- Button styles
- Card layouts

### API Configuration
Edit backend `.env` file to change:
- Azure API keys
- Supported languages
- File size limits

## ✨ Success!

Your speech translation app is fully functional with:
- ✅ Real-time speech recording
- ✅ Multi-format file upload
- ✅ Accurate speech recognition (Whisper)
- ✅ Multi-language translation (Azure)
- ✅ Beautiful responsive UI
- ✅ Real-time API monitoring

Enjoy using your multilingual speech translation app! 🌍🗣️
