import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  late final AuthProvider _authProvider;
  bool _obscurePass = true;

  @override
  void initState() {
    super.initState();
    _authProvider = Get.isRegistered<AuthProvider>()
        ? Get.find<AuthProvider>()
        : Get.put(AuthProvider(), permanent: true);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.g50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero image ──────────────────────────────────────────────
            const _AuthHeader(
              title: 'Welcome Back',
              subtitle: 'Sign in to keep your family space moving.',
              icon: Icons.home_rounded,
            ),

            // ── White card body ──────────────────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.g200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text(
                    'Welcome!',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0D0D0D),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Email field
                  _buildField(
                    controller: _emailCtrl,
                    hint: 'Email Address',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),

                  // Password field
                  _buildField(
                    controller: _passCtrl,
                    hint: 'Password',
                    obscure: _obscurePass,
                    suffix: GestureDetector(
                      onTap: () => setState(() => _obscurePass = !_obscurePass),
                      child: Icon(
                        _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.g400,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Forgot password
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.blue),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: _authProvider.isLoading.value ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          disabledBackgroundColor: AppColors.blue.withValues(alpha: 0.5),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: _authProvider.isLoading.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Register link
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 13, color: AppColors.g500, fontFamily: 'Araboto'),
                        children: [
                          const TextSpan(text: 'Add or Join a your family? '),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () => Get.toNamed(AppRoutes.signup),
                              child: const Text(
                                'Register now',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.blue, fontFamily: 'Araboto'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.g200, thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text('Or continue with', style: TextStyle(fontSize: 12, color: AppColors.g400.withValues(alpha: 0.8), fontWeight: FontWeight.w500)),
                      ),
                      const Expanded(child: Divider(color: AppColors.g200, thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // Social icons row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialIcon(
                        color: const Color(0xFFEA4335),
                        child: const Text('G', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                        onTap: () {},
                      ),
                      const SizedBox(width: 16),
                      _buildSocialIcon(
                        color: const Color(0xFF000000),
                        child: const Icon(Icons.apple, color: Colors.white, size: 22),
                        onTap: () {},
                      ),
                      const SizedBox(width: 16),
                      _buildSocialIcon(
                        color: const Color(0xFF1877F2),
                        child: const Text('f', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                        onTap: () {},
                      ),
                      const SizedBox(width: 16),
                      _buildSocialIcon(
                        color: AppColors.wc,
                        child: const Icon(Icons.chat_bubble, color: Colors.white, size: 18),
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;

    final validationMessage = _validateLogin(email: email, password: password);
    if (validationMessage != null) {
      Get.snackbar('Check your details', validationMessage);
      return;
    }

    try {
      final user = await _authProvider.login(email: email, password: password);
      final role = (user.role ?? 'user').toLowerCase();
      if (role == 'admin') {
        Get.snackbar('Unsupported account', 'Admin accounts should use the admin flow.');
        return;
      }

      if (!mounted) {
        return;
      }

      Get.offAllNamed(AppRoutes.home);
    } catch (error) {
      Get.snackbar(
        'Login failed',
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String? _validateLogin({
    required String email,
    required String password,
  }) {
    if (email.isEmpty || password.isEmpty) {
      return 'Please enter your email and password.';
    }

    if (!_isValidEmail(email) || email.length < 7 || email.length > 40) {
      return 'Email must be valid and between 7 and 40 characters.';
    }

    if (password.length < 6 || password.length > 20) {
      return 'Password must be between 6 and 20 characters.';
    }

    return null;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.g200, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14, color: AppColors.g800),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14, color: AppColors.g400),
          suffixIcon: suffix != null ? Padding(padding: const EdgeInsets.only(right: 12), child: suffix) : null,
          suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSocialIcon({required Color color, required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Center(child: child),
      ),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _AuthHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
      decoration: BoxDecoration(
        color: AppColors.dashboardPurple,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(icon, color: AppColors.blue, size: 21),
              ),
              const Spacer(),
              const Icon(Icons.family_restroom_rounded, color: Colors.white, size: 22),
            ],
          ),
          const SizedBox(height: 28),
          Center(
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.74), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
