import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vasvault/bloc/login_bloc.dart';
import 'package:vasvault/models/login_request.dart';
import 'package:vasvault/page/Register.dart';
import 'package:vasvault/routes.dart';
import 'package:vasvault/theme/app_colors.dart';
import 'package:vasvault/utils/session_meneger.dart';
import 'package:vasvault/widgets/error_dialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isObscure = true;
  final sessionManager = SessionManager();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    checkLoginSession();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _fadeController.forward();
  }

  void redirectToHomePage() {
    Navigator.pushReplacementNamed(context, MyRoute.home.name);
  }

  void checkLoginSession() async {
    final accessToken = await sessionManager.getAccessToken();
    if (accessToken.isNotEmpty) {
      redirectToHomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with dark gradient matching home theme
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.darkBackground,
                  AppColors.darkSurface,
                  AppColors.darkSurfaceLight,
                ],
              ),
            ),
          ),

          // Decorative circles
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.3),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryLight.withValues(alpha: 0.2),
                    AppColors.primaryLight.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),

                      // App Logo/Icon
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.cloud_outlined,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Title
                      Text(
                        'VasVault',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Secure Cloud Storage',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.darkTextSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Email field
                      _buildTextField(
                        controller: emailController,
                        hintText: 'Email',
                        textKey: const Key('Email'),
                        prefixIcon: Icons.email_outlined,
                      ),

                      const SizedBox(height: 16),

                      // Password field
                      _buildTextField(
                        controller: passwordController,
                        hintText: 'Password',
                        textKey: const Key('Password'),
                        prefixIcon: Icons.lock_outlined,
                        isPassword: true,
                        isObscure: isObscure,
                        onToggleObscure: () {
                          setState(() {
                            isObscure = !isObscure;
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Handle forgot password
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Login button with BLoC
                      BlocConsumer<LoginBloc, LoginState>(
                        listener: (context, state) {
                          if (state is LoginSuccess) {
                            Navigator.pushReplacementNamed(
                              context,
                              MyRoute.home.name,
                            );
                          } else if (state is LoginFailed) {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  ErrorDialog(message: state.errorMessage),
                            );
                          }
                        },
                        builder: (context, state) {
                          return _buildPrimaryButton(
                            label: 'Sign In',
                            isLoading: state is LoginLoading,
                            onPressed: () {
                              _attemptLogin(context);
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 48),

                      // Sign up section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an account?  ',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.darkTextSecondary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegisterPage(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required Key textKey,
    required IconData prefixIcon,
    bool isPassword = false,
    bool isObscure = false,
    VoidCallback? onToggleObscure,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder, width: 1),
      ),
      child: TextField(
        key: textKey,
        controller: controller,
        obscureText: isPassword && isObscure,
        style: TextStyle(
          color: AppColors.darkText,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.darkTextSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: AppColors.darkTextSecondary,
            size: 22,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  onPressed: onToggleObscure,
                  icon: Icon(
                    isObscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.darkTextSecondary,
                    size: 22,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('LoginButton'),
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _attemptLogin(BuildContext context) {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      final msg = email.isEmpty && password.isEmpty
          ? 'Email dan password wajib diisi'
          : email.isEmpty
          ? 'Email wajib diisi'
          : 'Password wajib diisi';
      showDialog(
        context: context,
        builder: (context) => ErrorDialog(message: msg),
      );
      return;
    }

    final requestBody = LoginRequestModel(email: email, password: password);
    context.read<LoginBloc>().add(Login(requestBody));
  }
}
