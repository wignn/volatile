import 'package:flutter/material.dart';
import 'package:vasvault/models/register_request.dart';
import 'package:vasvault/page/Login.dart';
import 'package:vasvault/routes.dart';
import 'package:vasvault/theme/app_colors.dart';
import 'package:vasvault/widgets/error_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vasvault/bloc/register_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  bool isObscure = true;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryLight.withValues(alpha: 0.3),
                    AppColors.primaryLight.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.2),
                    AppColors.primary.withValues(alpha: 0.0),
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
                    children: [
                      const SizedBox(height: 40),

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
                          Icons.person_add_outlined,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 32),

                      Text(
                        'Create Account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Join VasVault today',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.darkTextSecondary,
                        ),
                      ),

                      const SizedBox(height: 40),

                      _buildTextField(
                        controller: usernameController,
                        hintText: "Username",
                        prefixIcon: Icons.person_outline,
                      ),

                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: emailController,
                        hintText: "Email",
                        prefixIcon: Icons.email_outlined,
                      ),

                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: passwordController,
                        hintText: "Password",
                        prefixIcon: Icons.lock_outlined,
                        isPassword: true,
                        isObscure: isObscure,
                        onToggle: () => setState(() {
                          isObscure = !isObscure;
                        }),
                      ),

                      const SizedBox(height: 32),

                      BlocConsumer<RegisterBloc, SignupState>(
                        listener: (context, state) {
                          if (state is SignupSuccess) {
                            Navigator.pushReplacementNamed(
                              context,
                              MyRoute.home.name,
                            );
                          } else if (state is SignupFailed) {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  ErrorDialog(message: state.errorMessage),
                            );
                          }
                        },
                        builder: (context, state) {
                          return _buildPrimaryButton(
                            label: "Create Account",
                            isLoading: state is SignupLoading,
                            onPressed: () {
                              final body = RegisterRequestModel(
                                username: usernameController.text,
                                password: passwordController.text,
                                email: emailController.text,
                                name: usernameController.text,
                              );

                              context.read<RegisterBloc>().add(Signup(body));
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 48),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account?  ",
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
                                  builder: (context) => LoginPage(),
                                ),
                              );
                            },
                            child: Text(
                              "Sign In",
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
    required IconData prefixIcon,
    bool isPassword = false,
    bool isObscure = false,
    VoidCallback? onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder, width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && isObscure,
        style: TextStyle(color: AppColors.darkText, fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.darkTextSecondary,
            fontSize: 16,
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
                  onPressed: onToggle,
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
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    emailController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
}
