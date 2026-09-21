import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Border? border;
  final Color? color;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 12.0,
    this.opacity = 0.15,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.border,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(20.0);
    
    // Determine effective glass base color and opacity
    final baseColor = color ?? Colors.white;
    // If color is specified, use a richer tint, otherwise use a crisp frosted white tint
    final effectiveOpacity = color != null
        ? opacity.clamp(0.15, 0.60)
        : (opacity != 0.15 ? opacity : 0.12);

    return Container(
      margin: margin,
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: br,
        boxShadow: [
          // Soft ambient glass shadow to lift container from the dark mesh
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 24,
            spreadRadius: -2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: br,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              // Gradient surface to give genuine glass depth and light reflection
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  baseColor.withValues(alpha: effectiveOpacity),
                  baseColor.withValues(
                    alpha: (effectiveOpacity * 0.45).clamp(0.04, 1.0),
                  ),
                ],
              ),
              borderRadius: br,
              // Uniform border so BoxDecoration with borderRadius is valid and paints properly
              border: border ??
                  Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                    width: 1.0,
                  ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
