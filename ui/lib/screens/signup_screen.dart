import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import '../widgets/tech_grid_painter.dart';
import '../services/api_config.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  bool _obscurePassword = true;
  bool _isLoading = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String? _errorMessage;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '1072246847119-j73e8abrtvtshr5s0qe4of26kevf5cra.apps.googleusercontent.com',
  );

  Future<void> _handleSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
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
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/user/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'confirm_password': confirmPassword,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created! Please login.')),
          );
          Navigator.pop(context);
        }
      } else {
        final error = json.decode(response.body);
        String errorMessage = 'Signup failed';
        if (error['detail'] is List) {
          errorMessage = (error['detail'] as List).join('\n');
        } else if (error['detail'] is String) {
          errorMessage = error['detail'];
        }

        if (mounted) {
          setState(() {
            _errorMessage = errorMessage;
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

  Future<void> _signUpWithGoogle() async {
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
        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/user/google-auth'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'id_token': tokenToSend}),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', data['access_token']);

          if (mounted) Navigator.pushReplacementNamed(context, '/home');
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF060E1C), Color(0xFF091524), Color(0xFF050D18)],
              ),
            ),
          ),
          // Amber top glow
          Positioned(
            top: -80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 340,
                height: 340,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0x12F5A623),
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
                  // Brand (amber dot for sign-up)
                  _buildBrandLine(),
                  // Hero
                  _buildHeroSection(),
                  // Form
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    child: Column(
                      children: [
                        _buildField(
                          label: 'Name',
                          placeholder: 'Enter your name',
                          icon: Icons.person_outline,
                          labelColor: AppColors.amber,
                          controller: _nameController,
                        ),
                        const SizedBox(height: 16),
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
                        const SizedBox(height: 16),
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password',
                        ),
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
                        const SizedBox(height: 24),
                        _buildCTAButton(onPressed: _handleSignUp),
                        const SizedBox(height: 20),
                        _buildDivider(),
                        const SizedBox(height: 20),
                        _buildSocialButtons(),
                        const SizedBox(height: 20),
                        _buildFooterLink(),
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

  Widget _buildBrandLine() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, _) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.amber.withOpacity(_pulseAnimation.value),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: AppColors.amber.withOpacity(0.5), blurRadius: 6)
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'EYE INTELLIGENCE',
              style: TextStyle(
                color: AppColors.amber,
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
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient ring
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.amber.withOpacity(0.08)),
              gradient: RadialGradient(colors: [
                AppColors.amber.withOpacity(0.05),
                Colors.transparent,
              ]),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Sign',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.5,
                      ),
                    ),
                    TextSpan(
                      text: '-Up',
                      style: TextStyle(
                        color: AppColors.amber,
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Character with yellow headphones
              SizedBox(
                width: 160,
                height: 145,
                child: _buildCharacterWithYellowHeadphones(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterWithYellowHeadphones() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Laptop (slightly angled - writing pose)
        Positioned(
          bottom: 8,
          child: Container(
            width: 115,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFF0A1825),
              borderRadius: BorderRadius.circular(6),
              border:
                  Border.all(color: AppColors.amber.withOpacity(0.2)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      width: 55,
                      height: 2,
                      color: AppColors.amber.withOpacity(0.4)),
                  const SizedBox(height: 6),
                  Container(
                      width: 80,
                      height: 1.5,
                      color: Colors.white.withOpacity(0.1)),
                  const SizedBox(height: 4),
                  Container(
                      width: 65,
                      height: 1.5,
                      color: Colors.white.withOpacity(0.08)),
                ],
              ),
            ),
          ),
        ),
        // Character
        Positioned(
          top: 8,
          child: SizedBox(
            width: 62,
            height: 82,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Head
                Container(
                  width: 38,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Color(0xFFC49A6C),
                    shape: BoxShape.circle,
                  ),
                ),
                // Hair
                Positioned(
                  top: 0,
                  child: Container(
                    width: 38,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1A1008),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(19)),
                    ),
                  ),
                ),
                // YELLOW headphones arc
                Positioned(
                  top: 2,
                  child: Container(
                    width: 46,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border(
                        top: const BorderSide(
                            color: AppColors.amber, width: 4.5),
                        left: const BorderSide(
                            color: AppColors.amber, width: 4.5),
                        right: const BorderSide(
                            color: AppColors.amber, width: 4.5),
                      ),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(23)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Pen / writing indicator
        Positioned(
          bottom: 30,
          left: 18,
          child: Transform.rotate(
            angle: -0.6,
            child: Container(
              width: 3,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.amber,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ),
        ),
        // Smart watch glow on wrist
        Positioned(
          bottom: 28,
          right: 18,
          child: Container(
            width: 10,
            height: 7,
            decoration: BoxDecoration(
              color: const Color(0xFF0A1825),
              border: Border.all(color: AppColors.teal.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(2),
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
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: placeholder,
                        hintStyle: const TextStyle(
                            color: AppColors.textMuted, fontSize: 14),
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    String label = 'Password',
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
            child: Text(
              label,
              style: const TextStyle(
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

  Widget _buildCTAButton({required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.amber, AppColors.amberDim],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.amber.withOpacity(0.35),
              blurRadius: 24,
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
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.bgDeep),
                  ),
                )
              : const Text(
                  'Create Account',
                  style: TextStyle(
                    color: AppColors.bgDeep,
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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('— or —',
              style: TextStyle(
                  color: AppColors.textMuted, fontSize: 12)),
        ),
        Expanded(child: Divider(color: AppColors.bgGlassBorder)),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialBtn('G', const Color(0xFF4285F4), "Google", onTap: _signUpWithGoogle),
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
            content: Text('Signing up with $providerName...'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.teal,
          ),
        );
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pushReplacementNamed(context, '/home');
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

  Widget _buildFooterLink() {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: RichText(
          text: const TextSpan(children: [
            TextSpan(
                text: "Already have an account? ",
                style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            TextSpan(
                text: 'Log in',
                style: TextStyle(
                    color: AppColors.teal,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }
}
