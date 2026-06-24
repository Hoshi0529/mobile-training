import 'package:flutter/material.dart';

import '../common/field.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    required this.weightController,
    required this.factorController,
    required this.onWeightChanged,
    required this.onFactorChanged,
    super.key,
  });

  final TextEditingController weightController;
  final TextEditingController factorController;
  final ValueChanged<String> onWeightChanged;
  final ValueChanged<String> onFactorChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProfileRow(
          label: '体重 (kg)',
          child: SmallNumberField(
            controller: weightController,
            onChanged: onWeightChanged,
          ),
        ),
        const SizedBox(height: 14),
        _ProfileRow(
          label: '体質係数',
          child: SmallNumberField(
            controller: factorController,
            onChanged: onFactorChanged,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          '体重は500kg以下、体質係数は0.5〜1.5で入力してください。'
          '1.0が標準で、低めにすると分解時間が長くなります。',
          style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
        ),
      ],
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, required this.child});

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
