import 'package:flutter/material.dart';

import '../../summary.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({required this.summary, super.key});

  final RecordSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatsCard(
            title: '休肝日達成',
            value: summary.restDays.toString(),
            unit: '日',
            backgroundColor: const Color(0xFFECFDF5),
            textColor: const Color(0xFF047857),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatsCard(
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
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.backgroundColor,
    required this.textColor,
  });

  final String title;
  final String value;
  final String unit;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
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
}
