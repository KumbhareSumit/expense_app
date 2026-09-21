import 'package:flutter/material.dart';

class MeshBackground extends StatelessWidget {
  final Widget child;

  const MeshBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Define colors dynamically based on the current theme mode
    // Deep Navy base for dark mode to match the requested fabric texture
    final bgColor = const Color(0xFF0A142F);
    final lineColor = const Color(0xFF050B1A);
    
    // Orbs colors - Glowing colors that look spectacular over deep navy
    final orb1Color = isDark ? const Color(0xFF5E2CA5).withValues(alpha: 0.6) : const Color(0xFFE0B0FF).withValues(alpha: 0.5); // Purple
    final orb2Color = isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.6) : const Color(0xFF93C5FD).withValues(alpha: 0.5); // Blue
    final orb3Color = isDark ? const Color(0xFF00E5FF).withValues(alpha: 0.20) : const Color(0xFF5EEAD4).withValues(alpha: 0.4); // Bright Cyan

    return Stack(
      children: [
        // Ribbed Texture Background
        Positioned.fill(
          child: CustomPaint(
            painter: RibbedTexturePainter(
              backgroundColor: bgColor,
              lineColor: lineColor,
            ),
          ),
        ),
        // Gradient Orbs
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [orb1Color, Colors.transparent],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          right: -100,
          child: Container(
            width: 450,
            height: 450,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [orb2Color, Colors.transparent],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          top: 250,
          right: -150,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [orb3Color, Colors.transparent],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
        // Content
        child,
      ],
    );
  }
}

class RibbedTexturePainter extends CustomPainter {
  final Color backgroundColor;
  final Color lineColor;

  RibbedTexturePainter({
    required this.backgroundColor,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Fill the base color
    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Draw the ribbed lines (diagonal / pattern)
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final spacing = 4.0; // Very tight spacing to mimic corduroy/fabric

    // Cover the entire canvas with diagonals
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, size.height), // Start at bottom
        Offset(i + size.height, 0), // End at top right
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

