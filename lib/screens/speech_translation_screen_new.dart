import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/animated_record_button.dart';
import '../widgets/modern_widgets.dart';
import '../widgets/sidebar_menu.dart';
import '../widgets/selectable_text_card.dart';
import 'login_screen.dart';
import 'dart:ui';

class SpeechTranslationScreen extends StatefulWidget {
  const SpeechTranslationScreen({super.key});

  @override
  State<SpeechTranslationScreen> createState() => _SpeechTranslationScreenState();
}

class _SpeechTranslationScreenState extends State<SpeechTranslationScreen>
    with TickerProviderStateMixin {
  
  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // State variables
  bool _isRecording = false;
  bool _isProcessing = false;
  bool _isRetranslating = false;
  bool _showSidebar = false;
  String _selectedLanguage = 'en';
  String _transcriptionResult = '';
  String _translationResult = '';
  String _detectedLanguage = '';
  List<Map<String, String>> _languages = [];
  
  // File upload state
  bool _hasUploadedFile = false;
  String _uploadedFileName = '';
  String? _uploadedFilePath;
  List<int>? _uploadedFileBytes;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadLanguages();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: AppTheme.normalAnimation,
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: AppTheme.slowAnimation,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start entrance animations
    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _loadLanguages() async {
    try {
      final languagesMap = await ApiService.getLanguages();
      final List<Map<String, String>> languagesList = [];
      
      // Convert the languages map to the expected format
      if (languagesMap['languages'] is Map) {
        final Map<String, dynamic> languages = languagesMap['languages'];
        languages.forEach((code, name) {
          languagesList.add({
            'code': code,
            'name': name.toString(),
            'flag': _getFlagForLanguage(code),
          });
        });
      }
      
      setState(() {
        _languages = languagesList;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load languages: $e');
    }
  }

  String _getFlagForLanguage(String code) {
    const Map<String, String> flags = {
      'en': '🇺🇸',
      'es': '🇪🇸',
      'fr': '🇫🇷',
      'de': '🇩🇪',
      'it': '🇮🇹',
      'pt': '🇵🇹',
      'ru': '🇷🇺',
      'ja': '🇯🇵',
      'ko': '🇰🇷',
      'zh': '🇨🇳',
      'hi': '🇮🇳',
      'ar': '🇸🇦',
      'tr': '🇹🇷',
      'nl': '🇳🇱',
      'sv': '🇸🇪',
      'no': '🇳🇴',
      'da': '🇩🇰',
      'fi': '🇫🇮',
      'pl': '🇵🇱',
      'cs': '🇨🇿',
    };
    return flags[code] ?? '🌍';
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.accentCyan,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.premiumGold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Audio recording with audio_waveforms package
  Future<void> _startRecording() async {
    try {
      print('📱 Screen: Starting recording...');
      
      // Show user guidance for web microphone permission
      if (kIsWeb) {
        _showInfoSnackBar('Please allow microphone access when prompted by your browser');
      }
      
      // First, explicitly request microphone permission
      print('📱 Screen: Requesting microphone permission...');
      final hasPermission = await AudioService.requestMicrophonePermission();
      
      if (!hasPermission) {
        throw Exception('Microphone permission denied. Please allow microphone access and try again.');
      }
      
      print('📱 Screen: Permission granted, calling AudioService.startRecording()...');
      await AudioService.startRecording();
      
      print('📱 Screen: Recording started, updating UI...');
      setState(() {
        _isRecording = true;
      });
      
      _showSuccessSnackBar('Recording started successfully!');
      print('📱 Screen: UI updated and success message shown');
    } catch (e) {
      print('📱 Screen ERROR: $e');
      String errorMessage = 'Failed to start recording: $e';
      
      // Provide more specific guidance for common issues
      if (e.toString().contains('permission denied') || e.toString().contains('denied by browser')) {
        errorMessage = 'Microphone permission denied. Please:\n'
                     '1. Refresh the page\n'
                     '2. Click the microphone icon in your browser\'s address bar\n'
                     '3. Select "Allow" when prompted for microphone access\n'
                     '4. Try clicking the record button again';
      } else if (e.toString().contains('not available')) {
        errorMessage = 'Microphone not available. Please check that:\n'
                     '1. Your device has a microphone\n'
                     '2. No other app is using the microphone\n'
                     '3. Your browser supports audio recording';
      }
      
      _showErrorSnackBar(errorMessage);
    }
  }

  Future<void> _stopRecording() async {
    try {
      final audioPath = await AudioService.stopRecording();
      setState(() {
        _isRecording = false;
      });
      
      if (audioPath != null) {
        // For web recording, we need to handle the recorded file differently
        if (kIsWeb) {
          // Web recording creates a blob, we need to handle it as bytes
          // For now, we'll try to process with the path and let the API service handle it
          await _processAudio(audioPath, fileName: 'recording.webm');
        } else {
          // Mobile recording uses file path normally
          await _processAudio(audioPath);
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to stop recording: $e');
      setState(() {
        _isRecording = false;
      });
    }
  }

  Future<void> _pickAndProcessFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'mp4', 'mpeg', 'mpga', 'webm', 'ogg', 'flac', 'aac'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        setState(() {
          _hasUploadedFile = true;
          _uploadedFileName = file.name;
          
          // Store file data for later processing
          if (kIsWeb) {
            _uploadedFileBytes = file.bytes;
            _uploadedFilePath = null;
          } else {
            _uploadedFilePath = file.path;
            _uploadedFileBytes = null;
          }
          
          // Clear previous results
          _transcriptionResult = '';
          _translationResult = '';
          _detectedLanguage = '';
        });
        
        _showSuccessSnackBar('File "${file.name}" uploaded successfully! Click GO to process.');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick file: $e');
    }
  }

  void _cancelUpload() {
    setState(() {
      _hasUploadedFile = false;
      _uploadedFileName = '';
      _uploadedFilePath = null;
      _uploadedFileBytes = null;
      _transcriptionResult = '';
      _translationResult = '';
      _detectedLanguage = '';
    });
    _showSuccessSnackBar('Upload cancelled');
  }

  Future<void> _processUploadedFile() async {
    if (!_hasUploadedFile) return;
    
    await _processAudio(
      _uploadedFilePath,
      bytes: _uploadedFileBytes,
      fileName: _uploadedFileName,
    );
  }

  Future<void> _processAudio(String? filePath, {List<int>? bytes, String? fileName}) async {
    setState(() {
      _isProcessing = true;
      _transcriptionResult = '';
      _translationResult = '';
      _detectedLanguage = '';
    });

    try {
      final result = await ApiService.transcribeAudio(
        audioPath: filePath,
        audioBytes: bytes,
        fileName: fileName ?? (bytes != null ? 'audio_file.wav' : null),
        targetLanguage: _selectedLanguage,
      );

      setState(() {
        _transcriptionResult = result['original_text'] ?? '';
        _translationResult = result['translated_text'] ?? '';
        _detectedLanguage = result['language_detected'] ?? '';
      });

      print('📱 UI State Updated:');
      print('📱 _transcriptionResult: "$_transcriptionResult"');
      print('📱 _translationResult: "$_translationResult"');
      print('📱 _detectedLanguage: "$_detectedLanguage"');

      // Add to history
      await _addToHistory();

      _showSuccessSnackBar('Audio processed successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to process audio: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _retranslateText() async {
    if (_transcriptionResult.isEmpty) {
      _showErrorSnackBar('No text to retranslate. Please record or upload audio first.');
      return;
    }

    setState(() {
      _isRetranslating = true;
    });

    try {
      final result = await ApiService.translateText(
        text: _transcriptionResult,
        targetLanguage: _selectedLanguage,
        sourceLanguage: _detectedLanguage,
      );

      setState(() {
        _translationResult = result['translated_text'] ?? '';
      });

      // Add to history
      await _addToHistory();

      _showSuccessSnackBar('Text retranslated successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to retranslate: $e');
    } finally {
      setState(() {
        _isRetranslating = false;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await AuthService.logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  Future<void> _addToHistory() async {
    if (_transcriptionResult.isNotEmpty && _translationResult.isNotEmpty) {
      try {
        await StorageService.addToHistory(
          originalText: _transcriptionResult,
          translatedText: _translationResult,
          sourceLanguage: _detectedLanguage.isNotEmpty ? _detectedLanguage : 'auto',
          targetLanguage: _selectedLanguage,
          fileName: _hasUploadedFile ? _uploadedFileName : null,
        );
        print('📱 Added translation to history');
      } catch (e) {
        print('📱 Error adding to history: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Voice Translator',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    fontSize: 18,
                  ),
                ),
                if (AuthService.currentUser != null)
                  Text(
                    'Welcome, ${AuthService.currentUser!['name'] ?? 'User'}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                setState(() {
                  _showSidebar = true;
                });
              },
              tooltip: 'Menu',
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _logout,
                tooltip: 'Logout',
              ),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(20),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // Status Card
                            _buildStatusCard(),
                            const SizedBox(height: 20),

                            // Language Selector
                            if (_languages.isNotEmpty) ...[
                              _buildLanguageSelector(),
                              const SizedBox(height: 30),
                            ],

                            // Hero Record Zone
                            _buildRecordZone(),
                            const SizedBox(height: 30),

                            // File Upload Section
                            _buildFileUploadSection(),
                            const SizedBox(height: 20),

                            // File Preview Section (when file is uploaded)
                            if (_hasUploadedFile)
                              _buildFilePreviewSection(),
                            if (_hasUploadedFile)
                              const SizedBox(height: 20),

                            // Results Section
                            if (_transcriptionResult.isNotEmpty || _translationResult.isNotEmpty || _isProcessing) ...[
                              _buildResultsSection(),
                              // Debug info
                              Container(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  'Debug: trans="${_transcriptionResult}", translated="${_translationResult}", processing=$_isProcessing',
                                  style: TextStyle(color: Colors.white54, fontSize: 10),
                                ),
                              ),
                            ],
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // Sidebar overlay
        if (_showSidebar) ...[
          // Dark overlay
          GestureDetector(
            onTap: () {
              setState(() {
                _showSidebar = false;
              });
            },
            child: Container(
              color: Colors.black.withOpacity(0.5),
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          
          // Sidebar menu
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: SidebarMenu(
              onClose: () {
                setState(() {
                  _showSidebar = false;
                });
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusCard() {
    String statusText;
    IconData statusIcon;
    Color statusColor;

    if (_isRecording) {
      statusText = 'Recording in progress...';
      statusIcon = Icons.radio_button_checked;
      statusColor = AppTheme.neonCyan;
    } else if (_isProcessing) {
      statusText = 'Processing audio...';
      statusIcon = Icons.settings_voice;
      statusColor = AppTheme.premiumGold;
    } else {
      statusText = 'Ready to record or upload';
      statusIcon = Icons.mic_none;
      statusColor = AppTheme.accentCyan;
    }

    return AnimatedGlassCard(
      isActive: _isRecording || _isProcessing,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_detectedLanguage.isNotEmpty)
                  Text(
                    'Detected: $_detectedLanguage',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.translate,
                color: AppTheme.accentCyan,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Text(
                'Translate to',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ModernLanguageSelector(
                  selectedLanguage: _selectedLanguage,
                  languages: _languages,
                  onLanguageChanged: (value) {
                    setState(() {
                      _selectedLanguage = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Retranslate Button
              Expanded(
                flex: 2,
                child: _buildRetranslateButton(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRetranslateButton() {
    // Determine what action to take
    final bool hasUploadedFile = _hasUploadedFile && _transcriptionResult.isEmpty;
    final bool canRetranslate = _transcriptionResult.isNotEmpty && !_isRetranslating && !_isProcessing;
    final bool canGo = hasUploadedFile || canRetranslate;
    
    // Determine button text and icon
    String buttonText;
    IconData buttonIcon;
    VoidCallback? onTap;
    
    if (hasUploadedFile) {
      buttonText = 'GO';
      buttonIcon = Icons.play_arrow;
      onTap = _processUploadedFile;
    } else if (canRetranslate) {
      buttonText = 'GO';
      buttonIcon = Icons.refresh;
      onTap = _retranslateText;
    } else {
      buttonText = 'GO';
      buttonIcon = Icons.play_arrow;
      onTap = null;
    }
    
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: canGo ? AppTheme.cardGradient : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: canGo ? AppTheme.glassBorder : AppTheme.textMuted,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isRetranslating || _isProcessing)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.textPrimary,
                      ),
                    ),
                  )
                else
                  Icon(
                    buttonIcon,
                    color: canGo ? AppTheme.textPrimary : AppTheme.textMuted,
                    size: 18,
                  ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      color: canGo ? AppTheme.textPrimary : AppTheme.textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordZone() {
    return GlassCard(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Text(
            'Voice Recording',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 40),
          
          // Animated Record Button
          AnimatedRecordButton(
            isRecording: _isRecording,
            onPressed: _isRecording ? _stopRecording : _startRecording,
          ),
          
          const SizedBox(height: 30),
          
          // Waveform Animation
          WaveformWidget(
            isActive: _isRecording,
            height: 60,
          ),
          
          const SizedBox(height: 20),
          
          Text(
            _isRecording 
                ? 'Tap to stop recording'
                : 'Tap to start recording',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePreviewSection() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.file_present,
                  color: AppTheme.premiumGold,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Uploaded File',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // File Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.glassBorder.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getFileIcon(_uploadedFileName),
                    color: AppTheme.accentCyan,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _uploadedFileName,
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ready to process',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Cancel Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _cancelUpload,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.close,
                          color: AppTheme.textMuted,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'mp3':
      case 'wav':
      case 'm4a':
      case 'aac':
      case 'ogg':
      case 'flac':
        return Icons.audiotrack;
      case 'mp4':
      case 'mpeg':
      case 'webm':
        return Icons.videocam;
      default:
        return Icons.insert_drive_file;
    }
  }

  Widget _buildFileUploadSection() {
    return GlassCard(
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.upload_file,
                color: AppTheme.premiumGold,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Text(
                'Upload Audio File',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ModernActionButton(
            text: 'Choose File',
            icon: Icons.folder_open,
            onPressed: _pickAndProcessFile,
            isSecondary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    return Column(
      children: [
        // Original Text Card
        SelectableTextCard(
          text: _transcriptionResult,
          title: 'Original Text${_detectedLanguage.isNotEmpty ? ' (${_detectedLanguage})' : ''}',
          type: 'original',
          sourceLanguage: _detectedLanguage.isNotEmpty ? _detectedLanguage : 'auto',
          targetLanguage: _selectedLanguage,
          icon: Icons.mic,
          accentColor: AppTheme.accentCyan,
        ),
        
        const SizedBox(height: 20),
        
        // Translation Text Card
        SelectableTextCard(
          text: _translationResult,
          title: 'Translation${_languages.isNotEmpty ? ' (${_languages.firstWhere((lang) => lang['code'] == _selectedLanguage, orElse: () => {'name': _selectedLanguage})['name']})' : ''}',
          type: 'translated',
          sourceLanguage: _detectedLanguage.isNotEmpty ? _detectedLanguage : 'auto',
          targetLanguage: _selectedLanguage,
          icon: Icons.translate,
          accentColor: AppTheme.premiumGold,
        ),
      ],
    );
  }
}
