import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../summary.dart';
import 'bar_chart.dart';

class WeekCard extends StatelessWidget {
  const WeekCard({
    required this.weeklyData,
    required this.dailyAlcoholGoal,
    required this.selectedMetricIndex,
    required this.onMetricChanged,
    super.key,
  });

  final List<DailyRecordSummary> weeklyData;
  final double dailyAlcoholGoal;
  final int selectedMetricIndex;
  final ValueChanged<int> onMetricChanged;

  @override
  Widget build(BuildContext context) {
    final isAlcohol = selectedMetricIndex == 0;
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
            _MetricSwitch(
              selectedIndex: selectedMetricIndex,
              onChanged: onMetricChanged,
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
            WeeklyBarChart(
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

  double _chartMax(List<double> values, double? goalValue) {
    final maxData = values.fold<double>(0, math.max);
    final rawMax = math.max(maxData, goalValue ?? 0);
    if (rawMax <= 0) {
      return goalValue ?? 1;
    }
    return (rawMax * 1.2).ceilToDouble();
  }

  String _weekdayLabel(DateTime date) {
    const labels = ['月', '火', '水', '木', '金', '土', '日'];
    return labels[date.weekday - 1];
  }
}

class _MetricSwitch extends StatelessWidget {
  const _MetricSwitch({required this.selectedIndex, required this.onChanged});

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MetricButton(
          text: 'アルコール量',
          index: 0,
          color: const Color(0xFF2563EB),
          isSelected: selectedIndex == 0,
          onChanged: onChanged,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('|', style: TextStyle(color: Colors.grey[300])),
        ),
        _MetricButton(
          text: 'カロリー',
          index: 1,
          color: const Color(0xFFF97316),
          isSelected: selectedIndex == 1,
          onChanged: onChanged,
        ),
      ],
    );
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
    return GestureDetector(
      onTap: () => onChanged(index),
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
}
