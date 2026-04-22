import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero image ──────────────────────────────────────────────
            SizedBox(
              height: screenH * 0.38,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=800&h=500&fit=crop&crop=faces',
                    fit: BoxFit.cover,
                  ),
                  // Status bar overlay
                  Positioned(
                    top: 0, left: 0, right: 0,
                    child: Container(
                      height: 44,
                      color: Colors.black.withValues(alpha: 0.15),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('9:41', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                          Icon(Icons.signal_cellular_4_bar, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── White card body ──────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
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
                    child: ElevatedButton(
                      onPressed: () => Get.offAllNamed(AppRoutes.home),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text('Login', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
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
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SignupScreen()),
                              ),
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
    );
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
