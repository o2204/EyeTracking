import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/admin_login_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../views/home_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String signup = '/signup';
  static const String adminLogin = '/admin-login';
  static const String forgotPassword = '/forgot-password';

  static Map<String, WidgetBuilder> get routes => {
        login: (_) => const LoginScreen(),
        home: (_) => const HomeScreen(),
        signup: (_) => const SignupScreen(),
        adminLogin: (_) => const AdminLoginScreen(),
        forgotPassword: (_) => const ForgotPasswordScreen(),
      };
}
