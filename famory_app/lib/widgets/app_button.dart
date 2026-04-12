import 'package:flutter/material.dart';
import '../theme.dart';

/// Reusable Button Component - Primary UI Element
/// Supports primary, secondary, and text variants
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final Widget? icon;
  final bool isLoading;
  final bool isExpanded;
  final double? height;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color textColor;
    BorderSide? border;

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = AppColors.primaryBlue;
        textColor = Colors.white;
        break;
      case AppButtonVariant.secondary:
        backgroundColor = AppColors.softBlueBg;
        textColor = AppColors.deepBlue;
        break;
      case AppButtonVariant.text:
        backgroundColor = Colors.transparent;
        textColor = AppColors.primaryBlue;
        break;
      case AppButtonVariant.outline:
        backgroundColor = Colors.transparent;
        textColor = AppColors.primaryBlue;
        border = const BorderSide(color: AppColors.primaryBlue, width: 1.5);
        break;
      case AppButtonVariant.danger:
        backgroundColor = AppColors.error;
        textColor = Colors.white;
        break;
    }

    Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          )
        else ...[
          if (icon != null) ...[
            icon!,
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(
            text,
            style: theme.textTheme.labelLarge?.copyWith(color: textColor),
          ),
        ],
      ],
    );

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          height: height ?? 48,
          padding: EdgeInsets.symmetric(
            horizontal: isExpanded ? AppSpacing.lg : AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: border != null ? Border.fromBorderSide(border) : null,
          ),
          child: content,
        ),
      ),
    );
  }
}

enum AppButtonVariant {
  primary,
  secondary,
  text,
  outline,
  danger,
}
