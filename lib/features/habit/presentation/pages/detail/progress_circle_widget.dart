import 'dart:math';
import 'package:flutter/material.dart';

class WaterFillGlassProgress extends StatefulWidget {
  final double totalValue;
  final double currentValue;
  final double width;
  final double height;
  final Color color;
  final Color backgroundColor;

  const WaterFillGlassProgress({
    super.key,
    required this.totalValue,
    required this.currentValue,
    required this.color,
    this.backgroundColor = Colors.blue,
    this.width = 150,
    this.height = 250,
  });

  @override
  State<WaterFillGlassProgress> createState() => _WaterFillGlassProgressState();
}

class _WaterFillGlassProgressState extends State<WaterFillGlassProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        final progress = (widget.currentValue / widget.totalValue).clamp(0.0, 1.0);
        return CustomPaint(
          painter: _GlassPainter(
            progress: progress,
            wavePhase: _waveController.value * 2 * pi,
            color: widget.color,
            backgroundColor: widget.backgroundColor,
          ),
          size: Size(widget.width, widget.height),
        );
      },
    );
  }
}

class _GlassPainter extends CustomPainter {
  final double progress;
  final double wavePhase;
  final Color color;
  final Color backgroundColor;

  _GlassPainter({
    required this.progress,
    required this.wavePhase,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double glassTopWidth = size.width * 0.9;
    final double glassBottomWidth = size.width * 0.6;
    final double glassHeight = size.height * 0.9;
    final double radius = 16.0;

    // Create a curved glass shape
    final Path glassPath = Path()
      ..moveTo((size.width - glassTopWidth) / 2 + radius, 0)
      ..lineTo((size.width + glassTopWidth) / 2 - radius, 0)
      ..quadraticBezierTo(
        (size.width + glassTopWidth) / 2,
        0,
        (size.width + glassTopWidth) / 2,
        radius,
      )
      ..lineTo((size.width + glassBottomWidth) / 2, glassHeight - radius)
      ..quadraticBezierTo(
        (size.width + glassBottomWidth) / 2,
        glassHeight,
        (size.width + glassBottomWidth) / 2 - radius,
        glassHeight,
      )
      ..lineTo((size.width - glassBottomWidth) / 2 + radius, glassHeight)
      ..quadraticBezierTo(
        (size.width - glassBottomWidth) / 2,
        glassHeight,
        (size.width - glassBottomWidth) / 2,
        glassHeight - radius,
      )
      ..lineTo((size.width - glassTopWidth) / 2, radius)
      ..quadraticBezierTo(
        (size.width - glassTopWidth) / 2,
        0,
        (size.width - glassTopWidth) / 2 + radius,
        0,
      )
      ..close();

    // Glass outline
    final borderPaint = Paint()
      ..color = Colors.blueGrey.shade300.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(glassPath, borderPaint);

    // Clip to glass shape
    canvas.save();
    canvas.clipPath(glassPath);

    // Background (glass inner)
    final bgPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          backgroundColor.withOpacity(0.2),
          backgroundColor.withOpacity(0.05),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(glassPath, bgPaint);

    // Draw water wave
    final wavePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withOpacity(0.4),
          color.withOpacity(0.6),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final Path wavePath = Path();
    final double baseHeight = glassHeight * (1 - progress);
    const double waveAmplitude = 6.0;
    final double waveLength = size.width / 1.5;

    wavePath.moveTo(0, baseHeight);
    for (double x = 0; x <= size.width; x++) {
      final y = baseHeight + sin((x / waveLength * 2 * pi) + wavePhase) * waveAmplitude;
      wavePath.lineTo(x, y);
    }
    wavePath.lineTo(size.width, glassHeight);
    wavePath.lineTo(0, glassHeight);
    wavePath.close();

    canvas.drawPath(wavePath, wavePaint);
    canvas.restore();

    // Glass highlight (light reflection)
    final highlight = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(glassPath, highlight);
  }

  @override
  bool shouldRepaint(covariant _GlassPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.wavePhase != wavePhase;
}
