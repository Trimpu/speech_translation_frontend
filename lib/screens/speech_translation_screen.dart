import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import '../services/api_service.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';

class SpeechTranslationScreen extends StatefulWidget {
  const SpeechTranslationScreen({super.key});

  @override
  State<SpeechTranslationScreen> createState() => _SpeechTranslationScreenState();
}

class _SpeechTranslationScreenState extends State<SpeechTranslationScreen>
    with TickerProviderStateMixin {
  bool _isRecording = false;
  bool _isLoading = false;
  bool _isApiHealthy = false;
  String? _recordingPath;
  String? _selectedAudioPath;
  List<int>? _selectedAudioBytes;
  String? _selectedAudioFileName;
  String _selectedLanguage = 'hi';
  Map<String, String> _languages = {};
  
  // Results
  String? _transcribedText;
  String? _translatedText;
  String? _detectedLanguage;
  
  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Animation controllers
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    _initializeApp();
    _setupAnimations();
  }
  
  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }
  
  Future<void> _initializeApp() async {
    await _checkApiHealth();
    await _loadLanguages();
  }
  
  Future<void> _checkApiHealth() async {
    try {
      final isHealthy = await ApiService.checkHealth();
      setState(() {
        _isApiHealthy = isHealthy;
      });
      
      if (!isHealthy) {
        _showError('Backend server is not running on localhost:5000');
      }
    } catch (e) {
      setState(() {
        _isApiHealthy = false;
      });
      _showError('Cannot connect to backend server');
    }
  }
  
  Future<void> _loadLanguages() async {
    try {
      final response = await ApiService.getLanguages();
      setState(() {
        _languages = Map<String, String>.from(response['languages']);
      });
    } catch (e) {
      _showError('Failed to load languages: $e');
    }
  }
  
  Future<void> _startRecording() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final path = await AudioService.startRecording();
      
      setState(() {
        _isRecording = true;
        _recordingPath = path;
        _isLoading = false;
        _selectedAudioPath = null;
        _selectedAudioBytes = null;
        _selectedAudioFileName = null;
        _clearResults();
      });
      
      _pulseController.repeat(reverse: true);
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to start recording: $e');
    }
  }
  
  Future<void> _stopRecording() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final path = await AudioService.stopRecording();
      
      setState(() {
        _isRecording = false;
        _selectedAudioPath = path ?? _recordingPath;
        _selectedAudioBytes = null;
        _selectedAudioFileName = null;
        _isLoading = false;
      });
      
      _pulseController.stop();
      _pulseController.reset();
      
    } catch (e) {
      setState(() {
        _isRecording = false;
        _isLoading = false;
      });
      _pulseController.stop();
      _showError('Failed to stop recording: $e');
    }
  }
  
  Future<void> _pickAudioFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'mp4', 'mpeg', 'mpga', 'webm'],
      );
      
      if (result != null) {
        setState(() {
          if (kIsWeb) {
            // For web, use bytes
            _selectedAudioBytes = result.files.single.bytes;
            _selectedAudioFileName = result.files.single.name;
            _selectedAudioPath = null;
          } else {
            // For mobile, use path
            _selectedAudioPath = result.files.single.path;
            _selectedAudioBytes = null;
            _selectedAudioFileName = null;
          }
          _clearResults();
        });
      }
    } catch (e) {
      _showError('Failed to pick audio file: $e');
    }
  }
  
  Future<void> _playAudio() async {
    try {
      if (kIsWeb && _selectedAudioBytes != null) {
        // For web, convert List<int> to Uint8List and play from bytes
        final uint8List = Uint8List.fromList(_selectedAudioBytes!);
        await _audioPlayer.play(BytesSource(uint8List));
      } else if (_selectedAudioPath != null) {
        // For mobile, play from file path
        await _audioPlayer.play(DeviceFileSource(_selectedAudioPath!));
      }
    } catch (e) {
      _showError('Failed to play audio: $e');
    }
  }
  
  Future<void> _processAudio() async {
    if (_selectedAudioPath == null && _selectedAudioBytes == null) {
      _showError('No audio file selected');
      return;
    }
    
    if (!_isApiHealthy) {
      _showError('Backend server is not available');
      return;
    }
    
    setState(() {
      _isLoading = true;
      _clearResults();
    });
    
    try {
      print('DEBUG: Starting transcription...');
      print('DEBUG: audioPath: $_selectedAudioPath');
      print('DEBUG: audioBytes length: ${_selectedAudioBytes?.length}');
      print('DEBUG: fileName: $_selectedAudioFileName');
      print('DEBUG: targetLanguage: $_selectedLanguage');
      
      final response = await ApiService.transcribeAudio(
        audioPath: _selectedAudioPath,
        audioBytes: _selectedAudioBytes,
        fileName: _selectedAudioFileName,
        targetLanguage: _selectedLanguage,
      );
      
      print('DEBUG: Received response: $response');
      
      setState(() {
        // Use the correct field names from the backend response
        if (response['original_text'] != null && response['original_text'].toString().isNotEmpty) {
          _transcribedText = response['original_text'].toString();
        } else {
          _transcribedText = 'No transcription available';
        }
        
        if (response['translated_text'] != null && response['translated_text'].toString().isNotEmpty) {
          _translatedText = response['translated_text'].toString();
        } else {
          _translatedText = 'No translation available';
        }
        
        if (response['language_detected'] != null && response['language_detected'].toString().isNotEmpty) {
          _detectedLanguage = response['language_detected'].toString();
        } else {
          _detectedLanguage = 'Unknown';
        }
        
        _isLoading = false;
      });
      
      print('DEBUG: UI updated with results');
      print('DEBUG: transcribedText: $_transcribedText');
      print('DEBUG: translatedText: $_translatedText');
      print('DEBUG: detectedLanguage: $_detectedLanguage');
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transcription completed successfully!'),
          backgroundColor: AppTheme.accentCyan,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
    } catch (e) {
      print('DEBUG: Error occurred: $e');
      setState(() {
        _isLoading = false;
      });
      _showError('Transcription failed: $e');
    }
  }
  
  void _clearResults() {
    setState(() {
      _transcribedText = null;
      _translatedText = null;
      _detectedLanguage = null;
    });
  }
  
  void _showError(String message) {
    print('ERROR: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 10), // Longer duration for debugging
      ),
    );
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech Translation'),
        actions: [
          IconButton(
            icon: Icon(
              _isApiHealthy ? Icons.cloud_done : Icons.cloud_off,
              color: _isApiHealthy ? AppTheme.accentCyan : Colors.red.shade700,
            ),
            onPressed: _checkApiHealth,
            tooltip: _isApiHealthy ? 'API Connected' : 'API Disconnected',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            _buildStatusCard(),
            const SizedBox(height: 20),
            
            // Language Selection
            _buildLanguageSelector(),
            const SizedBox(height: 20),
            
            // Audio Recording Section
            _buildRecordingSection(),
            const SizedBox(height: 20),
            
            // File Upload Section
            _buildFileUploadSection(),
            const SizedBox(height: 20),
            
            // Process Button
            if (_selectedAudioPath != null || _selectedAudioBytes != null) _buildProcessButton(),
            const SizedBox(height: 20),
            
            // Results Section
            if (_transcribedText != null || _translatedText != null)
              _buildResultsSection(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              _isApiHealthy ? Icons.check_circle : Icons.error,
              color: _isApiHealthy ? AppTheme.accentCyan : Colors.red.shade700,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _isApiHealthy 
                    ? 'Connected to backend server' 
                    : 'Backend server unavailable',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            if (!_isApiHealthy)
              ElevatedButton(
                onPressed: _checkApiHealth,
                child: const Text('Retry'),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLanguageSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Target Language',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              decoration: const InputDecoration(
                labelText: 'Select language for translation',
                prefixIcon: Icon(Icons.language),
              ),
              items: _languages.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecordingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Record Audio',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: _isLoading 
                    ? null 
                    : (_isRecording ? _stopRecording : _startRecording),
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isRecording ? _pulseAnimation.value : 1.0,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isRecording 
                              ? Colors.red.shade700 
                              : AppTheme.primaryPurple,
                          boxShadow: [
                            BoxShadow(
                              color: (_isRecording 
                                  ? Colors.red.shade700 
                                  : AppTheme.primaryPurple).withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: _isRecording ? 10 : 5,
                            ),
                          ],
                        ),
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                _isRecording ? Icons.stop : Icons.mic,
                                size: 48,
                                color: Colors.white,
                              ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                _isRecording 
                    ? 'Recording... Tap to stop' 
                    : 'Tap to start recording',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFileUploadSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Or Upload Audio File',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickAudioFile,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Choose File'),
                  ),
                ),
                if (_selectedAudioPath != null || _selectedAudioBytes != null) ...[
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: _playAudio,
                    icon: const Icon(Icons.play_arrow),
                    tooltip: 'Play Audio',
                  ),
                ],
              ],
            ),
            if (_selectedAudioPath != null || _selectedAudioBytes != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.audiotrack, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedAudioFileName ?? 
                        (_selectedAudioPath?.split('/').last ?? 'Selected audio file'),
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedAudioPath = null;
                          _selectedAudioBytes = null;
                          _selectedAudioFileName = null;
                          _clearResults();
                        });
                      },
                      icon: const Icon(Icons.close, size: 20),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildProcessButton() {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _processAudio,
      icon: _isLoading 
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.translate),
      label: Text(_isLoading ? 'Processing...' : 'Transcribe & Translate'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
  
  Widget _buildResultsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Results',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            
            if (_detectedLanguage != null) ...[
              _buildResultItem(
                'Detected Language',
                _detectedLanguage!,
                Icons.language,
              ),
              const SizedBox(height: 16),
            ],
            
            if (_transcribedText != null) ...[
              _buildResultItem(
                'Original Text',
                _transcribedText!,
                Icons.text_fields,
              ),
              const SizedBox(height: 16),
            ],
            
            if (_translatedText != null) ...[
              _buildResultItem(
                'Translation (${_languages[_selectedLanguage] ?? _selectedLanguage})',
                _translatedText!,
                Icons.translate,
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildResultItem(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.primaryPurple),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: SelectableText(
            content,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}
