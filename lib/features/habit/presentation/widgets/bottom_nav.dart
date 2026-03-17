import 'package:flutter/material.dart';
import 'package:pursuit/features/habit/presentation/pages/calendar/calendar_screen.dart';
import 'package:pursuit/features/habit/presentation/pages/goals/goals_library_screen.dart';
import 'package:pursuit/features/habit/presentation/pages/profile/profile_screen.dart';

class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav();

  static const double _fabSize = 70;
  static const double _barHeight = 64;
  static const double _totalHeight = 110;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color barColor = isDark
        ? const Color(0xFF1E1E1E)
        : Colors.grey.shade50;
    final Color inactiveColor = isDark
        ? Colors.white38
        : Theme.of(context).primaryColor.withValues(alpha: 0.5);

    return SafeArea(
      child: SizedBox(
        height: _totalHeight,
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            /// NAV BAR
            Positioned(
              bottom: 12,
              left: 20,
              right: 20,
              child: CustomPaint(
                painter: _NotchedPillPainter(
                  color: barColor,
                  fabRadius: _fabSize / 2,
                  isDark: isDark,
                ),
                child: SizedBox(
                  height: _barHeight,
                  child: Row(
                    children: [
                      Expanded(
                        child: _NavItem(
                          icon: Icons.calendar_month,
                          color: inactiveColor,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CalendarScreen(),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(width: _fabSize + 16),

                      Expanded(
                        child: _NavItem(
                          icon: Icons.settings,
                          color: inactiveColor,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// FAB BUTTON
            Positioned(
              bottom: 30,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GoalsLibraryScreen(),
                    ),
                  );
                },
                child: Container(
                  width: _fabSize,
                  height: _fabSize,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha:0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Single nav item ──────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: SizedBox(
        height: double.infinity,
        child: Center(child: Icon(icon, color: color, size: 24)),
      ),
    );
  }
}

// ─── CustomPainter: floating pill with smooth concave notch ───────────────────

class _NotchedPillPainter extends CustomPainter {
  const _NotchedPillPainter({
    required this.color,
    required this.fabRadius,
    required this.isDark,
  });

  final Color color;
  final double fabRadius;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final double h = size.height;
    final double w = size.width;
    final double cx = w / 2;

    // How deep + wide the notch is
    final double notchR = fabRadius + 10; // FAB radius + margin
    const double notchDepth = 14.0;
    const double notchSmoothWidth = 18.0; // width of smooth transition curve

    final Paint fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      // Start after left pill cap (height/2 = full pill radius)
      ..moveTo(h / 2, 0)
      // Top-left to notch entry
      ..lineTo(cx - notchR - notchSmoothWidth, 0)
      // Smooth left entry into notch
      ..cubicTo(
        cx - notchR - notchSmoothWidth / 2,
        0, // cp1
        cx - notchR,
        0, // cp2
        cx - notchR,
        notchDepth, // end point
      )
      // Curved bottom of notch (concave arc)
      ..arcToPoint(
        Offset(cx + notchR, notchDepth),
        radius: Radius.circular(notchR),
        clockwise: false,
      )
      // Smooth right exit from notch
      ..cubicTo(
        cx + notchR,
        0, // cp1
        cx + notchR + notchSmoothWidth / 2,
        0, // cp2
        cx + notchR + notchSmoothWidth,
        0, // end point
      )
      // Top-right to right pill cap
      ..lineTo(w - h / 2, 0)
      // Right pill cap
      ..arcToPoint(
        Offset(w - h / 2, h),
        radius: Radius.circular(h / 2),
        clockwise: true,
      )
      // Bottom right to bottom left
      ..lineTo(h / 2, h)
      // Left pill cap
      ..arcToPoint(
        Offset(h / 2, 0),
        radius: Radius.circular(h / 2),
        clockwise: true,
      )
      ..close();

    // Draw shadow underneath
    canvas.drawShadow(
      path,
      isDark ? Colors.black.withValues(alpha:0.6) : Colors.black.withValues(alpha:0.12),
      12,
      false,
    );

    // Draw the bar fill
    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _NotchedPillPainter old) =>
      old.color != color || old.isDark != isDark;
}
