import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
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
            // ── Hero image (black & white family hands) ────────────────
            SizedBox(
              height: screenH * 0.32,
              width: double.infinity,
              child: ColorFiltered(
                colorFilter: const ColorFilter.matrix([
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0,      0,      0,      1, 0,
                ]),
                child: Image.network(
                  'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=800&h=400&fit=crop&crop=top',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),

            // ── White form body ────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text(
                    'Sign up',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0D0D0D),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Create an account to create or join your Family',
                    style: TextStyle(fontSize: 13, color: AppColors.g500, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 22),

                  // Name field
                  _buildLabel('Name'),
                  const SizedBox(height: 6),
                  _buildField(controller: _nameCtrl, hint: 'Your name'),
                  const SizedBox(height: 14),

                  // Email field
                  _buildLabel('Email Address'),
                  const SizedBox(height: 6),
                  _buildField(
                    controller: _emailCtrl,
                    hint: 'name@email.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),

                  // Password field
                  _buildLabel('Password'),
                  const SizedBox(height: 6),
                  _buildField(
                    controller: _passCtrl,
                    hint: 'Create a password',
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

                  // Confirm password field (no label, just the field as in design)
                  _buildField(
                    controller: _confirmCtrl,
                    hint: 'Confirm password',
                    obscure: _obscureConfirm,
                    suffix: GestureDetector(
                      onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      child: Icon(
                        _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.g400,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Terms checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 20,
                          height: 20,
                          margin: const EdgeInsets.only(top: 1),
                          decoration: BoxDecoration(
                            color: _agreedToTerms ? AppColors.blue : Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: _agreedToTerms ? AppColors.blue : AppColors.g300,
                              width: 1.5,
                            ),
                          ),
                          child: _agreedToTerms
                              ? const Icon(Icons.check, color: Colors.white, size: 13)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 12, color: AppColors.g600, fontFamily: 'Araboto', height: 1.5),
                            children: [
                              TextSpan(text: "I've read and agree with the "),
                              TextSpan(
                                text: 'Terms and Conditions',
                                style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w700),
                              ),
                              TextSpan(text: ' and the '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w700),
                              ),
                              TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Signup button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _agreedToTerms
                          ? () => Get.offAllNamed(AppRoutes.home)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        disabledBackgroundColor: AppColors.blue.withValues(alpha: 0.4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text('Signup', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Login link
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 13, color: AppColors.g500, fontFamily: 'Araboto'),
                        children: [
                          const TextSpan(text: 'Already have an account with your Family? '),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.blue,
                                  fontFamily: 'Araboto',
                                ),
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.g800),
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
          suffixIcon: suffix != null
              ? Padding(padding: const EdgeInsets.only(right: 12), child: suffix)
              : null,
          suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
