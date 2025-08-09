import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 🌐 Modern Language Selector with Glassmorphic Design
class ModernLanguageSelector extends StatelessWidget {
  final String selectedLanguage;
  final List<Map<String, String>> languages;
  final ValueChanged<String> onLanguageChanged;

  const ModernLanguageSelector({
    Key? key,
    required this.selectedLanguage,
    required this.languages,
    required this.onLanguageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppTheme.glassBorder,
          width: 1,
        ),
        boxShadow: AppTheme.glassShadow,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedLanguage,
          onChanged: (String? newValue) {
            if (newValue != null) {
              onLanguageChanged(newValue);
            }
          },
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppTheme.textPrimary,
          ),
          dropdownColor: AppTheme.surfaceDark,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          items: languages.map<DropdownMenuItem<String>>((language) {
            return DropdownMenuItem<String>(
              value: language['code'],
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    language['flag'] ?? '🌍',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      language['name'] ?? 'Unknown',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// 📄 Results Display Card with Modern Styling
class ResultsCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color iconColor;
  final bool isLoading;

  const ResultsCard({
    Key? key,
    required this.title,
    required this.content,
    required this.icon,
    this.iconColor = AppTheme.accentCyan,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.glassBorder,
          width: 1,
        ),
        boxShadow: AppTheme.glassShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const _LoadingShimmer()
          else
            SelectableText(
              content.isEmpty ? 'No content available' : content,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 15,
                height: 1.5,
              ),
            ),
        ],
      ),
    );
  }
}

/// ✨ Loading Shimmer Effect
class _LoadingShimmer extends StatefulWidget {
  const _LoadingShimmer();

  @override
  State<_LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<_LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          children: List.generate(3, (index) {
            return Container(
              margin: EdgeInsets.only(bottom: index < 2 ? 8 : 0),
              height: 16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment(-1.0 + _animation.value, 0.0),
                  end: Alignment(1.0 + _animation.value, 0.0),
                  colors: [
                    AppTheme.textMuted.withOpacity(0.1),
                    AppTheme.textSecondary.withOpacity(0.3),
                    AppTheme.textMuted.withOpacity(0.1),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/// 🎮 Action Button with Modern Styling
class ModernActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;

  const ModernActionButton({
    Key? key,
    required this.text,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: isSecondary ? null : AppTheme.recordButtonGradient,
        borderRadius: BorderRadius.circular(16),
        border: isSecondary
            ? Border.all(
                color: AppTheme.glassBorder,
                width: 1,
              )
            : null,
        boxShadow: isSecondary ? null : AppTheme.glassShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.textPrimary,
                      ),
                    ),
                  )
                else
                  Icon(
                    icon,
                    color: AppTheme.textPrimary,
                    size: 20,
                  ),
                const SizedBox(width: 12),
                Text(
                  text,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 🚀 Modern Button with Loading State
class ModernButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;

  const ModernButton({
    Key? key,
    required this.text,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null && !isLoading;
    
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: isEnabled && !isSecondary ? AppTheme.cardGradient : null,
        color: isSecondary ? AppTheme.surfaceDark.withOpacity(0.6) : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEnabled ? AppTheme.glassBorder : AppTheme.textMuted,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.textPrimary,
                      ),
                    ),
                  )
                else if (icon != null)
                  Icon(
                    icon,
                    color: isEnabled ? AppTheme.textPrimary : AppTheme.textMuted,
                    size: 20,
                  ),
                
                if ((icon != null || isLoading) && text.isNotEmpty)
                  const SizedBox(width: 12),
                
                if (text.isNotEmpty)
                  Text(
                    text,
                    style: TextStyle(
                      color: isEnabled ? AppTheme.textPrimary : AppTheme.textMuted,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
