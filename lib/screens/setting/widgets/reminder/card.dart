import 'package:flutter/material.dart';

class ReminderCard extends StatelessWidget {
  const ReminderCard({
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text(
        '休肝日リマインダー',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
      subtitle: const Text(
        '休肝日の0時に通知します。端末側の通知許可も必要です。',
        style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
      ),
      trailing: Switch(
        value: enabled,
        onChanged: onChanged,
        activeThumbColor: Colors.white,
        activeTrackColor: const Color(0xFF2563EB),
      ),
    );
  }
}
