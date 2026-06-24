import 'package:flutter/material.dart';

class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({
    required this.date,
    required this.inVisibleMonth,
    required this.hasRecord,
    required this.isToday,
    required this.isScheduled,
    required this.onTap,
    super.key,
  });

  final DateTime date;
  final bool inVisibleMonth;
  final bool hasRecord;
  final bool isToday;
  final bool isScheduled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = inVisibleMonth
        ? const Color(0xFF111827)
        : const Color(0xFFD1D5DB);
    final backgroundColor = hasRecord
        ? const Color(0xFFDBEAFE)
        : Colors.transparent;

    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Stack(
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
      ),
    );
  }
}
