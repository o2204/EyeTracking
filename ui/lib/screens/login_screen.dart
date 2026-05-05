import 'package:flutter/material.dart';
import '../main.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/auth_card.dart';
import '../widgets/mascot_character.dart';

class TechGridPainter extends CustomPainter {
  final Color color;
  TechGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paintLarge = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final paintSmall = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    const double spacing = 35.0;

    for (double i = 0; i < size.width; i += spacing) {
      for (double j = 0; j < size.height; j += spacing) {
        canvas.drawCircle(Offset(i, j), 1.5, paintLarge);
        canvas.drawCircle(Offset(i + spacing / 2, j + spacing / 2), 0.6, paintSmall);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false; // drives mascot state

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

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.pushReplacementNamed(context, AppRoutes.home);
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
            // Background Tech Grid (green dots)
            Positioned.fill(
              child: CustomPaint(
                painter: TechGridPainter(
                  color: AppTheme.primary.withValues(alpha: isDark ? 0.25 : 0.06),
                ),
              ),
            ),

            // Emerald Glow Orb
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

            // Main layout: top bar + content
            SafeArea(
              child: Column(
                children: [
                  // ── Top bar with Dark/Light Toggle ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ValueListenableBuilder<ThemeMode>(
                          valueListenable: themeModeNotifier,
                          builder: (context, mode, _) {
                            final isDarkNow = mode == ThemeMode.dark;
                            return GestureDetector(
                              onTap: () {
                                themeModeNotifier.value = isDarkNow
                                    ? ThemeMode.light
                                    : ThemeMode.dark;
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppTheme.cardBackgroundDark
                                      : AppTheme.cardBackgroundLight,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.primary.withValues(alpha: 0.4),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primary.withValues(alpha: 0.2),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isDarkNow
                                      ? Icons.light_mode_outlined
                                      : Icons.dark_mode_outlined,
                                  color: AppTheme.primary,
                                  size: 20,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // ── Login Form ──
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420), // Standard width for vertical layout
                            child: AuthCard(
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // ── Mascot at the top (Prominent & Visible) ──
                                    Center(
                                      child: Transform.scale(
                                        scale: 1.2, // Make it more "باين"
                                        child: MascotCharacter(
                                          isPasswordVisible: _isPasswordVisible,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    
                                    Text(
                                      'Welcome back',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: textColorPrimary,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Sign in to your account',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: textColorSecondary,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 36),
                                    
                                    // ── Traditional Vertical Fields Column ──
                                    CustomTextField(
                                      label: 'Email',
                                      hintText: 'you@example.com',
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: _validateEmail,
                                    ),
                                    const SizedBox(height: 24),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
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
                                                  fontSize: 12,
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
                                          onVisibilityChanged: (isVisible) {
                                            setState(() => _isPasswordVisible = isVisible);
                                          },
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 36),
                                    PrimaryButton(
                                      label: 'Sign In',
                                      onPressed: _handleSignIn,
                                      isLoading: _isLoading,
                                    ),
                                    const SizedBox(height: 28),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Don't have an account? ",
                                          style: TextStyle(
                                              color: textColorSecondary, fontSize: 14),
                                        ),
                                        GestureDetector(
                                          onTap: () => Navigator.pushNamed(
                                              context, AppRoutes.signup),
                                          child: const Text(
                                            'Sign up',
                                            style: TextStyle(
                                              color: AppTheme.textLink,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    Center(
                                      child: GestureDetector(
                                        onTap: () => Navigator.pushNamed(
                                            context, AppRoutes.adminLogin),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 250),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: AppTheme.primary.withValues(alpha: 0.25),
                                            ),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.admin_panel_settings_outlined,
                                                size: 14,
                                                color: textColorSecondary,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Admin Login',
                                                style: TextStyle(
                                                  color: textColorSecondary,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
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
          ],
        ),
      ),
    );
  }
}
