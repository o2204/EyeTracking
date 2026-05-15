import 'package:flutter/material.dart';
import 'dart:async';
import '../routes/app_routes.dart';
import '../theme/app_theme.dart';

class InteractiveIntroScreen extends StatefulWidget {
  const InteractiveIntroScreen({super.key});

  @override
  State<InteractiveIntroScreen> createState() => _InteractiveIntroScreenState();
}

class _InteractiveIntroScreenState extends State<InteractiveIntroScreen> {
  final int _dotCount = 9;
  final Set<int> _interactedDots = {};
  bool _isTransitioning = false;

  void _handleInteraction(int index) {
    if (_isTransitioning || _interactedDots.contains(index)) return;
    
    setState(() {
      _interactedDots.add(index);
    });

    if (_interactedDots.length == _dotCount) {
      setState(() {
        _isTransitioning = true;
      });
      
      // Short delay to let the final dot animation play before navigating
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppTheme.darkBackgroundGradient
              : AppTheme.lightBackgroundGradient,
        ),
        child: Center(
          child: SizedBox(
            width: 150,
            height: 150,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 30,
                mainAxisSpacing: 30,
              ),
              itemCount: _dotCount,
              itemBuilder: (context, index) {
                final isInteracted = _interactedDots.contains(index);
                
                return MouseRegion(
                  onEnter: (_) => _handleInteraction(index),
                  child: GestureDetector(
                    onTap: () => _handleInteraction(index),
                    child: AnimatedScale(
                      scale: isInteracted ? 1.5 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      child: AnimatedOpacity(
                        opacity: isInteracted ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: isInteracted
                                ? [
                                    BoxShadow(
                                      color: AppTheme.primary.withValues(alpha: 0.8),
                                      blurRadius: 15,
                                      spreadRadius: 5,
                                    )
                                  ]
                                : [
                                    BoxShadow(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      blurRadius: 4,
                                    )
                                  ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
