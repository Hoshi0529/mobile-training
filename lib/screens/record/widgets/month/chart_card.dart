import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../summary.dart';
import '../week/bar_chart.dart';

class MonthChartCard extends StatelessWidget {
  const MonthChartCard({
    required this.visibleMonth,
    required this.recordsByDay,
    required this.selectedMetricIndex,
    required this.onMetricChanged,
    super.key,
  });

  final DateTime visibleMonth;
  final Map<DateTime, List<Map<String, dynamic>>> recordsByDay;
  final int selectedMetricIndex;
  final ValueChanged<int> onMetricChanged;

  @override
  Widget build(BuildContext context) {
    final isAlcohol = selectedMetricIndex == 0;
    final daysInMonth = DateUtils.getDaysInMonth(
      visibleMonth.year,
      visibleMonth.month,
    );
    final bucketCount = (daysInMonth / 7).ceil();
    final values = List<double>.generate(bucketCount, (index) {
      final firstDay = index * 7 + 1;
      final lastDay = math.min(firstDay + 6, daysInMonth);
      var total = 0.0;
      for (var day = firstDay; day <= lastDay; day++) {
        final records =
            recordsByDay[DateTime(
              visibleMonth.year,
              visibleMonth.month,
              day,
            )] ??
            const <Map<String, dynamic>>[];
        final summary = DailyRecordSummary(
          date: DateTime(visibleMonth.year, visibleMonth.month, day),
          records: records,
        );
        total += isAlcohol ? summary.alcoholGrams : summary.calories.toDouble();
      }
      return total;
    });
    final labels = List.generate(bucketCount, (index) => '${index + 1}週');
    final total = values.fold<double>(0, (sum, value) => sum + value);
    final maxValue = _chartMax(values);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '月間推移',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _MetricButton(
                  text: 'アルコール量',
                  index: 0,
                  color: const Color(0xFF2563EB),
                  isSelected: isAlcohol,
                  onChanged: onMetricChanged,
                ),
                const SizedBox(width: 20),
                _MetricButton(
                  text: 'カロリー',
                  index: 1,
                  color: const Color(0xFFF97316),
                  isSelected: !isAlcohol,
                  onChanged: onMetricChanged,
                ),
              ],
            ),
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
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isAlcohol ? 'g' : 'kcal',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            WeeklyBarChart(
              values: values,
              labels: labels,
              maxValue: maxValue,
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

  double _chartMax(List<double> values) {
    final maxData = values.fold<double>(0, math.max);
    return maxData <= 0 ? 1 : (maxData * 1.2).ceilToDouble();
  }
}

class _MetricButton extends StatelessWidget {
  const _MetricButton({
    required this.text,
    required this.index,
    required this.color,
    required this.isSelected,
    required this.onChanged,
  });

  final String text;
  final int index;
  final Color color;
  final bool isSelected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => onChanged(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? color : const Color(0xFF9CA3AF),
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
