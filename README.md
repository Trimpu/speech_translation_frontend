# Speech Translation Flutter App

A multilingual speech-to-text and translation mobile application built with Flutter.

## Features

- **Real-time Audio Recording**: Record audio directly from your device
- **File Upload Support**: Upload audio files in various formats (MP3, WAV, M4A, MP4, MPEG, MPGA, WEBM)
- **Speech Recognition**: Powered by OpenAI Whisper for accurate transcription
- **Multi-language Translation**: Translate to 100+ languages using Azure Translator
- **Beautiful UI**: Modern, responsive design with smooth animations
- **Backend Integration**: Seamlessly connects to Flask backend API

## Backend Requirements

This app requires the backend server to be running. The backend provides:
- Speech-to-text transcription using Whisper
- Translation services using Azure Translator API
- Support for multiple audio formats

### Starting the Backend

Make sure the Flask backend is running on `localhost:5000`:

```bash
cd ../speech_translation_backend
python app.py
```

## Installation

1. **Prerequisites**:
   - Flutter SDK (3.8.1 or higher)
   - Android Studio / Xcode for mobile development
   - Backend server running

2. **Clone and Setup**:
   ```bash
   git clone <repository>
   cd speech_translation_frontend
   flutter pub get
   ```

3. **Run the App**:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── screens/
│   └── speech_translation_screen.dart  # Main UI screen
├── services/
│   ├── api_service.dart         # Backend API integration
│   └── audio_service.dart       # Audio recording service
└── theme/
    └── app_theme.dart           # App styling and theme
```

## Dependencies

- **record**: Audio recording functionality
- **file_picker**: File selection capabilities
- **http**: HTTP client for API calls
- **path_provider**: File system access
- **permission_handler**: Device permissions
- **audioplayers**: Audio playback
- **flutter_svg**: SVG icon support

## Permissions

### Android
- `RECORD_AUDIO`: For microphone access
- `WRITE_EXTERNAL_STORAGE`: For saving recordings
- `READ_EXTERNAL_STORAGE`: For file access
- `INTERNET`: For API communication

### iOS
- `NSMicrophoneUsageDescription`: Microphone access
- `NSDocumentsFolderUsageDescription`: File access
- `NSAppTransportSecurity`: HTTP communication

## Usage

1. **Select Target Language**: Choose the language you want to translate to
2. **Record Audio**: 
   - Tap the microphone button to start recording
   - Tap again to stop recording
3. **Upload File**: Alternatively, upload an audio file using the file picker
4. **Process**: Tap "Transcribe & Translate" to process the audio
5. **View Results**: See the original transcription and translation

## API Integration

The app communicates with the backend using these endpoints:

- `GET /health`: Check backend status
- `GET /languages`: Get available languages
- `POST /transcribe`: Upload audio for processing

## Troubleshooting

### Backend Connection Issues
- Ensure the Flask backend is running on port 5000
- Check that your device/emulator can reach localhost:5000
- For physical devices, use your computer's IP address instead of localhost

### Permission Issues
- Grant microphone permissions when prompted
- For Android, ensure storage permissions are granted
- Check app settings if permissions were denied

### Audio Recording Issues
- Test with a simple recording first
- Ensure microphone is not being used by other apps
- Check device audio settings

## Development

### Adding New Languages
Languages are fetched from the backend. To add support for new languages, update the backend configuration.

### Customizing UI
Modify `lib/theme/app_theme.dart` to change colors, fonts, and styling.

### Testing
```bash
flutter test
flutter run --profile  # For performance testing
```

## Building for Production

### Android
```bash
flutter build apk --release
flutter build appbundle --release  # For Play Store
```

### iOS
```bash
flutter build ios --release
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
