import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pursuit/core/functions/helper_functions.dart';
import 'package:pursuit/features/habit/domain/entities/habit.dart';

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
          _buildAppBar(),
          _buildStatsOverview(),
          _buildChartsSection(),
          _buildActivityCalendar(),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      backgroundColor: HelperFunctions.getColorById(
        id: widget.habit.color,
        isDark: true,
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Habit Analytics',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                HelperFunctions.getColorById(
                  id: widget.habit.color,
                ).withValues(alpha: 0.3),
                HelperFunctions.getColorById(id: widget.habit.color),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildStatsOverview() {
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                '🔥',
                'Current Streak',
                '${widget.habit.streakCount} days',
              ),
              _buildStatItem(
                '⭐',
                'Best Streak',
                '${widget.habit.bestStreak} days',
              ),
              _buildStatItem(
                '📈',
                'Completion',
                '${_calculateCompletionRate()}%',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: TextStyle(fontSize: 24)),
        SizedBox(height: 8),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
    return Expanded(
      child: Padding(
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Streak Trend',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              minY: 0,
              lineTouchData: LineTouchData(enabled: true),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: streakData.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value.toDouble());
                  }).toList(),
                  isCurved: true,
                  color: HelperFunctions.getColorById(id: widget.habit.color),
                  barWidth: 4,
                  belowBarData: BarAreaData(
                    show: true,
                    color: HelperFunctions.getColorById(
                      id: widget.habit.color,
                    ).withValues(alpha: 0.1),
                  ),
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyComparisonChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Comparison',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY:
                  (widget.habit.countThisMonth > widget.habit.countLastMonth
                          ? widget.habit.countThisMonth
                          : widget.habit.countLastMonth)
                      .toDouble() +
                  2,
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final labels = ['Last Month', 'This Month'];
                      return value.toInt() < labels.length
                          ? Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                labels[value.toInt()],
                                style: TextStyle(fontSize: 10),
                              ),
                            )
                          : SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: widget.habit.countLastMonth.toDouble(),
                      color: Colors.grey[300]!,
                      width: 20,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: widget.habit.countThisMonth.toDouble(),
                      color: HelperFunctions.getColorById(
                        id: widget.habit.color,
                      ),
                      width: 20,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
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
              Text(
                'Activity Calender',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
              ),
              _buildHeatmap(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeatmap() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: 31,
      itemBuilder: (context, index) {
        final day = index + 1;
        final isCompleted = widget.habit.completedDays.any((dayMap) {
          final date = DateTime.parse(dayMap['date']);
          return date.day == day;
        });

        return Container(
          decoration: BoxDecoration(
            color: isCompleted
                ? HelperFunctions.getColorById(id: widget.habit.color)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              day.toString(),
              style: TextStyle(
                fontSize: 10,
                color: isCompleted ? Colors.white : Colors.grey[600],
                fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper Methods
  int _calculateCompletionRate() {
    if (widget.habit.goalCount == 0) return 0;
    return ((widget.habit.goalCompletedCount / widget.habit.goalCount) * 100)
        .round();
  }

  Map<int, int> _calculateMostActiveDays() {
    // Simplified - in real app, analyze completedDays to find actual patterns
    final Map<int, int> dayCounts = {};
    for (int i = 0; i < 7; i++) {
      dayCounts[i] = (widget.habit.completedDays.length / 7).round() + (i % 3);
    }
    return dayCounts;
  }

  List<int> _generateStreakTrendData() {
    // Generate sample trend data based on streak history
    return List.generate(7, (index) {
      final base = widget.habit.streakCount;
      return (base * (0.7 + 0.3 * (index / 6))).round();
    });
  }

  Color _getBarColor(int dayIndex, int value) {
    final maxValue = _calculateMostActiveDays().values.reduce(
      (a, b) => a > b ? a : b,
    );
    final intensity = value / maxValue;
    return HelperFunctions.getColorById(
      id: widget.habit.color,
    ).withValues(alpha: 0.5 + intensity * 0.5);
  }
}
