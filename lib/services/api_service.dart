import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  // Dynamic base URL based on platform
  static String get baseUrl {
    if (kIsWeb) {
      // Web: Use localhost
      return 'http://localhost:5000';
    } else if (Platform.isAndroid) {
      // Android: Use your PC's IP address
      return 'http://192.168.0.4:5000';
    } else if (Platform.isIOS) {
      // iOS: Use your PC's IP address  
      return 'http://192.168.0.4:5000';
    } else {
      // Desktop: Use localhost
      return 'http://localhost:5000';
    }
  }
  
  // Get available languages
  static Future<Map<String, dynamic>> getLanguages() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/languages'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get languages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Transcribe and translate audio
  static Future<Map<String, dynamic>> transcribeAudio({
    String? audioPath,
    List<int>? audioBytes,
    String? fileName,
    required String targetLanguage,
  }) async {
    try {
      print('DEBUG API: Creating multipart request...');
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/transcribe'),
      );
      
      // Add audio file - handle both path (mobile) and bytes (web)
      if (audioBytes != null && fileName != null) {
        // Web upload using bytes
        print('DEBUG API: Adding file from bytes, length: ${audioBytes.length}, name: $fileName');
        request.files.add(
          http.MultipartFile.fromBytes(
            'audio',
            audioBytes,
            filename: fileName,
          ),
        );
      } else if (audioPath != null) {
        // Mobile upload using path
        print('DEBUG API: Adding file from path: $audioPath');
        request.files.add(
          await http.MultipartFile.fromPath('audio', audioPath),
        );
      } else {
        throw Exception('No audio file provided');
      }
      
      // Add target language
      request.fields['target_language'] = targetLanguage;
      print('DEBUG API: Target language: $targetLanguage');
      
      print('DEBUG API: Sending request to $baseUrl/transcribe...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('DEBUG API: Response status: ${response.statusCode}');
      print('DEBUG API: Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        try {
          final result = json.decode(response.body);
          print('DEBUG API: Parsed result: $result');
          
          // Validate that the expected fields are present
          if (result is Map<String, dynamic>) {
            if (!result.containsKey('original_text') || 
                !result.containsKey('translated_text') || 
                !result.containsKey('language_detected')) {
              print('DEBUG API: Missing required fields in response');
              print('DEBUG API: Available keys: ${result.keys.toList()}');
              throw Exception('Invalid response format from server');
            }
            
            // Check for null or empty values
            if (result['original_text'] == null || result['original_text'].toString().isEmpty) {
              throw Exception('Empty transcription received from server');
            }
            
            return result;
          } else {
            throw Exception('Response is not a valid JSON object');
          }
        } catch (e) {
          print('DEBUG API: JSON parsing error: $e');
          throw Exception('Failed to parse server response: $e');
        }
      } else {
        try {
          final errorData = json.decode(response.body);
          throw Exception(errorData['error'] ?? 'Transcription failed');
        } catch (e) {
          throw Exception('Server error (${response.statusCode}): ${response.body}');
        }
      }
    } catch (e) {
      print('DEBUG API: Exception occurred: $e');
      throw Exception('Network error: $e');
    }
  }
  
  // Check API health
  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Translate text without audio processing
  static Future<Map<String, dynamic>> translateText({
    required String text,
    required String targetLanguage,
    String? sourceLanguage,
  }) async {
    try {
      print('DEBUG API: Translating text...');
      print('DEBUG API: Text: ${text.substring(0, text.length > 100 ? 100 : text.length)}...');
      print('DEBUG API: Target language: $targetLanguage');
      print('DEBUG API: Source language: $sourceLanguage');

      final response = await http.post(
        Uri.parse('$baseUrl/translate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'text': text,
          'target_language': targetLanguage,
          'source_language': sourceLanguage,
        }),
      );

      print('DEBUG API: Response status: ${response.statusCode}');
      print('DEBUG API: Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final result = json.decode(response.body);
          print('DEBUG API: Parsed result: $result');

          if (result is Map<String, dynamic>) {
            if (!result.containsKey('translated_text')) {
              print('DEBUG API: Missing translated_text field in response');
              print('DEBUG API: Available keys: ${result.keys.toList()}');
              throw Exception('Invalid response format from server');
            }

            if (result['translated_text'] == null || result['translated_text'].toString().isEmpty) {
              throw Exception('Empty translation received from server');
            }

            return result;
          } else {
            throw Exception('Response is not a valid JSON object');
          }
        } catch (e) {
          print('DEBUG API: JSON parsing error: $e');
          throw Exception('Failed to parse server response: $e');
        }
      } else {
        try {
          final errorData = json.decode(response.body);
          throw Exception(errorData['error'] ?? 'Translation failed');
        } catch (e) {
          throw Exception('Server error (${response.statusCode}): ${response.body}');
        }
      }
    } catch (e) {
      print('DEBUG API: Exception occurred: $e');
      throw Exception('Network error: $e');
    }
  }
}
