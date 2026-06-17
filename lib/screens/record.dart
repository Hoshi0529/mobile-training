import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/menu.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  static const double _caloriesPerAlcoholGram = 8.5;

  int _selectedPeriodIndex = 0;
  int _selectedChartDataType = 0;
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppSettings>(
      valueListenable: globalAppSettingsNotifier,
      builder: (context, settings, child) {
        return ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: globalDrinkRecordsNotifier,
          builder: (context, records, child) {
            final weeklyData = _buildWeeklyData(records);
            final visibleMonthData = _buildMonthData(records, _visibleMonth);
            final summaryRecords = _selectedPeriodIndex == 0
                ? weeklyData.map((day) => day.records).expand((item) => item)
                : visibleMonthData.values.expand((item) => item);
            final scopeDates = _selectedPeriodIndex == 0
                ? weeklyData.map((day) => day.date).toList()
                : _monthDates(_visibleMonth);
            final summary = _buildSummary(
              summaryRecords.toList(),
              scopeDates,
              settings,
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 104),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '記録',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 18),
                  _buildPeriodSwitch(),
                  const SizedBox(height: 20),
                  if (_selectedPeriodIndex == 0)
                    _buildWeeklyCard(weeklyData, settings.dailyGoalGrams)
                  else
                    _buildMonthlyCalendarCard(visibleMonthData, settings),
                  const SizedBox(height: 16),
                  _buildSummaryRow(summary),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPeriodSwitch() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
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
              fontWeight: FontWeight.w800,
              color: isSelected
                  ? const Color(0xFF111827)
                  : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyCard(
    List<_DailyRecordSummary> weeklyData,
    double dailyAlcoholGoal,
  ) {
    final isAlcohol = _selectedChartDataType == 0;
    final values = weeklyData
        .map((day) => isAlcohol ? day.alcoholGrams : day.calories.toDouble())
        .toList();
    final total = values.fold<double>(0, (sum, value) => sum + value);
    final maxValue = _chartMax(values, isAlcohol ? dailyAlcoholGoal : null);
    final labels = weeklyData.map((day) => _weekdayLabel(day.date)).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMetricSwitch(),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  isAlcohol
                      ? total.toStringAsFixed(1)
                      : total.round().toString(),
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isAlcohol ? 'g' : 'kcal',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _WeeklyBarChart(
              values: values,
              labels: labels,
              maxValue: maxValue,
              goalValue: isAlcohol ? dailyAlcoholGoal : null,
              barColor: isAlcohol
                  ? const Color(0xFF2563EB)
                  : const Color(0xFFF97316),
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
        _buildMetricButton('アルコール量', 0, const Color(0xFF2563EB)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('|', style: TextStyle(color: Colors.grey[300])),
        ),
        _buildMetricButton('カロリー', 1, const Color(0xFFF97316)),
      ],
    );
  }

  Widget _buildMetricButton(String text, int index, Color color) {
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
          color: isSelected ? color : const Color(0xFF9CA3AF),
          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildMonthlyCalendarCard(
    Map<DateTime, List<Map<String, dynamic>>> recordsByDay,
    AppSettings settings,
  ) {
    final cells = _calendarCells(_visibleMonth);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
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
                Expanded(
                  child: Center(
                    child: Text(
                      '${_visibleMonth.month}月 ${_visibleMonth.year}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
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
            const SizedBox(height: 14),
            Row(
              children: const ['日', '月', '火', '水', '木', '金', '土']
                  .map(
                    (day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w800,
                          ),
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
                final isScheduled = settings.scheduledDrinkingDates.contains(
                  formatDateKey(date),
                );

                return _CalendarDayCell(
                  date: date,
                  inVisibleMonth: inVisibleMonth,
                  hasRecord: hasRecord,
                  isToday: isToday,
                  isScheduled: isScheduled,
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend(color: const Color(0xFFBFDBFE), label: '飲酒日'),
                const SizedBox(width: 18),
                _buildLegend(color: const Color(0xFFEF4444), label: '今日'),
                const SizedBox(width: 18),
                _buildLegend(color: const Color(0xFF10B981), label: '予定日'),
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
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w700,
          ),
        ),
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
            backgroundColor: const Color(0xFFECFDF5),
            textColor: const Color(0xFF047857),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            title: '目標超過',
            value: summary.overGoalDays.toString(),
            unit: '日',
            backgroundColor: const Color(0xFFFFF7ED),
            textColor: const Color(0xFFEA580C),
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: textColor.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w900,
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
                  fontWeight: FontWeight.w900,
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

  List<DateTime> _monthDates(DateTime month) {
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    return List.generate(
      daysInMonth,
      (index) => DateTime(month.year, month.month, index + 1),
    );
  }

  _RecordSummary _buildSummary(
    List<Map<String, dynamic>> records,
    List<DateTime> scopeDates,
    AppSettings settings,
  ) {
    final grouped = <DateTime, double>{};
    for (final record in records) {
      final recordedAt = record['recordedAt'];
      if (recordedAt is! DateTime) {
        continue;
      }

      final day = DateUtils.dateOnly(recordedAt);
      grouped[day] = (grouped[day] ?? 0) + _asDouble(record['alcoholGrams']);
    }

    final achievedRestDays = scopeDates.where((date) {
      final alcoholGrams = grouped[DateUtils.dateOnly(date)] ?? 0;
      return isRestDay(date, settings) && alcoholGrams <= 0;
    }).length;
    final overGoalDays = grouped.values
        .where((value) => value > settings.dailyGoalGrams)
        .length;

    return _RecordSummary(
      restDays: achievedRestDays,
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
  final Color barColor;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final ticks = _ticks();

    return SizedBox(
      height: 292,
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
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 12,
                      ),
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
                    : plotHeight -
                          (goalValue!.clamp(0, maxValue) / maxValue) *
                              plotHeight;

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
                                        width: 36,
                                        height: height,
                                        decoration: BoxDecoration(
                                          color: value > 0
                                              ? barColor
                                              : Colors.transparent,
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(6),
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  labels[index],
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
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
      ..color = const Color(0xFFE5E7EB)
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
      ..color = const Color(0xFFEF4444)
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
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Color(0xFFEF4444),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
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
    required this.isScheduled,
  });

  final DateTime date;
  final bool inVisibleMonth;
  final bool hasRecord;
  final bool isToday;
  final bool isScheduled;

  @override
  Widget build(BuildContext context) {
    final textColor = inVisibleMonth
        ? const Color(0xFF111827)
        : const Color(0xFFD1D5DB);
    final backgroundColor = hasRecord
        ? const Color(0xFFDBEAFE)
        : Colors.transparent;

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: isToday
                ? Border.all(color: const Color(0xFFEF4444), width: 1.5)
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            date.day.toString(),
            style: TextStyle(
              color: textColor,
              fontWeight: hasRecord || isToday
                  ? FontWeight.w900
                  : FontWeight.w600,
            ),
          ),
        ),
        if (isScheduled)
          Positioned(
            bottom: 4,
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
