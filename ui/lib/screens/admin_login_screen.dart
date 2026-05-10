import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/auth_card.dart';
import '../widgets/tech_grid_painter.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

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
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAdminLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final textColorPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textColorSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;

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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Back
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

                            // Admin badge
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppTheme.primary.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.shield_outlined,
                                      color: AppTheme.primary,
                                      size: 14,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'Admin Access',
                                      style: TextStyle(
                                        color: AppTheme.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Header
                            Text(
                              'Admin Login',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: textColorPrimary,
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Restricted to authorized personnel only',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: textColorSecondary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Email
                            CustomTextField(
                              label: 'Admin Email',
                              hintText: 'admin@example.com',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: _validateEmail,
                            ),
                            const SizedBox(height: 20),

                            // Password label + Forgot
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Password',
                                  style: TextStyle(
                                    color: textColorPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                      context, AppRoutes.forgotPassword),
                                  child: const Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                      color: AppTheme.textLink,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            CustomTextField(
                              label: '',
                              hintText: '••••••••',
                              controller: _passwordController,
                              isPassword: true,
                              validator: _validatePassword,
                            ),
                            const SizedBox(height: 28),

                            // Login as Admin Button
                            PrimaryButton(
                              label: 'Login as Admin',
                              onPressed: _handleAdminLogin,
                              isLoading: _isLoading,
                            ),
                            const SizedBox(height: 24),

                            // Back to user login
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pushReplacementNamed(
                                      context, AppRoutes.login),
                              child: Text(
                                '← Back to User Login',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: textColorSecondary.withValues(alpha: 0.7),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
}
