import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/family_service.dart';

class CreateFamilyInviteScreen extends StatefulWidget {
  const CreateFamilyInviteScreen({super.key});

  @override
  State<CreateFamilyInviteScreen> createState() => _CreateFamilyInviteScreenState();
}

class _CreateFamilyInviteScreenState extends State<CreateFamilyInviteScreen> {
  static const _galleryChannel = MethodChannel('one_famory/gallery');
  final _qrKey = GlobalKey();
  Future<String>? _inviteCodeFuture;
  bool _showQr = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _inviteCodeFuture = _loadInviteCode();
  }

  @override
  Widget build(BuildContext context) {
    final family = FamilyService();
    final args = (Get.arguments as Map?) ?? {};
    final familyName = args['familyName']?.toString() ?? family.familyName ?? 'Your Family';
    final inviteCodeFuture = _inviteCodeFuture ??= _loadInviteCode();

    return Scaffold(
      backgroundColor: AppColors.g50,
      body: SafeArea(
        child: FutureBuilder<String>(
          future: inviteCodeFuture,
          builder: (context, snapshot) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  _Header(familyName: familyName),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                    child: snapshot.connectionState == ConnectionState.waiting
                        ? const _InviteLoading()
                        : snapshot.hasError
                            ? _InviteError(
                                message: snapshot.error.toString().replaceFirst('Exception: ', ''),
                                onRetry: () {
                                  setState(() {
                                    _inviteCodeFuture = _loadInviteCode();
                                  });
                                },
                              )
                            : _InviteContent(
                                familyName: familyName,
                                inviteCode: snapshot.data!,
                                showQr: _showQr,
                                isSaving: _isSaving,
                                qrKey: _qrKey,
                                onCopy: () => _copyInviteCode(context, snapshot.data!),
                                onToggleQr: () => setState(() => _showQr = !_showQr),
                                onSaveQr: () => _saveQrCode(context, snapshot.data!),
                              ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<String> _loadInviteCode() {
    return FamilyService().requireFamilyCode();
  }

  Future<void> _copyInviteCode(BuildContext context, String inviteCode) async {
    await Clipboard.setData(ClipboardData(text: inviteCode));
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Family code copied: $inviteCode')),
    );
  }

  Future<void> _saveQrCode(BuildContext context, String inviteCode) async {
    setState(() => _isSaving = true);
    try {
      final boundary = _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw const FileSystemException('QR code is not ready yet.');
      }

      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData?.buffer.asUint8List();
      if (bytes == null) {
        throw const FileSystemException('Could not generate QR image.');
      }

      final fileName = 'famory_invite_${inviteCode.replaceAll(RegExp(r'[^A-Za-z0-9]'), '')}.png';
      final savedPath = await _saveImageToPhotos(fileName, bytes);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('QR code saved to Photos: $savedPath')),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save QR code: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<String> _saveImageToPhotos(String fileName, Uint8List bytes) async {
    if (Platform.isAndroid) {
      final path = await _galleryChannel.invokeMethod<String>(
        'savePngToGallery',
        {
          'fileName': fileName,
          'bytes': bytes,
        },
      );
      return path ?? 'Pictures/Famory/$fileName';
    }

    final file = File('${Directory.systemTemp.path}${Platform.pathSeparator}$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  }
}

class _InviteContent extends StatelessWidget {
  final String familyName;
  final String inviteCode;
  final bool showQr;
  final bool isSaving;
  final GlobalKey qrKey;
  final VoidCallback onCopy;
  final VoidCallback onToggleQr;
  final VoidCallback onSaveQr;

  const _InviteContent({
    required this.familyName,
    required this.inviteCode,
    required this.showQr,
    required this.isSaving,
    required this.qrKey,
    required this.onCopy,
    required this.onToggleQr,
    required this.onSaveQr,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Column(
            children: [
              Text(
                'Invite Your Family',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.g900),
              ),
              SizedBox(height: 4),
              Text(
                'Copy the real backend family code or show the QR code.',
                style: TextStyle(fontSize: 12, color: AppColors.g500),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _FamilyCodeCard(
          familyName: familyName,
          inviteCode: inviteCode,
          onCopy: onCopy,
        ),
        const SizedBox(height: 12),
        _InviteCard(
          icon: Icons.qr_code_rounded,
          iconColor: const Color(0xFFFF8C42),
          iconBg: const Color(0xFFFFE6D5),
          title: showQr ? 'Hide QR Code' : 'Show QR Code',
          subtitle: showQr
              ? 'The QR code is visible below and ready to save.'
              : 'Show a shareable code card for this family.',
          buttonLabel: showQr ? 'Hide' : 'Show',
          onTap: onToggleQr,
        ),
        if (showQr) ...[
          const SizedBox(height: 12),
          Center(
            child: RepaintBoundary(
              key: qrKey,
              child: _QrShareCard(
                familyName: familyName,
                inviteCode: inviteCode,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _InviteCard(
            icon: Icons.image_outlined,
            iconColor: const Color(0xFF4CB4EC),
            iconBg: const Color(0xFFEAF6FC),
            title: 'Save QR Code',
            subtitle: 'Save the visible QR card as an image.',
            buttonLabel: isSaving ? 'Saving' : 'Save',
            onTap: isSaving ? null : onSaveQr,
          ),
        ],
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => Get.offAllNamed(AppRoutes.home),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: const Text('Done'),
          ),
        ),
      ],
    );
  }
}

class _InviteLoading extends StatelessWidget {
  const _InviteLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _inviteCardDecoration(),
      child: const Column(
        children: [
          CircularProgressIndicator(color: AppColors.blue),
          SizedBox(height: 14),
          Text(
            'Getting real family code...',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.g700),
          ),
        ],
      ),
    );
  }
}

class _InviteError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _InviteError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _inviteCardDecoration(),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.red, size: 34),
          const SizedBox(height: 10),
          const Text(
            'No real invite code yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.g900),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.g500),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _inviteCardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(22),
    border: Border.all(color: AppColors.g200),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 18,
        offset: const Offset(0, 6),
      ),
    ],
  );
}

