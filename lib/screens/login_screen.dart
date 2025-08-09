import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/modern_widgets.dart';
import 'speech_translation_screen_new.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  
  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  // State variables
  bool _isLogin = true; // true for login, false for signup
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkExistingLogin();
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

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  void _checkExistingLogin() async {
    await AuthService.initialize();
    if (AuthService.isLoggedIn) {
      _navigateToMainApp();
    }
  }

  void _navigateToMainApp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const SpeechTranslationScreen(),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> result;
      
      if (_isLogin) {
        result = await AuthService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        result = await AuthService.register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
        );
      }

      if (result['success']) {
        _showSuccessSnackBar(result['message']);
        await Future.delayed(const Duration(milliseconds: 500));
        _navigateToMainApp();
      } else {
        _showErrorSnackBar(result['message']);
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _formKey.currentState?.reset();
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.accentCyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App Logo/Title
                        _buildHeader(),
                        const SizedBox(height: 40),

                        // Login/Signup Form
                        _buildAuthForm(),
                        const SizedBox(height: 24),

                        // Toggle Button
                        _buildToggleButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppTheme.cardGradient,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.glassBorder,
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.translate,
            size: 48,
            color: AppTheme.premiumGold,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Speech Translator',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isLogin ? 'Welcome back!' : 'Create your account',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthForm() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isLogin ? 'Sign In' : 'Sign Up',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Name field (only for signup)
              if (!_isLogin) ...[
                _buildNameField(),
                const SizedBox(height: 16),
              ],

              // Email field
              _buildEmailField(),
              const SizedBox(height: 16),

              // Password field
              _buildPasswordField(),
              const SizedBox(height: 24),

              // Submit button
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Full Name',
        hintText: 'Enter your full name',
        prefixIcon: Icon(Icons.person, color: AppTheme.accentCyan),
        filled: true,
        fillColor: AppTheme.surfaceDark.withOpacity(0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.glassBorder.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.accentCyan),
        ),
        labelStyle: TextStyle(color: AppTheme.textSecondary),
        hintStyle: TextStyle(color: AppTheme.textMuted),
      ),
      style: TextStyle(color: AppTheme.textPrimary),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your name';
        }
        if (value.trim().length < 2) {
          return 'Name must be at least 2 characters';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'Enter your email address',
        prefixIcon: Icon(Icons.email, color: AppTheme.accentCyan),
        filled: true,
        fillColor: AppTheme.surfaceDark.withOpacity(0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.glassBorder.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.accentCyan),
        ),
        labelStyle: TextStyle(color: AppTheme.textSecondary),
        hintStyle: TextStyle(color: AppTheme.textMuted),
      ),
      style: TextStyle(color: AppTheme.textPrimary),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your email';
        }
        if (!EmailValidator.validate(value.trim())) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter your password',
        prefixIcon: Icon(Icons.lock, color: AppTheme.accentCyan),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
            color: AppTheme.textMuted,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        filled: true,
        fillColor: AppTheme.surfaceDark.withOpacity(0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.glassBorder.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.accentCyan),
        ),
        labelStyle: TextStyle(color: AppTheme.textSecondary),
        hintStyle: TextStyle(color: AppTheme.textMuted),
      ),
      style: TextStyle(color: AppTheme.textPrimary),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (!_isLogin) {
          // Only validate password strength for signup
          final validation = AuthService.validatePassword(value);
          if (!validation['isValid']) {
            return validation['issues'].first;
          }
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return ModernButton(
      text: _isLogin ? 'Sign In' : 'Sign Up',
      icon: _isLogin ? Icons.login : Icons.person_add,
      onPressed: _isLoading ? null : _handleSubmit,
      isLoading: _isLoading,
    );
  }

  Widget _buildToggleButton() {
    return TextButton(
      onPressed: _toggleMode,
      child: RichText(
        text: TextSpan(
          text: _isLogin 
              ? "Don't have an account? " 
              : "Already have an account? ",
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
          children: [
            TextSpan(
              text: _isLogin ? 'Sign Up' : 'Sign In',
              style: TextStyle(
                color: AppTheme.accentCyan,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
