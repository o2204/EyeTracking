import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/admin_login_screen.dart';
import '../screens/admin_dashboard_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/splash_screen.dart';
import '../views/home_page.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/profile/screens/edit_profile_screen.dart';
import '../features/profile/screens/help_support_screen.dart';
import '../features/profile/screens/about_screen.dart';
import '../features/profile/screens/notifications_screen.dart';
import '../features/profile/screens/privacy_security_screen.dart';
import '../screens/interactive_intro_screen.dart';
import '../screens/camera_streaming_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String signup = '/signup';
  static const String adminLogin = '/admin-login';
  static const String adminDashboard = '/admin-dashboard';
  static const String forgotPassword = '/forgot-password';
  
  // Profile Module Routes
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String helpSupport = '/help-support';
  static const String about = '/about';
  static const String notifications = '/notifications';
  static const String privacySecurity = '/privacy-security';

  static const String interactiveIntro = '/interactive-intro';
  static const String cameraStreaming = '/camera-streaming';


  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashScreen(),
        interactiveIntro: (_) => const InteractiveIntroScreen(),
        login: (_) => const LoginScreen(),
        home: (_) => const HomeScreen(),
        signup: (_) => const SignupScreen(),
        adminLogin: (_) => const AdminLoginScreen(),
        adminDashboard: (_) => const AdminDashboardScreen(),
        forgotPassword: (_) => const ForgotPasswordScreen(),
        profile: (_) => const ProfileScreen(),
        editProfile: (_) => const EditProfileScreen(),
        helpSupport: (_) => const HelpSupportScreen(),
        about: (_) => const AboutScreen(),
        notifications: (_) => const NotificationsScreen(),
        privacySecurity: (_) => const PrivacySecurityScreen(),
        cameraStreaming: (_) => const CameraStreamingScreen(),
      };
}