class _Header extends StatelessWidget {
  final String familyName;

  const _Header({required this.familyName});

  @override
  Widget build(BuildContext context) {
    final displayName = FamilyService().ownerName ?? 'Name';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      decoration: const BoxDecoration(
        color: AppColors.dashboardPurple,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _TopIcon(
                icon: Icons.arrow_back_rounded,
                onTap: () {
                  if (Get.key.currentState?.canPop() ?? false) {
                    Get.back();
                  } else {
                    Get.offAllNamed(AppRoutes.home);
                  }
                },
              ),
              const SizedBox(width: 10),
              const _Avatar(),
              const Spacer(),
              const _TopIcon(icon: Icons.qr_code_2_rounded),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            'Invite to $familyName',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'Good Morning $displayName',
            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.76), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _FamilyCodeCard extends StatelessWidget {
  final String familyName;
  final String inviteCode;
  final VoidCallback onCopy;

  const _FamilyCodeCard({
    required this.familyName,
    required this.inviteCode,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.g200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            familyName,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.g500),
          ),
          const SizedBox(height: 10),
          const Text(
            'Family Code',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.g500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  inviteCode,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.g900, letterSpacing: 1.4),
                ),
              ),
              ElevatedButton.icon(
                onPressed: onCopy,
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('Copy'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QrShareCard extends StatelessWidget {
  final String familyName;
  final String inviteCode;

  const _QrShareCard({
    required this.familyName,
    required this.inviteCode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.g200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            familyName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.g900),
          ),
          const SizedBox(height: 14),
          _RealQrCode(data: inviteCode),
          const SizedBox(height: 14),
          const Text(
            'Join with family code',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.g500),
          ),
          const SizedBox(height: 4),
          Text(
            inviteCode,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.g900, letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }
}

class _RealQrCode extends StatelessWidget {
  final String data;

  const _RealQrCode({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 164,
      height: 164,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.g50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: QrImageView(
        data: data,
        version: QrVersions.auto,
        gapless: false,
        backgroundColor: AppColors.g50,
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: AppColors.g900,
        ),
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: AppColors.g900,
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: const Icon(Icons.person, color: Color(0xFF95BBFF), size: 20),
    );
  }
}

class _TopIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _TopIcon({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 34,
        height: 34,
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class _InviteCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback? onTap;

  const _InviteCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.g200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.g900)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.g500, height: 1.3)),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 104,
                    height: 34,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(buttonLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
