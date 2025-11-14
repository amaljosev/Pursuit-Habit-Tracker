import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          buildAppBar(widget),
          buildStatsOverview(context, _fadeAnimation, widget),
          _buildChartsSection(),
          _buildActivityCalendar(),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildChartsSection() {
    return SliverToBoxAdapter(
      child: Column(children: [_buildChartSelector(), _buildCurrentChart()]),
    );
  }

  Widget _buildChartSelector() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Wrap(
        runAlignment: WrapAlignment.center,
        children: [
          _buildChartTypeButton('Active Days', 0),
          _buildChartTypeButton('Streak Trend', 1),
          _buildChartTypeButton('Monthly Progress', 2),
        ],
      ),
    );
  }

  Widget _buildChartTypeButton(String label, int index) {
    final isSelected = _currentChartIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: () => setState(() => _currentChartIndex = index),
        style: TextButton.styleFrom(
          backgroundColor: isSelected
              ? HelperFunctions.getColorById(
                  id: widget.habit.color,
                ).withOpacity(0.1)
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? HelperFunctions.getColorById(
                    id: widget.habit.color,
                    isDark: true,
                  )
                : Colors.grey[600],
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentChart() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      child: Container(
        key: ValueKey(_currentChartIndex),
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: _getChartForIndex(_currentChartIndex),
      ),
    );
  }

  Widget _getChartForIndex(int index) {
    switch (index) {
      case 0:
        return _buildMostActiveDaysChart();
      case 1:
        return _buildStreakTrendChart();
      case 2:
        return _buildMonthlyComparisonChart();
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

  Widget _buildStreakTrendChart() {
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
                color: habitColor.withOpacity(0.1),
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
            color: Colors.grey[50],
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
                show: true,
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
                show: true,
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
                        habitColor.withOpacity(0.3),
                        habitColor.withOpacity(0.1),
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
                    color: habitColor.withOpacity(0.3),
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
          color: Colors.orange.withOpacity(0.5),
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
          ...insights
              .map(
                (insight) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ', style: TextStyle(color: Colors.blue[700])),
                      Expanded(
                        child: Text(
                          insight,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
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

  Widget _buildMonthlyComparisonChart() {
    final habitColor = HelperFunctions.getColorById(id: widget.habit.color);
    final previousColor = Colors.grey[400]!;

    // Data for all comparison periods
    final comparisonData = [
      {
        'label': 'Weekly',
        'current': widget.habit.countThisWeek.toDouble(),
        'previous': widget.habit.countLastWeek.toDouble(),
        'days': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      },
      {
        'label': 'Monthly',
        'current': widget.habit.countThisMonth.toDouble(),
        'previous': widget.habit.countLastMonth.toDouble(),
        'days': ['W1', 'W2', 'W3', 'W4'],
      },
      {
        'label': 'Yearly',
        'current': widget.habit.countThisYear.toDouble(),
        'previous': widget.habit.countLastYear.toDouble(),
        'days': ['Q1', 'Q2', 'Q3', 'Q4'],
      },
    ];

    final currentData = comparisonData[_currentComparisonPeriod];
    final currentValue = currentData['current'] as double;
    final previousValue = currentData['previous'] as double;
    final days = currentData['days'] as List<String>;

    // Create realistic sample data for demonstration
    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < days.length; i++) {
      // Create realistic sample values that add up to the total
      double currentBarValue =
          (currentValue / days.length) * (i + 0.5 + Random().nextDouble());
      double previousBarValue =
          (previousValue / days.length) * (i + 0.5 + Random().nextDouble());

      // Ensure values don't exceed the total
      currentBarValue = currentBarValue.clamp(0, currentValue);
      previousBarValue = previousBarValue.clamp(0, previousValue);

      barGroups.add(
        makeGroupData(
          i,
          previousBarValue,
          currentBarValue,
          previousColor,
          habitColor,
        ),
      );
    }

    // Calculate max Y value for the chart
    double maxY = 0;
    for (var group in barGroups) {
      for (var rod in group.barRods) {
        if (rod.toY > maxY) maxY = rod.toY;
      }
    }
    maxY = (maxY * 1.2).ceilToDouble(); // Add 20% padding

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with period selector
        Text(
          'Progress Comparison',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPeriodButton('Week', 0),
              _buildPeriodButton('Month', 1),
              _buildPeriodButton('Year', 2),
            ],
          ),
        ),
        SizedBox(height: 16),

        // Quick stats - Fixed to use proper values
        _buildComparisonQuickStats(currentValue, previousValue, habitColor),
        SizedBox(height: 20),

        // Double Bar Chart - Fixed implementation
        Container(
          height: 250,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: BarChart(
            BarChartData(
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final periodNames = ['Previous', 'Current'];
                    return BarTooltipItem(
                      '${periodNames[rodIndex]}\n${rod.toY.toStringAsFixed(1)}',
                      TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < days.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            days[index],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    reservedSize: 42,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      if (value == meta.min || value == meta.max) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              barGroups: barGroups,
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) {
                  return FlLine(color: Colors.grey[100]!, strokeWidth: 1);
                },
              ),
              alignment: BarChartAlignment.spaceAround,
              groupsSpace: 12, // Space between groups
              maxY: maxY,
            ),
          ),
        ),
        SizedBox(height: 16),

        // Legend
        _buildChartLegend(previousColor, habitColor),
        SizedBox(height: 16),

        // Insights
        _buildComparisonInsights(currentValue, previousValue, habitColor),
      ],
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double y1,
    double y2,
    Color leftColor,
    Color rightColor,
  ) {
    return BarChartGroupData(
      x: x,
      barsSpace: 8, // Space between bars in the same group
      barRods: [
        BarChartRodData(
          toY: y1,
          color: leftColor,
          width: 8, // Width of individual bars
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(2),
            topRight: Radius.circular(2),
          ),
        ),
        BarChartRodData(
          toY: y2,
          color: rightColor,
          width: 8,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(2),
            topRight: Radius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodButton(String label, int index) {
    final isSelected = _currentComparisonPeriod == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentComparisonPeriod = index),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? HelperFunctions.getColorById(id: widget.habit.color)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Fixed quick stats method
  Widget _buildComparisonQuickStats(
    double current,
    double previous,
    Color habitColor,
  ) {
    final difference = current - previous;
    final isImproving = difference >= 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildQuickStatItem(
          'Current',
          current.toInt().toString(),
          habitColor,
          Icons.trending_up,
        ),
        _buildQuickStatItem(
          'Previous',
          previous.toInt().toString(),
          Colors.grey[600]!,
          Icons.history,
        ),
        _buildQuickStatItem(
          'Change',
          '${isImproving ? '+' : ''}${difference.toInt()}',
          isImproving ? Colors.green : Colors.red,
          isImproving ? Icons.arrow_upward : Icons.arrow_downward,
        ),
      ],
    );
  }

  // Fixed stat item method
  Widget _buildQuickStatItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildChartLegend(Color previousColor, Color currentColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Previous Period', previousColor),
        SizedBox(width: 20),
        _buildLegendItem('Current Period', currentColor),
      ],
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildComparisonInsights(
    double current,
    double previous,
    Color habitColor,
  ) {
    final difference = current - previous;
    final percentageChange = previous > 0
        ? ((difference / previous) * 100).abs()
        : (current > 0 ? 100.0 : 0.0);
    final isImproving = difference >= 0;

    final insights = <Widget>[];

    if (current > previous) {
      insights.add(
        _buildInsightItem(
          Icons.rocket_launch,
          'Excellent progress! ${difference.toInt()} more than previous period',
          Colors.green,
        ),
      );
    } else if (current < previous) {
      insights.add(
        _buildInsightItem(
          Icons.lightbulb_outline,
          '${difference.abs().toInt()} less than previous period. Keep consistent!',
          Colors.orange,
        ),
      );
    } else {
      insights.add(
        _buildInsightItem(
          Icons.autorenew,
          'Steady performance - maintaining your habit consistently',
          Colors.blue,
        ),
      );
    }

    if (percentageChange > 25) {
      insights.add(
        _buildInsightItem(
          Icons.star,
          '${isImproving ? 'Significant improvement' : 'Noticeable decrease'} (${percentageChange.toStringAsFixed(1)}%)',
          isImproving ? Colors.green : Colors.red,
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: habitColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: habitColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, size: 16, color: habitColor),
              SizedBox(width: 8),
              Text(
                'Performance Insights',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: habitColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Column(children: insights),
        ],
      ),
    );
  }

  Widget _buildInsightItem(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildActivityCalendar() {
    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
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
                    ),
                  ),
                  _buildCalendarFormatToggle(),
                ],
              ),
              SizedBox(height: 16),
              _buildModernCalendar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarFormatToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFormatButton('Week', CalendarFormat.week),
          _buildFormatButton('Month', CalendarFormat.month),
        ],
      ),
    );
  }

  Widget _buildFormatButton(String label, CalendarFormat format) {
    final isSelected = _calendarFormat == format;
    return GestureDetector(
      onTap: () => setState(() => _calendarFormat = format),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? HelperFunctions.getColorById(id: widget.habit.color)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildModernCalendar() {
    final completedDates = _getCompletedDates();
    final habitColor = HelperFunctions.getColorById(id: widget.habit.color);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        onFormatChanged: (format) {
          setState(() => _calendarFormat = format);
        },
        onPageChanged: (focusedDay) {
          setState(() => _focusedDay = focusedDay);
        },

        // Header styling
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.grey[800],
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: habitColor,
            size: 24,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: habitColor,
            size: 24,
          ),
          headerPadding: EdgeInsets.symmetric(vertical: 16),
        ),

        // Days of week styling
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          weekendStyle: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),

        // Calendar styling
        calendarStyle: CalendarStyle(
          // Default day style
          defaultTextStyle: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
          weekendTextStyle: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),

          // Today styling
          todayDecoration: BoxDecoration(
            color: habitColor.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: habitColor, width: 2),
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
                color: habitColor.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          selectedTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),

          // Outside days
          outsideTextStyle: TextStyle(
            color: Colors.grey[400],
            fontWeight: FontWeight.normal,
          ),

          // Cell padding
          cellPadding: EdgeInsets.all(4),
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
      ),
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
      ).withOpacity(0.3);
    }

    final intensity = value / maxValue;
    return HelperFunctions.getColorById(
      id: widget.habit.color,
    ).withOpacity(0.5 + intensity * 0.5);
  }
}
