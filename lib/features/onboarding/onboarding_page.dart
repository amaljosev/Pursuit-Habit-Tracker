import 'package:flutter/material.dart';
import 'package:pursuit/features/habit/presentation/pages/splash/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Build Better Habits',
      description:
          'Start small and stay consistent. Build lasting habits with guided daily practice.',
      imageAsset: 'assets/images/onboarding1.png',
      color: const Color(0xFF6366F1),
      secondaryColor: const Color(0xFF8B5CF6),
    ),
    OnboardingPage(
      title: 'Track Your Progress',
      description:
          'Visualize your streaks and growth. Celebrate every milestone in your journey.',
      imageAsset: 'assets/images/onboarding2.png',
      color: const Color(0xFF10B981),
      secondaryColor: const Color(0xFF34D399),
    ),
    OnboardingPage(
      title: 'Stay Consistent',
      description:
          'Get gentle reminders and stay on track with your daily habits effortlessly.',
      imageAsset: 'assets/images/onboarding3.png',
      color: const Color(0xFFF59E0B),
      secondaryColor: const Color(0xFFFBBF24),
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showOnboarding', true);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const SplashScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: _pages[_currentPage].color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // Page View Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return OnboardingContent(
                    page: page,
                    currentIndex: index,
                    totalPages: _pages.length,
                  );
                },
              ),
            ),

            // Navigation Controls
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dots Indicator
                  PageIndicator(
                    currentPage: _currentPage,
                    totalPages: _pages.length,
                    activeColor: _pages[_currentPage].color,
                  ),

                  // Next/Get Started Button
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _completeOnboarding();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _pages[_currentPage].color,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 5,
                      children: [
                        Text(
                          _currentPage == _pages.length - 1
                              ? 'Get Started'
                              : 'Next',
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: Colors.white
                          ),
                        ),
                        Icon(
                          _currentPage == _pages.length - 1
                              ? Icons.arrow_forward
                              : Icons.arrow_forward_ios,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String imageAsset;
  final Color color;
  final Color secondaryColor;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.color,
    required this.secondaryColor,
  });
}

class OnboardingContent extends StatelessWidget {
  final OnboardingPage page;
  final int currentIndex;
  final int totalPages;

  const OnboardingContent({
    super.key,
    required this.page,
    required this.currentIndex,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Animated Graphic
          Expanded(
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      page.color.withValues(alpha: 0.1),
                      page.secondaryColor.withValues(alpha: 0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  children: [
                    // Pulsing Animation
                    Center(
                      child: _buildPulsingCircle(
                        page.color.withValues(alpha: 0.2),
                      ),
                    ),
                    // Icon/Image
                    Center(
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: page.color.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: page.color.withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          _getIconForPage(currentIndex),
                          size: 70,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Title
          Text(
            page.title,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white70 : Color(0xFF1F2937),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              page.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulsingCircle(Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 2000),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: 280 * value,
          height: 280 * value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 1 - value),
          ),
        );
      },
    );
  }

  IconData _getIconForPage(int index) {
    switch (index) {
      case 0:
        return Icons.trending_up;
      case 1:
        return Icons.bar_chart;
      case 2:
        return Icons.notifications_active;
      default:
        return Icons.check_circle;
    }
  }
}

class PageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Color activeColor;

  const PageIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalPages, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == currentPage ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == currentPage ? activeColor : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
