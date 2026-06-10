import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/menu.dart';

/// 記録画面（週間グラフと月間カレンダーを表示）。
class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  static const double _dailyAlcoholGoal = 20.0;
  static const double _caloriesPerAlcoholGram = 8.5;

  int _selectedPeriodIndex = 0; // 0: 週間, 1: 月間
  int _selectedChartDataType = 0; // 0: アルコール量, 1: カロリー
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: globalDrinkRecordsNotifier,
      builder: (context, records, child) {
        final weeklyData = _buildWeeklyData(records);
        final visibleMonthData = _buildMonthData(records, _visibleMonth);
        final summaryRecords = _selectedPeriodIndex == 0
            ? weeklyData.map((day) => day.records).expand((item) => item)
            : visibleMonthData.values.expand((item) => item);
        final summary = _buildSummary(summaryRecords.toList());

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '記録',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildPeriodSwitch(),
                const SizedBox(height: 24),
                if (_selectedPeriodIndex == 0)
                  _buildWeeklyCard(weeklyData)
                else
                  _buildMonthlyCalendarCard(visibleMonthData),
                const SizedBox(height: 20),
                _buildSummaryRow(summary),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPeriodSwitch() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [_buildPeriodTab('週間', 0), _buildPeriodTab('月間', 1)],
      ),
    );
  }

  Widget _buildPeriodTab(String text, int index) {
    final isSelected = _selectedPeriodIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriodIndex = index;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.black87 : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyCard(List<_DailyRecordSummary> weeklyData) {
    final isAlcohol = _selectedChartDataType == 0;
    final values = weeklyData
        .map((day) => isAlcohol ? day.alcoholGrams : day.calories.toDouble())
        .toList();
    final total = values.fold<double>(0, (sum, value) => sum + value);
    final maxValue = _chartMax(values, isAlcohol ? _dailyAlcoholGoal : null);
    final labels = weeklyData.map((day) => _weekdayLabel(day.date)).toList();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMetricSwitch(),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  isAlcohol
                      ? total.toStringAsFixed(1)
                      : total.round().toString(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isAlcohol ? 'g' : 'kcal',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _WeeklyBarChart(
              values: values,
              labels: labels,
              maxValue: maxValue,
              goalValue: isAlcohol ? _dailyAlcoholGoal : null,
              barColor: isAlcohol ? Colors.blue : Colors.orange,
              unit: isAlcohol ? 'g' : 'kcal',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricSwitch() {
    return Row(
      children: [
        _buildMetricButton('アルコール量', 0, Colors.blue),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text('|', style: TextStyle(color: Colors.grey[300])),
        ),
        _buildMetricButton('カロリー', 1, Colors.orange),
      ],
    );
  }

  Widget _buildMetricButton(String text, int index, MaterialColor color) {
    final isSelected = _selectedChartDataType == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedChartDataType = index;
        });
      },
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? color[700] : Colors.grey,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildMonthlyCalendarCard(
    Map<DateTime, List<Map<String, dynamic>>> recordsByDay,
  ) {
    final cells = _calendarCells(_visibleMonth);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      '${_visibleMonth.month}月 ${_visibleMonth.year}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _visibleMonth = DateTime(
                        _visibleMonth.year,
                        _visibleMonth.month - 1,
                      );
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _visibleMonth = DateTime(
                        _visibleMonth.year,
                        _visibleMonth.month + 1,
                      );
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: const ['日', '月', '火', '水', '木', '金', '土']
                  .map(
                    (day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: cells.length,
              itemBuilder: (context, index) {
                final date = cells[index];
                final inVisibleMonth = date.month == _visibleMonth.month;
                final hasRecord =
                    recordsByDay[DateUtils.dateOnly(date)]?.isNotEmpty ?? false;
                final isToday = DateUtils.isSameDay(date, DateTime.now());

                return _CalendarDayCell(
                  date: date,
                  inVisibleMonth: inVisibleMonth,
                  hasRecord: hasRecord,
                  isToday: isToday,
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend(color: Colors.blue[100]!, label: '飲酒日'),
                const SizedBox(width: 18),
                _buildLegend(color: Colors.red, label: '今日'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildSummaryRow(_RecordSummary summary) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: '休肝日達成',
            value: summary.restDays.toString(),
            unit: '日',
            backgroundColor: const Color(0xFFE8F6F0),
            textColor: const Color(0xFF0F7A59),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            title: '目標超過',
            value: summary.overGoalDays.toString(),
            unit: '日',
            backgroundColor: const Color(0xFFFFF4EC),
            textColor: const Color(0xFFD94D1A),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String unit,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: textColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(unit, style: TextStyle(color: textColor, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  List<_DailyRecordSummary> _buildWeeklyData(
    List<Map<String, dynamic>> records,
  ) {
    final today = DateUtils.dateOnly(DateTime.now());
    return List.generate(7, (index) {
      final date = today.subtract(Duration(days: 6 - index));
      final dayRecords = records.where((record) {
        final recordedAt = record['recordedAt'];
        return recordedAt is DateTime && DateUtils.isSameDay(recordedAt, date);
      }).toList();
      return _DailyRecordSummary(date: date, records: dayRecords);
    });
  }

  Map<DateTime, List<Map<String, dynamic>>> _buildMonthData(
    List<Map<String, dynamic>> records,
    DateTime month,
  ) {
    final result = <DateTime, List<Map<String, dynamic>>>{};
    for (final record in records) {
      final recordedAt = record['recordedAt'];
      if (recordedAt is! DateTime ||
          recordedAt.year != month.year ||
          recordedAt.month != month.month) {
        continue;
      }

      final day = DateUtils.dateOnly(recordedAt);
      result.putIfAbsent(day, () => []).add(record);
    }
    return result;
  }

  List<DateTime> _calendarCells(DateTime month) {
    final firstDay = DateTime(month.year, month.month);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final firstCell = firstDay.subtract(Duration(days: firstDay.weekday % 7));
    final daysToShow = firstCell.add(const Duration(days: 34)).isBefore(lastDay)
        ? 42
        : 35;
    return List.generate(
      daysToShow,
      (index) => firstCell.add(Duration(days: index)),
    );
  }

  _RecordSummary _buildSummary(List<Map<String, dynamic>> records) {
    final grouped = <DateTime, double>{};
    for (final record in records) {
      final recordedAt = record['recordedAt'];
      if (recordedAt is! DateTime) {
        continue;
      }

      final day = DateUtils.dateOnly(recordedAt);
      grouped[day] = (grouped[day] ?? 0) + _asDouble(record['alcoholGrams']);
    }

    final daysInScope = _selectedPeriodIndex == 0
        ? 7
        : DateUtils.getDaysInMonth(_visibleMonth.year, _visibleMonth.month);
    final drinkingDays = grouped.values.where((value) => value > 0).length;
    final overGoalDays = grouped.values
        .where((value) => value > _dailyAlcoholGoal)
        .length;

    return _RecordSummary(
      restDays: math.max(daysInScope - drinkingDays, 0),
      overGoalDays: overGoalDays,
    );
  }

  double _chartMax(List<double> values, double? goalValue) {
    final maxData = values.fold<double>(0, math.max);
    final rawMax = math.max(maxData, goalValue ?? 0);
    if (rawMax <= 0) {
      return goalValue ?? 1;
    }
    return (rawMax * 1.2).ceilToDouble();
  }

  static double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString()) ?? 0;
  }

  static String _weekdayLabel(DateTime date) {
    const labels = ['月', '火', '水', '木', '金', '土', '日'];
    return labels[date.weekday - 1];
  }
}

class _DailyRecordSummary {
  const _DailyRecordSummary({required this.date, required this.records});

  final DateTime date;
  final List<Map<String, dynamic>> records;

  double get alcoholGrams => records.fold<double>(0, (sum, record) {
    final value = record['alcoholGrams'];
    if (value is num) {
      return sum + value.toDouble();
    }
    return sum + (double.tryParse(value.toString()) ?? 0);
  });

  int get calories =>
      (alcoholGrams * _RecordScreenState._caloriesPerAlcoholGram).round();
}

class _RecordSummary {
  const _RecordSummary({required this.restDays, required this.overGoalDays});

  final int restDays;
  final int overGoalDays;
}

class _WeeklyBarChart extends StatelessWidget {
  const _WeeklyBarChart({
    required this.values,
    required this.labels,
    required this.maxValue,
    required this.barColor,
    required this.unit,
    this.goalValue,
  });

  final List<double> values;
  final List<String> labels;
  final double maxValue;
  final double? goalValue;
  final MaterialColor barColor;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final ticks = _ticks();

    return SizedBox(
      height: 300,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ticks
                  .map(
                    (tick) => Text(
                      _formatTick(tick),
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final plotHeight = constraints.maxHeight - 28;
                final goalTop = goalValue == null
                    ? null
                    : (plotHeight -
                          (goalValue!.clamp(0, maxValue) / maxValue) *
                              plotHeight);

                return Stack(
                  children: [
                    Positioned.fill(
                      bottom: 28,
                      child: CustomPaint(
                        painter: _ChartGuidePainter(
                          goalTop: goalTop,
                          goalLabel: goalValue == null ? null : '目標上限',
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(values.length, (index) {
                          final value = values[index];
                          final height = maxValue <= 0
                              ? 0.0
                              : (value / maxValue).clamp(0.0, 1.0) * plotHeight;

                          return Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  height: plotHeight,
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Tooltip(
                                      message:
                                          '${labels[index]}: ${_formatValue(value)} $unit',
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 180,
                                        ),
                                        width: 40,
                                        height: height,
                                        decoration: BoxDecoration(
                                          color: value > 0
                                              ? barColor[500]
                                              : Colors.transparent,
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(4),
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  labels[index],
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<double> _ticks() {
    return List.generate(5, (index) => maxValue - (maxValue / 4 * index));
  }

  String _formatTick(double value) {
    if (unit == 'kcal') {
      return value.round().toString();
    }
    return value == value.toInt()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }

  String _formatValue(double value) {
    if (unit == 'kcal') {
      return value.round().toString();
    }
    return value.toStringAsFixed(1);
  }
}

class _ChartGuidePainter extends CustomPainter {
  const _ChartGuidePainter({this.goalTop, this.goalLabel});

  final double? goalTop;
  final String? goalLabel;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFECEFF4)
      ..strokeWidth = 1;

    for (var i = 0; i <= 4; i++) {
      final y = size.height / 4 * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final top = goalTop;
    if (top == null) {
      return;
    }

    final goalPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 1;
    const dashWidth = 5.0;
    const dashSpace = 5.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, top),
        Offset(math.min(x + dashWidth, size.width), top),
        goalPaint,
      );
      x += dashWidth + dashSpace;
    }

    final label = goalLabel;
    if (label == null) {
      return;
    }

    final textPainter = TextPainter(
      text: const TextSpan(
        text: '目標上限',
        style: TextStyle(color: Colors.red, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(size.width / 2 - textPainter.width / 2, math.max(top - 16, 0)),
    );
  }

  @override
  bool shouldRepaint(covariant _ChartGuidePainter oldDelegate) {
    return oldDelegate.goalTop != goalTop || oldDelegate.goalLabel != goalLabel;
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.date,
    required this.inVisibleMonth,
    required this.hasRecord,
    required this.isToday,
  });

  final DateTime date;
  final bool inVisibleMonth;
  final bool hasRecord;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final textColor = inVisibleMonth ? Colors.black87 : Colors.grey[400];
    final backgroundColor = hasRecord ? Colors.blue[100] : Colors.transparent;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: isToday ? Border.all(color: Colors.red, width: 1.5) : null,
      ),
      alignment: Alignment.center,
      child: Text(
        date.day.toString(),
        style: TextStyle(
          color: textColor,
          fontWeight: hasRecord || isToday
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      ),
    );
  }
}
