import 'package:flutter/material.dart';

class FeatureCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const FeatureCard({
    super.key,
    required this.child,
    this.color,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: gradient == null ? (color ?? Colors.white) : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }
}
