import 'package:flutter/material.dart';
import '../theme.dart';

enum AvatarSize { small, medium, large }

class CustomAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final AvatarSize size;

  const CustomAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = AvatarSize.medium,
  });

  double get _size {
    switch (size) {
      case AvatarSize.small:
        return 32;
      case AvatarSize.medium:
        return 40;
      case AvatarSize.large:
        return 64;
    }
  }

  double get _fontSize {
    switch (size) {
      case AvatarSize.small:
        return 12;
      case AvatarSize.medium:
        return 14;
      case AvatarSize.large:
        return 20;
    }
  }

  String get _initials {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryBlue, AppColors.accentOrange],
        ),
      ),
      child: imageUrl != null
          ? ClipOval(
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildInitials(),
              ),
            )
          : _buildInitials(),
    );
  }

  Widget _buildInitials() {
    return Center(
      child: Text(
        _initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: _fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
