import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';

// ────────────────────────────────────────
// Admin Colors (Specific to this design)
// ────────────────────────────────────────
class AdminColors {
  static const bgDeep = Color(0xFF030B14);
  static const bgDark = Color(0xFF060F1C);
  static const bgMid = Color(0xFF0B1A2E);
  static const bgCard = Color(0xCC0B1A2E);
  static const teal = Color(0xFF00E5B0);
  static const tealDim = Color(0xFF00C498);
  static const tealGlow = Color(0x2E00E5B0);
  static const tealBg = Color(0x1200E5B0);
  static const amber = Color(0xFFF5A623);
  static const red = Color(0xFFFF4D6A);
  static const blue = Color(0xFF3B8EEA);
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFF7A8FA8);
  static const textMuted = Color(0xFF3D5068);
  static const glass = Color(0x0AFFFFFF);
  static const glassBorder = Color(0x14FFFFFF);
  static const glassBorderHover = Color(0x4D00E5B0);
}

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;
  final _emailController = TextEditingController(text: 'admin@eyeintelligence.io');
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authService.adminLogin(email, password);

      if (result['success']) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Login failed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildLabel(String text, {bool isAmber = false}) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: isAmber ? AdminColors.amber : AdminColors.teal,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      style: GoogleFonts.dmSans(fontSize: 14, color: AdminColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.dmSans(color: AdminColors.textMuted),
        prefixIcon: Icon(icon, color: AdminColors.textMuted, size: 17),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AdminColors.textMuted,
                  size: 17,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
        filled: true,
        fillColor: AdminColors.bgMid.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AdminColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AdminColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AdminColors.glassBorderHover),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildStatPill(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AdminColors.glass,
        border: Border.all(color: AdminColors.glassBorder),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 6)],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$value $label',
            style: GoogleFonts.dmSans(fontSize: 11, color: AdminColors.textSecondary),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.bgDeep,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            colors: [AdminColors.teal, AdminColors.tealDim],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AdminColors.teal.withOpacity(0.3),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.layers, color: AdminColors.bgDeep, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'EYE INTELLIGENCE',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          color: AdminColors.teal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  Text(
                    'Admin Login',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Secure access to the Eye Intelligence control panel',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(fontSize: 13, color: AdminColors.textSecondary),
                  ),
                  const SizedBox(height: 36),
                  _buildLabel('Admin Email'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _emailController,
                    hint: 'admin@eyeintelligence.io',
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Password', isAmber: true),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _passwordController,
                    hint: '••••••••••••',
                    icon: Icons.lock_outlined,
                    isPassword: true,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _rememberMe = !_rememberMe),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: _rememberMe ? AdminColors.teal : AdminColors.glass,
                                border: Border.all(
                                  color: _rememberMe ? AdminColors.teal : AdminColors.glassBorder,
                                ),
                              ),
                              child: _rememberMe
                                  ? const Icon(Icons.check, size: 10, color: AdminColors.bgDeep)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Keep me signed in',
                              style: GoogleFonts.dmSans(fontSize: 12, color: AdminColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context, AppRoutes.forgotPassword,
                          arguments: {'isAdmin': true}
                        ),
                        child: Text(
                          'Forgot password?',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: AdminColors.teal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminColors.teal,
                        foregroundColor: AdminColors.bgDeep,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                        elevation: 8,
                        shadowColor: AdminColors.teal.withOpacity(0.4),
                      ),
                      child: _isLoading 
                        ? const SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(strokeWidth: 2, color: AdminColors.bgDeep)
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.login, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Sign in to Dashboard',
                                style: GoogleFonts.dmSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shield, size: 12, color: AdminColors.teal),
                      const SizedBox(width: 6),
                      Text(
                        '256-bit SSL encrypted · Admin access only',
                        style: GoogleFonts.dmSans(fontSize: 11, color: AdminColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatPill('247', 'devices', AdminColors.teal),
                      const SizedBox(width: 8),
                      _buildStatPill('12', 'rooms', AdminColors.amber),
                      const SizedBox(width: 8),
                      _buildStatPill('99.8%', 'uptime', AdminColors.blue),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
