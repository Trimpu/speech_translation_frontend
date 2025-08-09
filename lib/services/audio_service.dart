import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';

class AudioService {
  static RecorderController? _recorderController;
  static bool _isRecording = false;
  static String? _currentRecordingPath;

  /// 🎤 Request microphone permission for recording
  static Future<bool> requestMicrophonePermission() async {
    try {
      print('🎤 AudioService: Requesting microphone permission...');
      
      if (kIsWeb) {
        // Web permission - audio_waveforms handles this internally
        print('🎤 AudioService: Web platform detected');
        return true; // audio_waveforms handles web permissions
      }
      
      // Mobile permission using permission_handler
      final status = await Permission.microphone.request();
      final granted = status == PermissionStatus.granted;
      
      print('🎤 AudioService: Mobile permission status: $status');
      return granted;
    } catch (e) {
      print('🎤 AudioService: Error requesting permission: $e');
      return false;
    }
  }

  /// 🎙️ Start recording audio
  static Future<String?> startRecording() async {
    try {
      print('🎤 AudioService: Starting recording...');
      
      // Check permission first
      final hasPermission = await requestMicrophonePermission();
      if (!hasPermission) {
        throw Exception('Microphone permission denied');
      }

      // Stop any existing recording
      if (_isRecording && _recorderController != null) {
        await stopRecording();
      }

      // Initialize recorder controller if not already done
      _recorderController ??= RecorderController();

      // Get recording path
      String path;
      if (kIsWeb) {
        path = 'recording_${DateTime.now().millisecondsSinceEpoch}';
      } else {
        final directory = await getTemporaryDirectory();
        path = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
      }

      // Start recording
      await _recorderController!.record(path: path);
      _isRecording = true;
      _currentRecordingPath = path;
      
      print('🎤 AudioService: Recording started at: $path');
      return path;
    } catch (e) {
      print('🎤 AudioService: Error starting recording: $e');
      _isRecording = false;
      _currentRecordingPath = null;
      rethrow;
    }
  }

  /// ⏹️ Stop recording audio
  static Future<String?> stopRecording() async {
    try {
      print('🎤 AudioService: Stopping recording...');
      
      if (!_isRecording || _recorderController == null) {
        print('🎤 AudioService: No active recording to stop');
        return null;
      }

      final path = await _recorderController!.stop();
      _isRecording = false;
      
      print('🎤 AudioService: Recording stopped. File saved at: $path');
      
      // Verify file exists on mobile
      if (!kIsWeb && path != null) {
        final file = File(path);
        if (await file.exists()) {
          final size = await file.length();
          print('🎤 AudioService: Recording file size: ${size} bytes');
        } else {
          print('🎤 AudioService: Warning - Recording file does not exist');
        }
      }
      
      _currentRecordingPath = null;
      return path;
    } catch (e) {
      print('🎤 AudioService: Error stopping recording: $e');
      _isRecording = false;
      _currentRecordingPath = null;
      rethrow;
    }
  }

  /// 📊 Check if currently recording
  static Future<bool> isRecording() async {
    try {
      final recording = _recorderController?.isRecording ?? false;
      _isRecording = recording;
      return recording;
    } catch (e) {
      print('🎤 AudioService: Error checking recording status: $e');
      return false;
    }
  }

  /// 🧹 Dispose audio service
  static Future<void> dispose() async {
    try {
      print('🎤 AudioService: Disposing...');
      if (_isRecording) {
        await stopRecording();
      }
      _recorderController?.dispose();
      _recorderController = null;
      print('🎤 AudioService: Disposed successfully');
    } catch (e) {
      print('🎤 AudioService: Error disposing: $e');
    }
  }

  /// 🗂️ Get current recording path
  static String? getCurrentRecordingPath() {
    return _currentRecordingPath;
  }
}
