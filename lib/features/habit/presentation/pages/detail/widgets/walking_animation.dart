import 'package:flutter/material.dart';

class WalkingProgressIndicator extends StatefulWidget {
  final String unit;
  final double totalGoal;
  final double completedCount;
  final void Function() onIncrease;
  final void Function() onDecrease;
  final Color primaryColor;
  final Color secondaryColor;
  final String iconEmoji;

  const WalkingProgressIndicator({
    super.key,
    required this.unit,
    required this.totalGoal,
    required this.completedCount,
    required this.onDecrease,
    required this.onIncrease,
    required this.primaryColor,
    required this.secondaryColor,
    required this.iconEmoji,
  });

  @override
  WalkingProgressIndicatorState createState() =>
      WalkingProgressIndicatorState();
}

class WalkingProgressIndicatorState extends State<WalkingProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController _moveController;
  late Animation<double> _positionAnim;
  late Animation<Color?> colorAnim;

  double _currentProgress = 0.0;

  @override
  void initState() {
    super.initState();
    assert(widget.totalGoal > 0, 'totalGoal must be > 0');
    _currentProgress = (widget.completedCount / widget.totalGoal).clamp(
      0.0,
      1.0,
    );

    _moveController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _initAnimations(begin: 0.0, end: _currentProgress);
    _moveController.forward();
  }

  void _initAnimations({required double begin, required double end}) {
    _positionAnim = Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: _moveController, curve: Curves.easeOutQuart),
    );
    colorAnim =
        ColorTween(
          begin: widget.primaryColor.withValues(alpha: 0.3),
          end: widget.secondaryColor,
        ).animate(
          CurvedAnimation(parent: _moveController, curve: Curves.easeInOut),
        );
  }

  @override
  void didUpdateWidget(WalkingProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.completedCount != widget.completedCount ||
        oldWidget.totalGoal != widget.totalGoal) {
      _updateProgressAnimation();
    }
  }

  void _updateProgressAnimation() {
    final newProg = (widget.completedCount / widget.totalGoal).clamp(0.0, 1.0);
    _initAnimations(begin: _currentProgress, end: newProg);
    _currentProgress = newProg;

    _moveController
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _moveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isComplete = _currentProgress >= 1.0;
    final int percent = (_currentProgress * 100).clamp(0, 100).toInt();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        spacing: 20,
        children: [
          // Header
          Text(
            '${widget.completedCount.toInt()} / ${widget.totalGoal.toInt()} ${widget.unit}',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: widget.secondaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$percent% Complete',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: widget.primaryColor),
            ),
          ),
          // Track + moving character
          LayoutBuilder(
            builder: (context, constraints) {
              final fullWidth = constraints.maxWidth;
              return SizedBox(
                height: 120,
                child: Stack(
                  children: [
                    // Track line background
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),

                    // Progress fill
                    AnimatedBuilder(
                      animation: _positionAnim,
                      builder: (ctx, ch) {
                        return Positioned(
                          bottom: 20,
                          right: 0,
                          child: Container(
                            height: 18,
                            width: fullWidth * _positionAnim.value,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft,
                                colors: [
                                  widget.primaryColor,
                                  widget.secondaryColor,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.secondaryColor.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // Character or check mark (without bouncing)
                    AnimatedBuilder(
                      animation: _positionAnim,
                      builder: (ctx, ch) {
                        final double moveX = fullWidth * _positionAnim.value;
                        if (isComplete) {
                          return Positioned(
                            left: 0,
                            top: 20,
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: widget.secondaryColor,
                              size: 48,
                            ),
                          );
                        } else {
                          return Positioned(
                            right: moveX,
                            top: 30,
                            bottom: 0,
                            child: Text(
                              widget.iconEmoji,
                              style: const TextStyle(fontSize: 36),
                            ),
                          );
                        }
                      },
                    ),

                    // Goal flag at the end of the track
                    if (!isComplete)
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: Icon(
                          Icons.flag_rounded,
                          color: widget.primaryColor,
                          size: 40,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCircleButton(
                icon: Icons.remove_rounded,
                onTap: widget.onDecrease,
                backgroundColor: Colors.grey[100]!,
                iconColor: widget.primaryColor,
                size: 80,
                isDark: isDark,
                label: "-1 ${widget.unit}",
              ),
              _buildCircleButton(
                icon: Icons.add_rounded,
                onTap: widget.onIncrease,
                backgroundColor: widget.secondaryColor,
                iconColor: Colors.white,
                size: 80,
                isDark: isDark,
                label: "+1 ${widget.unit}",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color backgroundColor,
    required Color iconColor,
    double size = 50,
    required String label,
    required bool isDark
  }) {
    return Column(
      spacing: 5,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            boxShadow:isDark?null: [
              BoxShadow(
                color: iconColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: onTap,
            icon: Icon(icon, color: iconColor, size: size * 0.45),
          ),
        ),
        Text(label),
      ],
    );
  }
}
