import 'package:flutter/material.dart';

import '../common/field.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    required this.controller,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                '体重 (kg)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 12),
            SmallNumberField(controller: controller, onChanged: onChanged),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          'アルコール分解時間の計算に使用します。',
          style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
        ),
      ],
    );
  }
}
