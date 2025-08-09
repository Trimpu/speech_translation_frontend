import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import '../services/api_service.dart';

class AuthService {
  // Use the same dynamic base URL as ApiService
  static String get _baseUrl => ApiService.baseUrl;
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'auth_token';

  // User model
  static Map<String, dynamic>? _currentUser;
  static String? _authToken;

  // Initialize auth service
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    final token = prefs.getString(_tokenKey);
    
    if (userData != null && token != null) {
      _currentUser = jsonDecode(userData);
      _authToken = token;
    }
  }

  // Check if user is logged in
  static bool get isLoggedIn => _currentUser != null && _authToken != null;

  // Get current user
  static Map<String, dynamic>? get currentUser => _currentUser;

  // Get auth token
  static String? get authToken => _authToken;

  // Hash password
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Register new user
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      print('🔐 AuthService: Registering user: $email');
      
      final hashedPassword = _hashPassword(password);
      
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': hashedPassword,
          'name': name,
        }),
      );

      print('🔐 AuthService: Register response status: ${response.statusCode}');
      print('🔐 AuthService: Register response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'success') {
          // Store user data and token
          _currentUser = data['user'];
          _authToken = data['token'];
          
          // Save to local storage
          await _saveUserData();
          
          return {
            'success': true,
            'message': 'Registration successful!',
            'user': _currentUser,
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Registration failed',
          };
        }
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['error'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      print('🔐 AuthService: Register error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Login user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 AuthService: Logging in user: $email');
      
      final hashedPassword = _hashPassword(password);
      
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': hashedPassword,
        }),
      );

      print('🔐 AuthService: Login response status: ${response.statusCode}');
      print('🔐 AuthService: Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'success') {
          // Store user data and token
          _currentUser = data['user'];
          _authToken = data['token'];
          
          // Save to local storage
          await _saveUserData();
          
          return {
            'success': true,
            'message': 'Login successful!',
            'user': _currentUser,
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Login failed',
          };
        }
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['error'] ?? 'Invalid email or password',
        };
      }
    } catch (e) {
      print('🔐 AuthService: Login error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Logout user
  static Future<void> logout() async {
    try {
      print('🔐 AuthService: Logging out user');
      
      // Clear local data
      _currentUser = null;
      _authToken = null;
      
      // Clear from storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_tokenKey);
      
      print('🔐 AuthService: Logout successful');
    } catch (e) {
      print('🔐 AuthService: Logout error: $e');
    }
  }

  // Save user data to local storage
  static Future<void> _saveUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_currentUser != null) {
        await prefs.setString(_userKey, jsonEncode(_currentUser));
      }
      
      if (_authToken != null) {
        await prefs.setString(_tokenKey, _authToken!);
      }
      
      print('🔐 AuthService: User data saved to local storage');
    } catch (e) {
      print('🔐 AuthService: Error saving user data: $e');
    }
  }

  // Get authenticated headers for API calls
  static Map<String, String> getAuthHeaders() {
    final headers = {'Content-Type': 'application/json'};
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }

  // Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate password strength
  static Map<String, dynamic> validatePassword(String password) {
    final issues = <String>[];
    
    if (password.length < 8) {
      issues.add('Password must be at least 8 characters long');
    }
    
    if (!password.contains(RegExp(r'[A-Z]'))) {
      issues.add('Password must contain at least one uppercase letter');
    }
    
    if (!password.contains(RegExp(r'[a-z]'))) {
      issues.add('Password must contain at least one lowercase letter');
    }
    
    if (!password.contains(RegExp(r'[0-9]'))) {
      issues.add('Password must contain at least one number');
    }
    
    return {
      'isValid': issues.isEmpty,
      'issues': issues,
    };
  }
}
