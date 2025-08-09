import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _historyKey = 'translation_history';
  static const String _savedTextsKey = 'saved_texts';
  
  // Translation history item model
  static const int maxHistoryItems = 100;
  static const int maxSavedTexts = 50;

  // Get translation history
  static Future<List<Map<String, dynamic>>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);
      
      if (historyJson != null) {
        final List<dynamic> historyList = jsonDecode(historyJson);
        return historyList.cast<Map<String, dynamic>>();
      }
      
      return [];
    } catch (e) {
      print('📱 StorageService: Error getting history: $e');
      return [];
    }
  }

  // Add item to history
  static Future<void> addToHistory({
    required String originalText,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
    String? fileName,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getHistory();
      
      final newItem = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'originalText': originalText,
        'translatedText': translatedText,
        'sourceLanguage': sourceLanguage,
        'targetLanguage': targetLanguage,
        'fileName': fileName,
        'timestamp': DateTime.now().toIso8601String(),
        'date': DateTime.now().toString().split(' ')[0], // YYYY-MM-DD
      };
      
      // Add to beginning of list
      history.insert(0, newItem);
      
      // Keep only last maxHistoryItems
      if (history.length > maxHistoryItems) {
        history.removeRange(maxHistoryItems, history.length);
      }
      
      await prefs.setString(_historyKey, jsonEncode(history));
      print('📱 StorageService: Added item to history');
    } catch (e) {
      print('📱 StorageService: Error adding to history: $e');
    }
  }

  // Get saved texts
  static Future<List<Map<String, dynamic>>> getSavedTexts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString(_savedTextsKey);
      
      if (savedJson != null) {
        final List<dynamic> savedList = jsonDecode(savedJson);
        return savedList.cast<Map<String, dynamic>>();
      }
      
      return [];
    } catch (e) {
      print('📱 StorageService: Error getting saved texts: $e');
      return [];
    }
  }

  // Save text for later
  static Future<void> saveText({
    required String text,
    required String type, // 'original' or 'translated'
    required String sourceLanguage,
    required String targetLanguage,
    String? title,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTexts = await getSavedTexts();
      
      final newSavedText = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': text,
        'type': type,
        'sourceLanguage': sourceLanguage,
        'targetLanguage': targetLanguage,
        'title': title ?? '${type.capitalize()} text',
        'timestamp': DateTime.now().toIso8601String(),
        'date': DateTime.now().toString().split(' ')[0], // YYYY-MM-DD
      };
      
      // Add to beginning of list
      savedTexts.insert(0, newSavedText);
      
      // Keep only last maxSavedTexts
      if (savedTexts.length > maxSavedTexts) {
        savedTexts.removeRange(maxSavedTexts, savedTexts.length);
      }
      
      await prefs.setString(_savedTextsKey, jsonEncode(savedTexts));
      print('📱 StorageService: Saved text for later');
    } catch (e) {
      print('📱 StorageService: Error saving text: $e');
    }
  }

  // Delete history item
  static Future<void> deleteHistoryItem(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getHistory();
      
      history.removeWhere((item) => item['id'] == id);
      
      await prefs.setString(_historyKey, jsonEncode(history));
      print('📱 StorageService: Deleted history item');
    } catch (e) {
      print('📱 StorageService: Error deleting history item: $e');
    }
  }

  // Delete saved text
  static Future<void> deleteSavedText(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTexts = await getSavedTexts();
      
      savedTexts.removeWhere((item) => item['id'] == id);
      
      await prefs.setString(_savedTextsKey, jsonEncode(savedTexts));
      print('📱 StorageService: Deleted saved text');
    } catch (e) {
      print('📱 StorageService: Error deleting saved text: $e');
    }
  }

  // Clear all history
  static Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
      print('📱 StorageService: Cleared all history');
    } catch (e) {
      print('📱 StorageService: Error clearing history: $e');
    }
  }

  // Clear all saved texts
  static Future<void> clearSavedTexts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_savedTextsKey);
      print('📱 StorageService: Cleared all saved texts');
    } catch (e) {
      print('📱 StorageService: Error clearing saved texts: $e');
    }
  }

  // Search history
  static Future<List<Map<String, dynamic>>> searchHistory(String query) async {
    try {
      final history = await getHistory();
      
      if (query.isEmpty) return history;
      
      return history.where((item) {
        final originalText = item['originalText']?.toString().toLowerCase() ?? '';
        final translatedText = item['translatedText']?.toString().toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();
        
        return originalText.contains(searchQuery) || 
               translatedText.contains(searchQuery);
      }).toList();
    } catch (e) {
      print('📱 StorageService: Error searching history: $e');
      return [];
    }
  }

  // Search saved texts
  static Future<List<Map<String, dynamic>>> searchSavedTexts(String query) async {
    try {
      final savedTexts = await getSavedTexts();
      
      if (query.isEmpty) return savedTexts;
      
      return savedTexts.where((item) {
        final text = item['text']?.toString().toLowerCase() ?? '';
        final title = item['title']?.toString().toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();
        
        return text.contains(searchQuery) || title.contains(searchQuery);
      }).toList();
    } catch (e) {
      print('📱 StorageService: Error searching saved texts: $e');
      return [];
    }
  }

  // Get stats
  static Future<Map<String, int>> getStats() async {
    try {
      final history = await getHistory();
      final savedTexts = await getSavedTexts();
      
      return {
        'totalTranslations': history.length,
        'savedTexts': savedTexts.length,
        'todayTranslations': history.where((item) {
          final date = item['date'] ?? '';
          final today = DateTime.now().toString().split(' ')[0];
          return date == today;
        }).length,
      };
    } catch (e) {
      print('📱 StorageService: Error getting stats: $e');
      return {
        'totalTranslations': 0,
        'savedTexts': 0,
        'todayTranslations': 0,
      };
    }
  }
}

// Extension to capitalize strings
extension StringCapitalization on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
