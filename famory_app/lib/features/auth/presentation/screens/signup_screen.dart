import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../settings/settings_detail_screens.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _firstnameCtrl = TextEditingController();
  final _lastnameCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _imagePicker = ImagePicker();
  late final AuthProvider _authProvider;
  String? _selectedGender;
  String? _profilePhotoPath;
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _authProvider = Get.isRegistered<AuthProvider>()
        ? Get.find<AuthProvider>()
        : Get.put(AuthProvider(), permanent: true);
  }

  @override
  void dispose() {
    _firstnameCtrl.dispose();
    _lastnameCtrl.dispose();
    _contactCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
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
            // ── Hero image (black & white family hands) ────────────────
            const _AuthHeader(
              title: 'Create Account',
              subtitle: 'Start a family space or join one with an invite.',
              icon: Icons.person_add_alt_1_rounded,
            ),

            // ── White form body ────────────────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
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
                    'Sign up',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0D0D0D),
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Create an account to create or join your Family',
                    style: TextStyle(fontSize: 13, color: AppColors.g500, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 22),

                  // First and last name fields
                  _buildLabel('First name'),
                  const SizedBox(height: 6),
                  _buildField(controller: _firstnameCtrl, hint: 'Ex: Naser'),
                  const SizedBox(height: 14),

                  _buildLabel('Last name'),
                  const SizedBox(height: 6),
                  _buildField(controller: _lastnameCtrl, hint: 'Ex: Almutairi'),
                  const SizedBox(height: 14),

                  _buildLabel('Email or phone'),
                  const SizedBox(height: 6),
                  _buildField(
                    controller: _contactCtrl,
                    hint: 'Ex: name@email.com or 0555555555',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),

                  // Password field
                  _buildLabel('Password'),
                  const SizedBox(height: 6),
                  _buildField(
                    controller: _passCtrl,
                    hint: '8-35 characters',
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

                  _buildLabel('Gender'),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _GenderChip(
                        label: 'Female',
                        selected: _selectedGender == 'Female',
                        onTap: () => setState(() => _selectedGender = 'Female'),
                      ),
                      const SizedBox(width: 8),
                      _GenderChip(
                        label: 'Male',
                        selected: _selectedGender == 'Male',
                        onTap: () => setState(() => _selectedGender = 'Male'),
                      ),
                      const SizedBox(width: 8),
                      _GenderChip(
                        label: 'Other',
                        selected: _selectedGender == 'Other',
                        onTap: () => setState(() => _selectedGender = 'Other'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _buildLabel('Profile photo optional'),
                  const SizedBox(height: 6),
                  _ProfilePhotoPicker(
                    imagePath: _profilePhotoPath,
                    onTap: _openSignupPhotoSheet,
                    onRemove: _profilePhotoPath == null ? null : () => setState(() => _profilePhotoPath = null),
                  ),
                  const SizedBox(height: 18),

                  const _DividerLabel(text: 'Or continue with'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _ThirdPartyButton(label: 'WeChat', color: AppColors.wc, onTap: _showThirdPartyMessage)),
                      const SizedBox(width: 8),
                      Expanded(child: _ThirdPartyButton(label: 'Google', color: AppColors.red, onTap: _showThirdPartyMessage)),
                      const SizedBox(width: 8),
                      Expanded(child: _ThirdPartyButton(label: 'Apple', color: AppColors.g900, onTap: _showThirdPartyMessage)),
                    ],
                  ),
                  const SizedBox(height: 22),

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
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: _agreedToTerms && !_authProvider.isLoading.value ? _signup : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          disabledBackgroundColor: AppColors.blue.withValues(alpha: 0.4),
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
                                'Signup',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                      ),
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
                              onTap: () => Get.offNamed(AppRoutes.login),
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
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.g800),
    );
  }

  Future<void> _signup() async {
    final firstname = _firstnameCtrl.text.trim();
    final lastname = _lastnameCtrl.text.trim();
    final contact = _contactCtrl.text.trim();
    final email = contact;
    final password = _passCtrl.text;
    final confirmPassword = _confirmCtrl.text;

    final validationMessage = _validateSignup(
      firstname: firstname,
      lastname: lastname,
      contact: contact,
      password: password,
      confirmPassword: confirmPassword,
      gender: _selectedGender,
    );

    if (validationMessage != null) {
      Get.snackbar('Check your details', validationMessage);
      return;
    }

    try {
      final user = await _authProvider.signup(
        firstname: firstname,
        lastname: lastname,
        email: email,
        password: password,
      );
      await _saveOptionalSignupProfile();
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
        'Signup failed',
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String? _validateSignup({
    required String firstname,
    required String lastname,
    required String contact,
    required String password,
    required String confirmPassword,
    required String? gender,
  }) {
    if (firstname.isEmpty || lastname.isEmpty || contact.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      return 'Add your first name, last name, contact, password, and confirmation.';
    }

    if (firstname.length < 3 || firstname.length > 35) {
      return 'First name must be between 3 and 35 characters.';
    }

    if (lastname.length < 3 || lastname.length > 35) {
      return 'Last name must be between 3 and 35 characters.';
    }

    if (!_isValidEmail(contact) || contact.length < 7 || contact.length > 50) {
      return 'Use an email like name@example.com. Phone signup needs backend support first.';
    }

    if (password.length < 8 || password.length > 35) {
      return 'Password must be between 8 and 35 characters.';
    }

    if (password != confirmPassword) {
      return 'The passwords you entered do not match.';
    }

    if (gender == null || gender.isEmpty) {
      return 'Choose Female, Male, or Other for gender.';
    }

    if (!_agreedToTerms) {
      return 'Please accept the terms and conditions to continue.';
    }

    return null;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  Future<void> _openSignupPhotoSheet() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(14),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.g300,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                _ImageSourceOption(
                  icon: Icons.photo_library_rounded,
                  title: 'Photos',
                  subtitle: 'Choose from your photo library',
                  onTap: () => Get.back(result: ImageSource.gallery),
                ),
                _ImageSourceOption(
                  icon: Icons.photo_camera_rounded,
                  title: 'Take picture',
                  subtitle: 'Open the camera',
                  onTap: () => Get.back(result: ImageSource.camera),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) {
      return;
    }

    final image = await _imagePicker.pickImage(source: source, imageQuality: 85);
    if (image == null) {
      return;
    }

    setState(() => _profilePhotoPath = image.path);
  }

  Future<void> _saveOptionalSignupProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final photoPath = _profilePhotoPath?.trim();
    if (photoPath != null && photoPath.isNotEmpty) {
      var savedPhotoPath = photoPath;
      try {
        final updatedUser = await _authProvider.updateProfilePhoto(File(photoPath));
        final backendPhoto = updatedUser.profilePhoto?.trim();
        if (backendPhoto != null && backendPhoto.isNotEmpty) {
          savedPhotoPath = backendPhoto;
        }
      } catch (_) {
        savedPhotoPath = photoPath;
      }
      await prefs.setString(ProfileSettingsScreen.imagePathKey, savedPhotoPath);
    }

    final gender = _selectedGender?.trim();
    if (gender != null && gender.isNotEmpty) {
      await prefs.setString('profile_gender', gender);
    }
  }

  void _showThirdPartyMessage() {
    Get.snackbar(
      'Coming soon',
      'This sign up option is in the design now. It still needs backend OAuth setup.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
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
        readOnly: readOnly,
        onTap: onTap,
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

class _GenderChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GenderChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.purpleL : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.dashboardPurple : AppColors.g200,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? AppColors.dashboardPurpleD : AppColors.g600,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfilePhotoPicker extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const _ProfilePhotoPicker({
    required this.imagePath,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final image = _imageProvider(imagePath);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.g50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.g200, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.purpleL,
                shape: BoxShape.circle,
                image: image == null ? null : DecorationImage(image: image, fit: BoxFit.cover),
              ),
              child: image == null
                  ? const Icon(Icons.add_a_photo_rounded, color: AppColors.dashboardPurple, size: 20)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    imagePath == null ? 'Add profile photo' : 'Profile photo added',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.g800),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Photos or take picture',
                    style: TextStyle(fontSize: 12, color: AppColors.g500),
                  ),
                ],
              ),
            ),
            if (onRemove != null)
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close_rounded, color: AppColors.g500, size: 20),
              )
            else
              const Icon(Icons.chevron_right_rounded, color: AppColors.g400),
          ],
        ),
      ),
    );
  }

  ImageProvider? _imageProvider(String? path) {
    final value = path?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return NetworkImage(value);
    }

    final file = File(value);
    return file.existsSync() ? FileImage(file) : null;
  }
}

class _DividerLabel extends StatelessWidget {
  final String text;

  const _DividerLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.g200)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.g500, fontWeight: FontWeight.w700)),
        ),
        const Expanded(child: Divider(color: AppColors.g200)),
      ],
    );
  }
}

class _ThirdPartyButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ThirdPartyButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.g200, width: 1.4),
        ),
        child: Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Center(
                child: Text(
                  label.substring(0, 1),
                  style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.g700)),
          ],
        ),
      ),
    );
  }
}

class _ImageSourceOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ImageSourceOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.purpleL,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: AppColors.dashboardPurple),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.g900)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.g500)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.g400),
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
