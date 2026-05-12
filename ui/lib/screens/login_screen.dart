import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import '../widgets/tech_grid_painter.dart';
import 'signup_screen.dart';
import '../services/api_config.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _obscurePassword = true;
  bool _isLoading = false;
  int _adminTapCount = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;
  final _authService = AuthService();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '1072246847119-j73e8abrtvtshr5s0qe4of26kevf5cra.apps.googleusercontent.com',
  );

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill all fields';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.userLogin(email, password);

      if (result['success']) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = result['message'] ?? 'Login failed';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Connection error: $e';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _googleSignIn.signIn();
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final auth = await user.authentication;
      final String tokenToSend = auth.idToken ?? auth.accessToken ?? '';

      if (tokenToSend.isNotEmpty) {
        // We can either add googleAuth to AuthService or keep it here.
        // For consistency, I'll keep it here but ensure is_admin=false is set.
        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/user/google-auth'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'id_token': tokenToSend}),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          
          // Securely store token
          const storage = FlutterSecureStorage();
          await storage.write(key: 'access_token', value: data['access_token']);
          await storage.write(key: 'is_admin', value: 'false');

          if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.home);
        } else {
          final error = json.decode(response.body);
          String errorMessage = 'Google authentication failed';
          if (error['detail'] is String) {
            errorMessage = error['detail'];
          }
          
          if (mounted) {
            setState(() {
              _errorMessage = errorMessage;
            });
          }
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Google Sign-In Error: $error';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF060E1C), Color(0xFF091524), Color(0xFF050D18)],
              ),
            ),
          ),
          // Teal top glow
          Positioned(
            top: -80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 340,
                height: 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.teal.withOpacity(0.07),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Brand
                  _buildBrandLine(color: AppColors.teal),
                  // Hero section
                  _buildHeroSection(),
                  // Form
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildField(
                          label: 'Email',
                          placeholder: 'email@gmail.com',
                          icon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          labelColor: AppColors.teal,
                          controller: _emailController,
                        ),
                        const SizedBox(height: 16),
                        _buildPasswordField(controller: _passwordController),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        _buildForgotPassword(),
                        const SizedBox(height: 20),
                        _buildCTAButton(
                          label: 'Login',
                          color: AppColors.teal,
                          textColor: AppColors.bgDeep,
                          glowColor: AppColors.teal,
                          onPressed: _handleLogin,
                        ),
                        const SizedBox(height: 20),
                        _buildDivider(),
                        const SizedBox(height: 20),
                        _buildSocialButtons(),
                        const SizedBox(height: 24),
                        _buildFooterLink(
                          text: "Don't have an account? ",
                          linkText: 'Sign up',
                          linkColor: AppColors.teal,
                          onTap: () => Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => const SignupScreen(),
                              transitionsBuilder: (_, anim, __, child) =>
                                  FadeTransition(opacity: anim, child: child),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandLine({required Color color}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 0),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, _) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color.withOpacity(_pulseAnimation.value),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'EYE INTELLIGENCE',
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return SizedBox(
      height: 230,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulse ring
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, _) => Container(
              width: 180 * _pulseAnimation.value,
              height: 180 * _pulseAnimation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.teal.withOpacity(0.15 * _pulseAnimation.value),
                ),
              ),
            ),
          ),
          // Title + character
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Log',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.5,
                      ),
                    ),
                    TextSpan(
                      text: 'In',
                      style: TextStyle(
                        color: AppColors.teal,
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Character illustration placeholder
              GestureDetector(
                onTap: () {
                  _adminTapCount++;
                  if (_adminTapCount >= 3) {
                    _adminTapCount = 0;
                    Navigator.pushNamed(context, AppRoutes.adminLogin);
                  }
                },
                child: Container(
                  width: 160,
                  height: 155,
                  alignment: Alignment.center,
                  child: _buildCharacterSVG(headphonesColor: Colors.white70),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterSVG({required Color headphonesColor}) {
    // Stylized character icon using Flutter widgets
    return Stack(
      alignment: Alignment.center,
      children: [
        // Laptop
        Positioned(
          bottom: 10,
          child: Container(
            width: 110,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF0A1825),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.teal.withOpacity(0.2)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 60, height: 2, color: AppColors.teal.withOpacity(0.4)),
                  const SizedBox(height: 6),
                  Container(width: 80, height: 1.5, color: Colors.white.withOpacity(0.1)),
                  const SizedBox(height: 4),
                  Container(width: 70, height: 1.5, color: Colors.white.withOpacity(0.08)),
                ],
              ),
            ),
          ),
        ),
        // Person silhouette
        Positioned(
          top: 10,
          child: Container(
            width: 60,
            height: 80,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Head
                Container(
                  width: 38,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC49A6C),
                    shape: BoxShape.circle,
                  ),
                ),
                // Hair
                Positioned(
                  top: 0,
                  child: Container(
                    width: 38,
                    height: 22,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1008),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                    ),
                  ),
                ),
                // Headphones arc
                Positioned(
                  top: 2,
                  child: Container(
                    width: 44,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: headphonesColor, width: 4),
                        left: BorderSide(color: headphonesColor, width: 4),
                        right: BorderSide(color: headphonesColor, width: 4),
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required String label,
    required String placeholder,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required Color labelColor,
    required TextEditingController controller,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xB30E1C32),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.bgGlassBorder),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(icon, color: AppColors.textMuted, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      keyboardType: keyboardType,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: placeholder,
                        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -9,
          left: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            color: AppColors.bgDeep,
            child: Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({required TextEditingController controller}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xB30E1C32),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.bgGlassBorder),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Icon(Icons.lock_outline_rounded,
                      color: AppColors.textMuted, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      obscureText: _obscurePassword,
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Enter your password',
                        hintStyle: TextStyle(
                            color: AppColors.textMuted, fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textMuted,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -9,
          left: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            color: AppColors.bgDeep,
            child: const Text(
              'Password',
              style: TextStyle(
                color: AppColors.teal,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.forgotPassword);
        },
        child: Text(
          'Forgot Password?',
          style: TextStyle(
            color: AppColors.teal,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCTAButton({
    required String label,
    required Color color,
    required Color textColor,
    required Color glowColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: glowColor.withOpacity(0.35),
              blurRadius: 24,
              spreadRadius: 0,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
          child: _isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.bgGlassBorder)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('— or —',
              style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12)),
        ),
        Expanded(child: Divider(color: AppColors.bgGlassBorder)),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialBtn('G', const Color(0xFF4285F4), "Google", onTap: _signInWithGoogle),
        const SizedBox(width: 16),
        _socialBtn('f', const Color(0xFF1877F2), "Facebook"),
        const SizedBox(width: 16),
        _socialBtn('', Colors.white, "Apple", icon: Icons.apple),
      ],
    );
  }

  Widget _socialBtn(String letter, Color color, String providerName, {IconData? icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logging in with $providerName...'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.teal,
          ),
        );
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.home);
        });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xB30E1C32),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.bgGlassBorder),
            ),
            child: Center(
              child: icon != null
                  ? Icon(icon, color: Colors.white, size: 24)
                  : Text(
                      letter,
                      style: TextStyle(
                          color: color,
                          fontSize: 18,
                          fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterLink({
    required String text,
    required String linkText,
    required Color linkColor,
    required VoidCallback onTap,
  }) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: RichText(
          text: TextSpan(children: [
            TextSpan(
                text: text,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 13)),
            TextSpan(
                text: linkText,
                style: TextStyle(
                    color: linkColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }
}
