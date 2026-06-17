import 'package:flutter/material.dart';

import '../common/field.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({
    required this.controller,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            '1日の目標上限 (g)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 12),
        SmallNumberField(controller: controller, onChanged: onChanged),
      ],
    );
  }
}
