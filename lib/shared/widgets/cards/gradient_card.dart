import 'package:flutter/material.dart';
import '../../../theme/app_shadows.dart';

class GradientCard extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final EdgeInsets? padding;
  final double borderRadius;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final List<BoxShadow>? shadows;

  const GradientCard({
    super.key,
    required this.child,
    required this.gradient,
    this.padding,
    this.borderRadius = 20,
    this.onTap,
    this.width,
    this.height,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: shadows ?? AppShadows.cardShadowMedium,
        ),
        child: child,
      ),
    );
  }
}