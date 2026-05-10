import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/auth_card.dart';
import '../widgets/tech_grid_painter.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
       vsync: this,
       duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendLink() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        setState(() {
          _isLoading = false;
          _emailSent = true;
        });
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppTheme.darkBackgroundGradient
              : AppTheme.lightBackgroundGradient,
        ),
        child: Stack(
        children: [
          // Background Tech Grid
          Positioned.fill(
            child: CustomPaint(
              painter: TechGridPainter(
                color: AppTheme.primary.withValues(alpha: isDark ? 0.15 : 0.05),
              ),
            ),
          ),
          
          // The Premium Emerald Light Flare Orb
          Positioned(
            top: -150,
            left: MediaQuery.of(context).size.width / 2 - 180,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primary.withValues(alpha: isDark ? 0.20 : 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          FadeTransition(
            opacity: _fadeAnim,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: AuthCard(
                      child: _emailSent ? _buildSuccessState(isDark) : _buildFormState(theme, isDark),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildFormState(ThemeData theme, bool isDark) {
    final textColorPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textColorSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Back button
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: textColorSecondary,
                size: 18,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Icon
          Container(
            width: 56,
            height: 56,
            margin: const EdgeInsets.only(bottom: 20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.lock_reset_outlined,
              color: AppTheme.primary,
              size: 26,
            ),
          ),

          // Header
          Text(
            'Reset Password',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColorPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Enter your email and we'll send you a link to reset your password.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColorSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          // Email
          CustomTextField(
            label: 'Email',
            hintText: 'you@example.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
          const SizedBox(height: 28),

          // Send Reset Link
          PrimaryButton(
            label: 'Send Reset Link',
            onPressed: _handleSendLink,
            isLoading: _isLoading,
          ),
          const SizedBox(height: 24),

          // Back to login
          GestureDetector(
            onTap: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.login),
            child: const Text(
              '← Back to Login',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textLink,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(bool isDark) {
    final textColorPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textColorSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),

        // Success icon
        Container(
          width: 64,
          height: 64,
          margin: const EdgeInsets.only(bottom: 24),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Color(0xFF10B981),
            size: 32,
          ),
        ),

        Text(
          'Check your inbox',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColorPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "We've sent a password reset link to\n${_emailController.text}",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColorSecondary,
            fontSize: 14,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),

        PrimaryButton(
          label: 'Back to Login',
          onPressed: () =>
              Navigator.pushReplacementNamed(context, AppRoutes.login),
          isLoading: false,
        ),
        const SizedBox(height: 16),

        GestureDetector(
          onTap: () => setState(() => _emailSent = false),
          child: Text(
            'Resend email',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColorSecondary.withValues(alpha: 0.7),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
