import 'package:flutter/material.dart';

import '../common/field.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({
    required this.goalController,
    required this.costController,
    required this.onGoalChanged,
    required this.onCostChanged,
    super.key,
  });

  final TextEditingController goalController;
  final TextEditingController costController;
  final ValueChanged<String> onGoalChanged;
  final ValueChanged<String> onCostChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GoalRow(
          label: '1日の目標上限 (g)',
          child: SmallNumberField(
            controller: goalController,
            onChanged: onGoalChanged,
          ),
        ),
        const SizedBox(height: 14),
        _GoalRow(
          label: '飲酒1回の目安 (円)',
          child: SmallNumberField(
            controller: costController,
            onChanged: onCostChanged,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          '目標上限は500g以下で入力してください。'
          '金額は休肝日や未飲酒日の節約目安に使います。',
          style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
        ),
      ],
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 12),
        child,
      ],
    );
  }
}
