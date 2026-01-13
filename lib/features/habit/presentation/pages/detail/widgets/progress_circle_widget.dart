import 'package:flutter/material.dart';

class AnimatedRoundedProgress extends StatefulWidget {
  final double totalValue;
  final double completedValue;
  final Color color;

  const AnimatedRoundedProgress({
    super.key,
    required this.totalValue,
    required this.completedValue,
    required this.color,
  });

  @override
  AnimatedRoundedProgressState createState() => AnimatedRoundedProgressState();
}

class AnimatedRoundedProgressState extends State<AnimatedRoundedProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _oldCompleted = 0;

  @override
  void initState() {
    super.initState();
    _oldCompleted = widget.completedValue;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(
      begin: _oldCompleted,
      end: widget.completedValue,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedRoundedProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.completedValue != oldWidget.completedValue) {
      _oldCompleted = oldWidget.completedValue;
      _animation = Tween<double>(
        begin: _oldCompleted,
        end: widget.completedValue,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
      _controller
        ..value = 0
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Helper function to generate a lighter version of the user's color
  Color _getLightShade(Color color) {
    final hsl = HSLColor.fromColor(color);
    final lighter = hsl.withLightness((hsl.lightness + 0.6).clamp(0.0, 1.0));
    return lighter.toColor();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.totalValue;
    final backgroundColor = _getLightShade(widget.color);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        double current = _animation.value;
        double percent = (total > 0) ? (current / total).clamp(0.0, 1.0) : 0.0;

        return CustomPaint(
          painter: _CircleProgressPainter(
            backgroundColor: backgroundColor,
            progressColor: widget.color,
            strokeWidth: 20,
            percent: percent,
          ),
          child: SizedBox(
            width: 300,
            height: 300,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 5,
                children: [
                  Text(
                    "${(percent * 100).toStringAsFixed(0)}%",
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Completed',
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[200],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CircleProgressPainter extends CustomPainter {
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;
  final double percent;

  _CircleProgressPainter({
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
    required this.percent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2);

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw background circle
    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    double sweepAngle = 2 * 3.141592653589793 * percent;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.141592653589793 / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircleProgressPainter old) {
    return old.percent != percent ||
        old.progressColor != progressColor ||
        old.backgroundColor != backgroundColor ||
        old.strokeWidth != strokeWidth;
  }
}
