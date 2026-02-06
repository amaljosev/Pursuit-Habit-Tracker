import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pursuit/core/extensions/context_extensions.dart';
import 'package:pursuit/core/functions/helper_functions.dart';
import 'package:pursuit/features/habit/domain/entities/habit.dart';
import 'package:pursuit/features/habit/presentation/pages/progress/widgets/appbar_widget.dart';
import 'package:pursuit/features/habit/presentation/pages/progress/widgets/overview_widget.dart';
import 'package:table_calendar/table_calendar.dart';

class ProgressPage extends StatefulWidget {
  final Habit habit;

  const ProgressPage({super.key, required this.habit});

  @override
  ProgressPageState createState() => ProgressPageState();
}

class ProgressPageState extends State<ProgressPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentChartIndex = 0;
  int _currentComparisonPeriod = 0;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  int _selectedYear = DateTime.now().year;
  late ScrollController _heatmapScrollController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    _heatmapScrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentMonth();
    });
  }

  void _scrollToCurrentMonth() {
    final now = DateTime.now();
    if (_selectedYear != now.year) return;

    final month = now.month;
    // Scroll to approximate position of current month
    final scrollPosition = (month - 1) * 53.0 / 12 * 14.0;

    _heatmapScrollController.animateTo(
      scrollPosition,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _heatmapScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          buildAppBar(widget, isDark, context),

          buildStatsOverview(context, _fadeAnimation, widget, isDark),
          _buildYearlyHeatMap(isDark),
          _buildChartsSection(isDark),
          _buildActivityCalendar(isDark),

          SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildYearlyHeatMap(bool isDark) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? HelperFunctions.getColorById(
                  id: widget.habit.color,
                  isDarkMode: true,
                )
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Year
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Year in Pixels',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedYear = _selectedYear == DateTime.now().year
                          ? DateTime.now().year - 1
                          : DateTime.now().year;
                    });
                    // Scroll to current month when switching to current year
                    if (_selectedYear == DateTime.now().year) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToCurrentMonth();
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: HelperFunctions.getColorById(
                        id: widget.habit.color,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '$_selectedYear',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: HelperFunctions.getColorById(
                              id: widget.habit.color,
                            ),
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.swap_horiz,
                          size: 16,
                          color: HelperFunctions.getColorById(
                            id: widget.habit.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // 365 Squares Container
            Container(
              height: 140,
              child: SingleChildScrollView(
                controller: _heatmapScrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: _build365Squares(isDark),
              ),
            ),
            SizedBox(height: 8),

            // Stats
            _buildStats(isDark),
          ],
        ),
      ),
    );
  }

  Widget _build365Squares(bool isDark) {
    final completedDates = _getYearlyCompletedDates(_selectedYear);
    final totalDays = 365;

    const double squareSize = 14.0;
    const double spacing = 2.0;

    final now = DateTime.now();
    final isCurrentYear = _selectedYear == now.year;

    return Row(
      children: List.generate(53, (weekIndex) {
        return Container(
          margin: EdgeInsets.only(right: spacing),
          child: Column(
            children: List.generate(7, (dayIndex) {
              final dayNumber = weekIndex * 7 + dayIndex + 1;
              if (dayNumber > totalDays) {
                return Container(
                  width: squareSize,
                  height: squareSize,
                  margin: EdgeInsets.only(bottom: spacing),
                );
              }

              final date = DateTime(_selectedYear, 1, dayNumber);
              final isCompleted = completedDates.any(
                (completedDate) =>
                    completedDate.year == date.year &&
                    completedDate.month == date.month &&
                    completedDate.day == date.day,
              );

              final habitColor = HelperFunctions.getColorById(
                id: widget.habit.color,
              );
              final isToday =
                  isCurrentYear &&
                  date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day;

              return Container(
                width: squareSize,
                height: squareSize,
                margin: EdgeInsets.only(bottom: spacing),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? habitColor
                      : (isDark ? Colors.grey[800] : Colors.grey[100]),
                  borderRadius: BorderRadius.circular(2),
                  border: isToday
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildStats(bool isDark) {
    final completedDates = _getYearlyCompletedDates(_selectedYear);
    final completedCount = completedDates.length;
    final percentage = (completedCount / 365 * 100).round();
    final habitColor = HelperFunctions.getColorById(id: widget.habit.color);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$completedCount/365 days',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: habitColor,
          ),
        ),
        Text(
          '$percentage%',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: habitColor,
          ),
        ),
      ],
    );
  }

  Set<DateTime> _getYearlyCompletedDates(int year) {
    final completedDates = <DateTime>{};

    for (final dayMap in widget.habit.completedDays) {
      try {
        final dateStr = dayMap['date'] as String;
        final date = DateTime.parse(dateStr);
        if (date.year == year) {
          completedDates.add(date);
        }
      } catch (e) {
        continue;
      }
    }

    return completedDates;
  }

  SliverToBoxAdapter _buildChartsSection(bool isDark) {
    return SliverToBoxAdapter(
      child: Column(
        children: [_buildChartSelector(isDark), _buildCurrentChart(isDark)],
      ),
    );
  }

  Widget _buildChartSelector(bool isDark) {
    return Container(
      width: context.screenWidth,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark
            ? HelperFunctions.getColorById(
                id: widget.habit.color,
                isDarkMode: true,
              )
            : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: SizedBox(
        height: 50,
        child: ListView(
          scrollDirection: Axis.horizontal,

          children: [
            _buildChartTypeButton('Streak Trend', 0, isDark),
            _buildChartTypeButton('Active Days', 1, isDark),
            _buildChartTypeButton('Monthly Progress', 2, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildChartTypeButton(String label, int index, bool isDark) {
    final isSelected = _currentChartIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: () => setState(() => _currentChartIndex = index),
        style: TextButton.styleFrom(
          backgroundColor: isSelected
              ? HelperFunctions.getColorById(
                  id: widget.habit.color,
                ).withValues(alpha: 0.1)
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isDark
                ? isSelected
                      ? HelperFunctions.getColorById(
                          id: widget.habit.color,
                          isDark: true,
                        )
                      : Colors.grey[400]
                : isSelected
                ? HelperFunctions.getColorById(
                    id: widget.habit.color,
                    isDark: true,
                  )
                : Colors.grey[600],
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentChart(bool isDark) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      child: Container(
        key: ValueKey(_currentChartIndex),
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark
              ? HelperFunctions.getColorById(
                  id: widget.habit.color,
                  isDarkMode: true,
                )
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: _getChartForIndex(_currentChartIndex, isDark),
      ),
    );
  }

  Widget _getChartForIndex(int index, bool isDark) {
    switch (index) {
      case 0:
        return _buildStreakTrendChart(isDark);
      case 1:
        return _buildMostActiveDaysChart();
      case 2:
        return _buildComparisonChart(isDark);
      default:
        return _buildMostActiveDaysChart();
    }
  }

  Widget _buildMostActiveDaysChart() {
    final dayData = _calculateMostActiveDays();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Most Active Days',
          style: Theme.of(
            context,
          ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY:
                  dayData.values.reduce((a, b) => a > b ? a : b).toDouble() + 2,
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final days = [
                        'Mon',
                        'Tue',
                        'Wed',
                        'Thu',
                        'Fri',
                        'Sat',
                        'Sun',
                      ];
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          days[value.toInt()],
                          style: TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: dayData.entries.map((entry) {
                final index = entry.key;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value.toDouble(),
                      color: _getBarColor(index, entry.value),
                      width: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStreakTrendChart(bool isDark) {
    final streakData = _generateStreakTrendData();
    final habitColor = HelperFunctions.getColorById(id: widget.habit.color);
    final currentStreak = widget.habit.streakCount;
    final bestStreak = widget.habit.bestStreak;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with stats
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Streak Trend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: habitColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${streakData.last} days',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: habitColor,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),

        // Mini stats row
        Row(
          children: [
            _buildMiniStreakStat('Current', '$currentStreak days', habitColor),
            SizedBox(width: 16),
            _buildMiniStreakStat('Best', '$bestStreak days', Colors.amber),
            SizedBox(width: 16),
            _buildTrendIndicator(streakData),
          ],
        ),
        SizedBox(height: 16),

        // Chart with improved UX
        Container(
          height: 200,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? HelperFunctions.getColorById(
                    id: widget.habit.color,
                    isDarkMode: true,
                  )
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: streakData.reduce((a, b) => a > b ? a : b).toDouble() * 1.2,
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  tooltipBorder: BorderSide(color: habitColor),

                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      return LineTooltipItem(
                        'Day ${spot.x.toInt() + 1}\n${spot.y.toInt()} days',
                        TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 20,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() % 2 == 0 &&
                          value.toInt() < streakData.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Day ${value.toInt() + 1}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() == value && value.toInt() % 5 == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            '${value.toInt()}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.right,
                          ),
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: false,
                drawVerticalLine: true,
                drawHorizontalLine: true,
                horizontalInterval: 5,
                verticalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey[200]!,
                    strokeWidth: 1,
                    dashArray: [3, 3],
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(color: Colors.grey[100]!, strokeWidth: 1);
                },
              ),
              borderData: FlBorderData(
                show: false,
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: streakData.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value.toDouble());
                  }).toList(),
                  isCurved: true,
                  color: habitColor,
                  barWidth: 4,
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        habitColor.withValues(alpha: 0.3),
                        habitColor.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: habitColor,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  shadow: Shadow(
                    color: habitColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ),
              ],
              // Add trend line if applicable
              extraLinesData: _buildTrendLines(streakData, habitColor),
            ),
          ),
        ),

        // Chart legend and insights
        SizedBox(height: 16),
        _buildChartInsights(streakData, currentStreak, bestStreak),
      ],
    );
  }

  Widget _buildMiniStreakStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendIndicator(List<int> streakData) {
    if (streakData.length < 2) return SizedBox.shrink();

    final current = streakData.last;
    final previous = streakData[streakData.length - 2];
    final isIncreasing = current > previous;
    final isSame = current == previous;

    return Row(
      children: [
        Icon(
          isSame
              ? Icons.remove
              : isIncreasing
              ? Icons.trending_up
              : Icons.trending_down,
          size: 16,
          color: isSame
              ? Colors.grey
              : isIncreasing
              ? Colors.green
              : Colors.red,
        ),
        SizedBox(width: 4),
        Text(
          isSame
              ? 'Steady'
              : isIncreasing
              ? 'Growing'
              : 'Declining',
          style: TextStyle(
            fontSize: 10,
            color: isSame
                ? Colors.grey
                : isIncreasing
                ? Colors.green
                : Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  ExtraLinesData? _buildTrendLines(List<int> streakData, Color habitColor) {
    if (streakData.length < 3) return null;

    // Calculate average trend
    double sum = 0;
    for (var value in streakData) {
      sum += value.toDouble();
    }
    final average = sum / streakData.length;

    return ExtraLinesData(
      horizontalLines: [
        HorizontalLine(
          y: average,
          color: Colors.orange.withValues(alpha: 0.5),
          strokeWidth: 1,
          dashArray: [5, 5],
          label: HorizontalLineLabel(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 8),
            style: TextStyle(
              color: Colors.orange,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            labelResolver: (line) => 'Avg: ${average.toStringAsFixed(1)}',
          ),
        ),
      ],
    );
  }

  Widget _buildChartInsights(
    List<int> streakData,
    int currentStreak,
    int bestStreak,
  ) {
    final insights = <String>[];

    if (currentStreak >= 7) {
      insights.add(
        '🔥 Great consistency! You\'ve maintained this habit for over a week.',
      );
    }

    if (streakData.length >= 2) {
      final growth = streakData.last - streakData.first;
      if (growth > 0) {
        insights.add(
          '📈 Your streak has grown by $growth days in this period.',
        );
      } else if (growth < 0) {
        insights.add(
          '📉 Your streak has decreased by ${growth.abs()} days recently.',
        );
      }
    }

    if (currentStreak == bestStreak && currentStreak > 0) {
      insights.add('⭐ You\'re at your personal best! Keep going!');
    } else if (bestStreak - currentStreak <= 3 && currentStreak > 0) {
      insights.add(
        '💪 Only ${bestStreak - currentStreak} days away from your best streak!',
      );
    }

    if (insights.isEmpty) {
      insights.add('💡 Start building your streak! Complete your habit daily.');
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, size: 16, color: Colors.blue[700]),
              SizedBox(width: 8),
              Text(
                'Streak Insights',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          ...insights.map(
            (insight) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: Colors.blue[700])),
                  Expanded(
                    child: Text(
                      insight,
                      style: TextStyle(fontSize: 12, color: Colors.blue[800]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced data generation with real trend analysis
  List<int> _generateStreakTrendData() {
    // Analyze actual completion patterns from completedDays
    final completedDates = widget.habit.completedDays.map((day) {
      return DateTime.parse(day['date'] as String);
    }).toList()..sort((a, b) => a.compareTo(b));

    if (completedDates.isEmpty) {
      return List.generate(7, (index) => 0);
    }

    // Calculate streak over last 7 periods (days/weeks)
    final trendData = <int>[];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final targetDate = now.subtract(Duration(days: i));
      final streakOnDate = _calculateStreakOnDate(completedDates, targetDate);
      trendData.add(streakOnDate);
    }

    return trendData;
  }

  int _calculateStreakOnDate(
    List<DateTime> completedDates,
    DateTime targetDate,
  ) {
    int streak = 0;
    DateTime currentDate = targetDate;

    while (completedDates.any(
      (date) =>
          date.year == currentDate.year &&
          date.month == currentDate.month &&
          date.day == currentDate.day,
    )) {
      streak++;
      currentDate = currentDate.subtract(Duration(days: 1));
    }

    return streak;
  }

  Widget _buildComparisonChart(bool isDark) {
    final habitColor = HelperFunctions.getColorById(id: widget.habit.color);
    final previousColor = Colors.grey.withValues(alpha: 0.3);

    // --- 1. DATA PROCESSING LOGIC ---
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int getCountForDate(DateTime date) {
      final dateStr = date.toIso8601String().split('T')[0];
      final entry = widget.habit.completedDays.firstWhere(
        (e) => e['date'] == dateStr,
        orElse: () => {'date': dateStr, 'count': 0},
      );
      return entry['count'] as int;
    }

    List<double> currentValues = [];
    List<double> previousValues = [];
    List<String> labels = [];
    int currentTotal = 0;
    int previousTotal = 0;

    if (_currentComparisonPeriod == 0) {
      // WEEKLY (Mon-Sun)
      final currentWeekStart = today.subtract(
        Duration(days: today.weekday - 1),
      );
      final previousWeekStart = currentWeekStart.subtract(
        const Duration(days: 7),
      );
      labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
      for (int i = 0; i < 7; i++) {
        final cVal = getCountForDate(
          currentWeekStart.add(Duration(days: i)),
        ).toDouble();
        final pVal = getCountForDate(
          previousWeekStart.add(Duration(days: i)),
        ).toDouble();
        currentValues.add(cVal);
        previousValues.add(pVal);
        currentTotal += cVal.toInt();
        previousTotal += pVal.toInt();
      }
    } else if (_currentComparisonPeriod == 1) {
      // MONTHLY (4 Weeks)
      labels = ['W1', 'W2', 'W3', 'W4'];
      final startThisMonth = DateTime(today.year, today.month, 1);
      final startLastMonth = (today.month == 1)
          ? DateTime(today.year - 1, 12, 1)
          : DateTime(today.year, today.month - 1, 1);
      for (int i = 0; i < 4; i++) {
        double cSum = 0;
        double pSum = 0;
        for (int d = 0; d < 7; d++) {
          final dayNum = (i * 7) + d + 1;
          try {
            final cDate = DateTime(
              startThisMonth.year,
              startThisMonth.month,
              dayNum,
            );
            if (cDate.month == startThisMonth.month) {
              cSum += getCountForDate(cDate);
            }
            final pDate = DateTime(
              startLastMonth.year,
              startLastMonth.month,
              dayNum,
            );
            if (pDate.month == startLastMonth.month) {
              pSum += getCountForDate(pDate);
            }
          } catch (_) {}
        }
        currentValues.add(cSum);
        previousValues.add(pSum);
        currentTotal += cSum.toInt();
        previousTotal += pSum.toInt();
      }
    } else {
      // YEARLY (Jan-Dec)
      labels = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
      Map<int, int> thisY = {};
      Map<int, int> lastY = {};
      for (var entry in widget.habit.completedDays) {
        final d = DateTime.parse(entry['date']);
        if (d.year == today.year) {
          thisY[d.month] = (thisY[d.month] ?? 0) + (entry['count'] as int);
        } else if (d.year == today.year - 1) {
          lastY[d.month] = (lastY[d.month] ?? 0) + (entry['count'] as int);
        }
      }
      for (int i = 1; i <= 12; i++) {
        currentValues.add((thisY[i] ?? 0).toDouble());
        previousValues.add((lastY[i] ?? 0).toDouble());
        currentTotal += currentValues.last.toInt();
        previousTotal += previousValues.last.toInt();
      }
    }

    // --- 2. CHART GROUPS ---
    double maxY = 0;
    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < currentValues.length; i++) {
      if (currentValues[i] > maxY) maxY = currentValues[i];
      if (previousValues[i] > maxY) maxY = previousValues[i];
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: previousValues[i],
              color: previousColor,
              width: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            BarChartRodData(
              toY: currentValues[i],
              color: habitColor,
              width: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
          barsSpace: 4,
        ),
      );
    }
    maxY = (maxY * 1.2).ceilToDouble();
    if (maxY < 5) maxY = 5;

    // --- 3. UI RENDERING ---

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 10,
          children: [
            Text(
              'Progress',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontSize: MediaQuery.of(context).size.width * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: isDark
                    ? HelperFunctions.getColorById(
                        id: widget.habit.color,
                        isDarkMode: true,
                      )
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _buildPeriodBtn('Week', 0, habitColor, isDark),
                  _buildPeriodBtn('Month', 1, habitColor, isDark),
                  _buildPeriodBtn('Year', 2, habitColor, isDark),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 20),

        // Quick Stats Section
        _buildComparisonQuickStats(
          currentTotal.toDouble(),
          previousTotal.toDouble(),
          habitColor,
        ),

        SizedBox(height: 24),

        // Chart
        Container(
          height: 200,
          child: BarChart(
            BarChartData(
              maxY: maxY,

              gridData: FlGridData(
                show: false,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (v) =>
                    FlLine(color: Colors.grey[100]!, strokeWidth: 1),
              ),
              borderData: FlBorderData(
                show: isDark,
                border: Border.all(color: Colors.white),
              ),
              titlesData: FlTitlesData(
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, m) => Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        labels[v.toInt()],
                        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      ),
                    ),
                  ),
                ),
              ),
              barGroups: barGroups,
            ),
          ),
        ),

        SizedBox(height: 16),
        _buildChartLegend(previousColor, habitColor),
        SizedBox(height: 20),

        // Insights Section
        _buildComparisonInsights(
          currentTotal.toDouble(),
          previousTotal.toDouble(),
          habitColor,
        ),
      ],
    );
  }

  // --- SUPPORTING UI METHODS ---

  Widget _buildPeriodBtn(String label, int index, Color color, bool isDark) {
    final isSelected = _currentComparisonPeriod == index;
    return GestureDetector(
      onTap: () => setState(() => _currentComparisonPeriod = index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? isDark
                    ? HelperFunctions.getColorById(
                        id: widget.habit.color,
                        isDark: true,
                      )
                    : Colors.white
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black12, blurRadius: 2)]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: isSelected
                  ? isDark
                        ? Colors.white
                        : Colors.black
                  : Colors.grey,
              fontSize: MediaQuery.of(context).size.width * 0.035,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonQuickStats(
    double current,
    double previous,
    Color habitColor,
  ) {
    final diff = current - previous;
    final isUp = diff >= 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _statItem(
          'Current',
          current.toInt().toString(),
          habitColor,
          Icons.bolt,
        ),
        _statItem(
          'Previous',
          previous.toInt().toString(),
          Colors.grey[600]!,
          Icons.history,
        ),
        _statItem(
          'Change',
          '${isUp ? '+' : ''}${diff.toInt()}',
          isUp ? Colors.green : Colors.red,
          isUp ? Icons.trending_up : Icons.trending_down,
        ),
      ],
    );
  }

  Widget _statItem(String label, String val, Color col, IconData icon) {
    return Column(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: col.withValues(alpha: 0.1),
          child: Icon(icon, size: 14, color: col),
        ),
        SizedBox(height: 6),
        Text(
          val,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: col,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildChartLegend(Color prevCol, Color currCol) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem('Previous', prevCol),
        SizedBox(width: 20),
        _legendItem('Current', currCol),
      ],
    );
  }

  Widget _legendItem(String txt, Color col) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: col,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 6),
        Text(txt, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildComparisonInsights(
    double current,
    double previous,
    Color habitColor,
  ) {
    final diff = current - previous;
    final isImproving = diff >= 0;
    final percent = previous > 0
        ? ((diff / previous) * 100).abs()
        : (current > 0 ? 100.0 : 0.0);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: habitColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: habitColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 18, color: habitColor),
              SizedBox(width: 8),
              Text(
                'Smart Insights',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: habitColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _insightRow(
            isImproving ? Icons.rocket_launch : Icons.lightbulb,
            isImproving
                ? 'Great job! You\'re up by ${percent.toStringAsFixed(0)}% compared to last period.'
                : 'You\'re slightly behind your last period. Try a small win today!',
            isImproving ? Colors.green : Colors.orange,
          ),
          if (current == 0 && previous > 0)
            _insightRow(
              Icons.warning_amber_rounded,
              'Don\'t let your streak slip! Start today to rebuild momentum.',
              Colors.red,
            ),
          if (current > widget.habit.bestStreak)
            _insightRow(
              Icons.emoji_events,
              'New Personal Record incoming! Keep pushing.',
              Colors.blue,
            ),
        ],
      ),
    );
  }

  Widget _insightRow(IconData icon, String text, Color col) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: col),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildActivityCalendar(bool isDark) {
    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? HelperFunctions.getColorById(
                    id: widget.habit.color,
                    isDarkMode: true,
                  )
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Activity Calendar',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildModernCalendar(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernCalendar(bool isDark) {
    final completedDates = _getCompletedDates();
    final habitColor = HelperFunctions.getColorById(id: widget.habit.color);

    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      availableGestures: AvailableGestures.horizontalSwipe,

      onPageChanged: (focusedDay) {
        setState(() => _focusedDay = focusedDay);
      },

      // Header styling
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: Theme.of(context).textTheme.titleMedium!,
        leftChevronIcon: Icon(Icons.chevron_left, color: habitColor, size: 24),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          color: habitColor,
          size: 24,
        ),
        headerPadding: EdgeInsets.symmetric(vertical: 16),
      ),

      // Days of week styling
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
          color: !isDark ? Colors.grey[600] : null,
        ),
        weekendStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
          color: !isDark ? Colors.grey[600] : null,
        ),
      ),

      // Calendar styling
      calendarStyle: CalendarStyle(
        // Default day style
        defaultTextStyle: TextStyle(
          color: isDark ? Colors.white : Colors.grey[800],
          fontWeight: FontWeight.w500,
        ),
        weekendTextStyle: TextStyle(
          color: isDark ? Colors.white : Colors.grey[800],
          fontWeight: FontWeight.w500,
        ),

        // Today styling
        todayDecoration: BoxDecoration(
          color: habitColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: HelperFunctions.getColorById(
              id: widget.habit.color,
              isDark: true,
            ),
            width: 2,
          ),
        ),
        todayTextStyle: TextStyle(
          color: habitColor,
          fontWeight: FontWeight.bold,
        ),

        // Selected day styling (for completed days)
        selectedDecoration: BoxDecoration(
          color: habitColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: habitColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        selectedTextStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
          fontWeight: FontWeight.bold,
          color: widget.habit.color == 12 ? Colors.black : Colors.white,
        ),

        // Outside days
        outsideTextStyle: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.normal,
        ),
      ),

      // Builders for custom day rendering
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (completedDates.any(
            (completedDate) =>
                completedDate.year == date.year &&
                completedDate.month == date.month &&
                completedDate.day == date.day,
          )) {
            return Positioned(
              bottom: 1,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: habitColor,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }
          return SizedBox.shrink();
        },
      ),

      // Selected day predicate
      selectedDayPredicate: (day) {
        return completedDates.any(
          (completedDate) =>
              completedDate.year == day.year &&
              completedDate.month == day.month &&
              completedDate.day == day.day,
        );
      },
    );
  }

  Set<DateTime> _getCompletedDates() {
    final completedDates = <DateTime>{};

    for (final dayMap in widget.habit.completedDays) {
      try {
        final dateStr = dayMap['date'] as String;
        final date = DateTime.parse(dateStr);
        completedDates.add(date);
      } catch (e) {
        // Ignore parse errors
        continue;
      }
    }

    return completedDates;
  }

  Map<int, int> _calculateMostActiveDays() {
    // keys: 0 = Mon, 1 = Tue, ... 6 = Sun
    final Map<int, int> dayCounts = {for (var i = 0; i < 7; i++) i: 0};

    for (final dayMap in widget.habit.completedDays) {
      try {
        final dateStr = dayMap['date'] as String;
        final date = DateTime.parse(dateStr);
        final count = (dayMap['count'] is int)
            ? (dayMap['count'] as int)
            : (int.tryParse(dayMap['count'].toString()) ?? 1);

        // DateTime.weekday: Monday = 1 ... Sunday = 7
        final index = (date.weekday - 1) % 7;
        dayCounts[index] = (dayCounts[index] ?? 0) + count;
      } catch (e) {
        // ignore parse errors for safety
        continue;
      }
    }

    return dayCounts;
  }

  Color _getBarColor(int dayIndex, int value) {
    final dayData = _calculateMostActiveDays();
    final maxValue = dayData.values.reduce((a, b) => a > b ? a : b);

    if (maxValue == 0) {
      return HelperFunctions.getColorById(
        id: widget.habit.color,
      ).withValues(alpha: 0.3);
    }

    final intensity = value / maxValue;
    return HelperFunctions.getColorById(
      id: widget.habit.color,
    ).withValues(alpha: 0.5 + intensity * 0.5);
  }
}
