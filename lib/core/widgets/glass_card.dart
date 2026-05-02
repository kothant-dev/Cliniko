import 'dart:ui';
import 'package:cliniko/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AppTheme.space16),
    this.borderRadius,
    this.blur = 20.0,
    this.opacity,
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final double blur;
  final double? opacity;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultOpacity = isDark ? 0.6 : 0.8;

    return Container(
      width: width,
      height: height,
      decoration: AppTheme.glassDecoration(
        context: context,
        blur: blur,
        opacity: opacity ?? defaultOpacity,
        borderRadius: borderRadius,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusMedium),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
