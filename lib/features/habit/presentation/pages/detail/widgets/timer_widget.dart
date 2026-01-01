import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ModernTimerWidget extends StatefulWidget {
  final int totalGoalCount;
  final int completedGoalCount;
  final String goalValue;
  final VoidCallback saveTime;
  final Color primaryColor;
  final Color progressColor;
  final double size;
  final VoidCallback? onTimerComplete;
  final VoidCallback? onTimerStart;
  final VoidCallback? onTimerPause;
  final VoidCallback? onResetTimer;

  const ModernTimerWidget({
    super.key,
    required this.totalGoalCount,
    required this.completedGoalCount,
    required this.goalValue,
    required this.saveTime,
    this.primaryColor = Colors.blue,
    this.progressColor = Colors.blue,
    this.size = 200,
    this.onTimerComplete,
    this.onTimerStart,
    this.onTimerPause,
    this.onResetTimer,
  });

  @override
  State<ModernTimerWidget> createState() => _ModernTimerWidgetState();
}

class _ModernTimerWidgetState extends State<ModernTimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late int _currentGoalCount;
  Timer? _saveTimer;
  bool _isRunning = false;

  Duration get _unitDuration => widget.goalValue == 'min'
      ? const Duration(minutes: 1)
      : const Duration(hours: 1);

  Duration get _totalDuration => _unitDuration * widget.totalGoalCount;

  @override
  void initState() {
    super.initState();

    _currentGoalCount = widget.completedGoalCount;

    _progressController = AnimationController(
      vsync: this,
      duration: _totalDuration,
    )..value = _currentGoalCount / widget.totalGoalCount;

    _progressAnimation =
        CurvedAnimation(parent: _progressController, curve: Curves.linear)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              setState(() => _isRunning = false);
              widget.onTimerComplete?.call();
              _saveTimer?.cancel();
            }
          });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _saveTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_progressController.isCompleted) {
      _progressController.reset();
      _currentGoalCount = 0;
    }

    setState(() => _isRunning = true);
    widget.onTimerStart?.call();

    // Continue from where left off
    final remainingProgress = 1.0 - _progressController.value;
    final remainingDuration = _totalDuration * remainingProgress;

    _progressController.forward(from: _progressController.value);

    // Save progress every unit duration
    _saveTimer?.cancel();
    _saveTimer = Timer.periodic(_unitDuration, (timer) {
      if (!_isRunning) return;

      if (_currentGoalCount < widget.totalGoalCount) {
        setState(() => _currentGoalCount++);
        widget.saveTime();
      } else {
        _saveTimer?.cancel();
      }
    });

    // Ensure duration sync
    Future.delayed(remainingDuration, () {
      if (mounted) {
        setState(() => _isRunning = false);
        _saveTimer?.cancel();
        widget.onTimerComplete?.call();
      }
    });
  }

  void _pauseTimer() {
    setState(() => _isRunning = false);
    widget.onTimerPause?.call();
    _progressController.stop();
    _saveTimer?.cancel();
  }

  void _resetTimer() {
    _pauseTimer();
    widget.onResetTimer?.call();
    _progressController.reset();

    setState(() {
      _currentGoalCount = 0;
    });
  }

  String _formatTime(double progress) {
    final totalSeconds = _totalDuration.inSeconds;
    final remainingSeconds = (totalSeconds * (1 - progress)).ceil();

    final hours = (remainingSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((remainingSeconds % 3600) ~/ 60).toString().padLeft(
      2,
      '0',
    );
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final circleSize = widget.size;
    final progressSize = circleSize * 0.9;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  final progress = _progressAnimation.value;

                  return Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.primaryColor.withValues(alpha: 0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: progressSize,
                          height: progressSize,
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(
                          width: progressSize,
                          height: progressSize,
                          child: CustomPaint(
                            painter: _TimerProgressPainter(
                              progress: progress,
                              progressColor: widget.progressColor,
                              backgroundColor: Colors.grey[200]!,
                              strokeWidth: circleSize * 0.06,
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: progressSize * 0.85,
                          height: progressSize * 0.85,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                widget.primaryColor.withValues(
                                  alpha: _isRunning ? 0.1 : 0.05,
                                ),
                                Colors.transparent,
                              ],
                              stops: const [0.1, 0.8],
                            ),
                          ),
                        ),
                        AnimatedScale(
                          duration: const Duration(milliseconds: 200),
                          scale: _isRunning ? 1.05 : 1.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                progress == 1.0 ? '🎉' : _formatTime(progress),
                                style: TextStyle(
                                  fontSize: circleSize * 0.14,
                                  fontWeight: FontWeight.w700,
                                  color: widget.primaryColor,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                progress == 1.0
                                    ? 'Completed'
                                    : _isRunning
                                    ? 'Running'
                                    : 'Paused',
                                style: TextStyle(
                                  fontSize: circleSize * 0.06,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: circleSize * 0.16),
              _buildTimerControls(),
              SizedBox(height: circleSize * 0.08),
              Text(
                '$_currentGoalCount / ${widget.totalGoalCount} ${widget.goalValue}',
                style: TextStyle(
                  fontSize: circleSize * 0.06,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "💡 A minimum of 1 ${widget.goalValue == 'min' ? 'minute' : 'hour'} is required for auto-save. "
                  "Progress will be saved automatically every ${widget.goalValue == 'min' ? 'minute' : 'hour'}.",
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimerControls() {
    final buttonSize = widget.size * 0.3;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(
          icon: Icons.refresh_rounded,
          color: Colors.grey[600]!,
          onPressed: _resetTimer,
          tooltip: 'Reset Timer',
          size: buttonSize,
          label: 'Reset',
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: buttonSize * 1.2,
          height: buttonSize * 1.2,
          decoration: BoxDecoration(
            color: widget.primaryColor,
            shape: BoxShape.circle,
            boxShadow: _isRunning
                ? [
                    BoxShadow(
                      color: widget.primaryColor.withValues(alpha: 0.6),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: widget.primaryColor.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: IconButton(
            onPressed: _isRunning ? _pauseTimer : _startTimer,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                key: ValueKey(_isRunning),
                color: Colors.white,
                size: buttonSize * 0.6,
              ),
            ),
          ),
        ),
        _buildControlButton(
          icon: CupertinoIcons.check_mark,
          color: widget.primaryColor,
          onPressed: () => widget.onTimerComplete?.call(),
          tooltip: 'Finish Goal',
          size: buttonSize,
          label: 'Finish Goal',
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
    required double size,
    required String label,
  }) {
    return Column(
      spacing: 10,
      children: [
        Tooltip(
          message: tooltip,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: onPressed,
              icon: Icon(icon, color: color, size: size * 0.5),
            ),
          ),
        ),
        Text(label),
      ],
    );
  }
}

class _TimerProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  const _TimerProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    final progPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final sweep = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweep,
      false,
      progPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TimerProgressPainter old) =>
      progress != old.progress ||
      progressColor != old.progressColor ||
      backgroundColor != old.backgroundColor ||
      strokeWidth != old.strokeWidth;
}
