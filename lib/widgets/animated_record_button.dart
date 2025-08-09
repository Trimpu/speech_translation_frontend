import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

/// 🎙️ Animated Record Button with Waveform
class AnimatedRecordButton extends StatefulWidget {
  final bool isRecording;
  final VoidCallback onPressed;
  final double size;

  const AnimatedRecordButton({
    Key? key,
    required this.isRecording,
    required this.onPressed,
    this.size = 120,
  }) : super(key: key);

  @override
  State<AnimatedRecordButton> createState() => _AnimatedRecordButtonState();
}

class _AnimatedRecordButtonState extends State<AnimatedRecordButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late AnimationController _rotationController;
  
  late Animation<double> _pulseAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
  }

  @override
  void didUpdateWidget(AnimatedRecordButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording != oldWidget.isRecording) {
      if (widget.isRecording) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
  }

  void _startAnimations() {
    _pulseController.repeat(reverse: true);
    _rippleController.repeat();
    _rotationController.repeat();
  }

  void _stopAnimations() {
    _pulseController.stop();
    _rippleController.stop();
    _rotationController.stop();
    _pulseController.reset();
    _rippleController.reset();
    _rotationController.reset();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: Container(
        width: widget.size * 2,
        height: widget.size * 2,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ripple Effects
            if (widget.isRecording) ...[
              AnimatedBuilder(
                animation: _rippleAnimation,
                builder: (context, child) {
                  return Container(
                    width: widget.size * 2 * _rippleAnimation.value,
                    height: widget.size * 2 * _rippleAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.neonCyan.withOpacity(
                          1.0 - _rippleAnimation.value,
                        ),
                        width: 2,
                      ),
                    ),
                  );
                },
              ),
              AnimatedBuilder(
                animation: _rippleAnimation,
                builder: (context, child) {
                  final delayedValue = (_rippleAnimation.value - 0.3).clamp(0.0, 1.0);
                  return Container(
                    width: widget.size * 1.5 * delayedValue,
                    height: widget.size * 1.5 * delayedValue,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.premiumGold.withOpacity(
                          1.0 - delayedValue,
                        ),
                        width: 3,
                      ),
                    ),
                  );
                },
              ),
            ],

            // Outer Ring with Rotation
            AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Container(
                    width: widget.size * 1.4,
                    height: widget.size * 1.4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: widget.isRecording
                          ? AppTheme.activeGradient
                          : AppTheme.recordButtonGradient,
                      boxShadow: [
                        BoxShadow(
                          color: widget.isRecording
                              ? AppTheme.neonCyan.withOpacity(0.4)
                              : AppTheme.primaryPurple.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.surfaceDark,
                      ),
                    ),
                  ),
                );
              },
            ),

            // Main Button
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.isRecording ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: widget.isRecording
                          ? AppTheme.activeGradient
                          : AppTheme.recordButtonGradient,
                      boxShadow: AppTheme.glassShadow,
                    ),
                    child: Icon(
                      widget.isRecording ? Icons.stop : Icons.mic,
                      size: widget.size * 0.4,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),

            // Inner Glow
            if (widget.isRecording)
              Container(
                width: widget.size * 0.8,
                height: widget.size * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 🌊 Waveform Visualization Widget
class WaveformWidget extends StatefulWidget {
  final bool isActive;
  final double height;
  final int barCount;

  const WaveformWidget({
    Key? key,
    required this.isActive,
    this.height = 80,
    this.barCount = 20,
  }) : super(key: key);

  @override
  State<WaveformWidget> createState() => _WaveformWidgetState();
}

class _WaveformWidgetState extends State<WaveformWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.barCount,
      (index) => AnimationController(
        duration: Duration(
          milliseconds: 300 + (index * 50) % 800,
        ),
        vsync: this,
      ),
    );

    _animations = _controllers.map(
      (controller) => Tween<double>(
        begin: 0.1,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      )),
    ).toList();

    if (widget.isActive) {
      _startWaveform();
    }
  }

  void _startWaveform() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted && widget.isActive) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  void _stopWaveform() {
    for (final controller in _controllers) {
      controller.stop();
      controller.reset();
    }
  }

  @override
  void didUpdateWidget(WaveformWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _startWaveform();
      } else {
        _stopWaveform();
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          widget.barCount,
          (index) => AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Container(
                width: 4,
                height: widget.height * _animations[index].value,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: widget.isActive
                        ? [
                            AppTheme.neonCyan,
                            AppTheme.premiumGold,
                          ]
                        : [
                            AppTheme.textMuted,
                            AppTheme.textSecondary,
                          ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
