import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// Reusable Cyber-Medical translucent glowing card container
class CyberCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? borderColor;
  final Color? backgroundColor;
  final double borderRadius;
  final VoidCallback? onTap;

  const CyberCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 12),
    this.borderColor,
    this.backgroundColor,
    this.borderRadius = 18,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveBorder = borderColor ?? CyberMedicalTheme.primaryAccent.withValues(alpha: 0.25);
    final effectiveBg = backgroundColor ?? CyberMedicalTheme.cardSurfaceTranslucent;

    Widget cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: effectiveBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: effectiveBorder.withValues(alpha: 0.12),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Padding(
        padding: margin ?? EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: cardContent,
        ),
      );
    }

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: cardContent,
    );
  }
}
