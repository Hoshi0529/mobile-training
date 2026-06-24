import 'package:flutter/material.dart';

import '../../data/menu.dart';
import 'detail_sheet.dart';
import 'summary.dart';
import 'widgets/month/card.dart';
import 'widgets/month/chart_card.dart';
import 'widgets/period/switch.dart';
import 'widgets/stats/row.dart';
import 'widgets/week/card.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
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
                : _monthDates(_visibleMonth)
                      .where(
                        (date) =>
                            !date.isAfter(DateUtils.dateOnly(DateTime.now())),
                      )
                      .toList();
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
                  PeriodSwitch(
                    selectedIndex: _selectedPeriodIndex,
                    onChanged: (index) {
                      setState(() {
                        _selectedPeriodIndex = index;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  if (_selectedPeriodIndex == 0)
                    WeekCard(
                      weeklyData: weeklyData,
                      dailyAlcoholGoal: settings.dailyGoalGrams,
                      selectedMetricIndex: _selectedChartDataType,
                      onMetricChanged: (index) {
                        setState(() {
                          _selectedChartDataType = index;
                        });
                      },
                    )
                  else ...[
                    MonthCard(
                      visibleMonth: _visibleMonth,
                      recordsByDay: visibleMonthData,
                      scheduledDates: settings.scheduledDrinkingDates,
                      onMonthChanged: (month) {
                        setState(() {
                          _visibleMonth = month;
                        });
                      },
                      onDateTapped: (date) {
                        showDayRecordsSheet(context, date);
                      },
                    ),
                    const SizedBox(height: 16),
                    MonthChartCard(
                      visibleMonth: _visibleMonth,
                      recordsByDay: visibleMonthData,
                      selectedMetricIndex: _selectedChartDataType,
                      onMetricChanged: (index) {
                        setState(() {
                          _selectedChartDataType = index;
                        });
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  StatsRow(summary: summary),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<DailyRecordSummary> _buildWeeklyData(
    List<Map<String, dynamic>> records,
  ) {
    final today = DateUtils.dateOnly(DateTime.now());
    return List.generate(7, (index) {
      final date = today.subtract(Duration(days: 6 - index));
      final dayRecords = records.where((record) {
        final recordedAt = record['recordedAt'];
        return recordedAt is DateTime && DateUtils.isSameDay(recordedAt, date);
      }).toList();
      return DailyRecordSummary(date: date, records: dayRecords);
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

  List<DateTime> _monthDates(DateTime month) {
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    return List.generate(
      daysInMonth,
      (index) => DateTime(month.year, month.month, index + 1),
    );
  }

  RecordSummary _buildSummary(
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

    return RecordSummary(
      restDays: achievedRestDays,
      overGoalDays: overGoalDays,
    );
  }

  static double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString()) ?? 0;
  }
}
