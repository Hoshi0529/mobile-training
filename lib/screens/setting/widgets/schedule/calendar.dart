import 'package:flutter/material.dart';

import '../../../../data/menu.dart';

class ScheduleCalendar extends StatelessWidget {
  const ScheduleCalendar({
    required this.visibleMonth,
    required this.scheduledDates,
    required this.onMonthChanged,
    required this.onDateTapped,
    super.key,
  });

  final DateTime visibleMonth;
  final Set<String> scheduledDates;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onDateTapped;

  @override
  Widget build(BuildContext context) {
    const weekdays = ['日', '月', '火', '水', '木', '金', '土'];
    final cells = _calendarCells(visibleMonth);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  '${visibleMonth.month}月 ${visibleMonth.year}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                onMonthChanged(
                  DateTime(visibleMonth.year, visibleMonth.month - 1),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                onMonthChanged(
                  DateTime(visibleMonth.year, visibleMonth.month + 1),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: weekdays
              .map(
                (day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: cells.length,
          itemBuilder: (context, index) {
            final date = cells[index];
            final inVisibleMonth = date.month == visibleMonth.month;
            final isScheduled = scheduledDates.contains(formatDateKey(date));
            final isToday = DateUtils.isSameDay(date, DateTime.now());

            return InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => onDateTapped(date),
              child: Container(
                decoration: BoxDecoration(
                  color: isScheduled
                      ? const Color(0xFFD1FAE5)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: isToday
                      ? Border.all(color: const Color(0xFFEF4444), width: 1.5)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  date.day.toString(),
                  style: TextStyle(
                    color: inVisibleMonth
                        ? const Color(0xFF111827)
                        : const Color(0xFFD1D5DB),
                    fontSize: 14,
                    fontWeight: isScheduled ? FontWeight.w900 : FontWeight.w700,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  List<DateTime> _calendarCells(DateTime month) {
    final firstDay = DateTime(month.year, month.month);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final firstCell = firstDay.subtract(Duration(days: firstDay.weekday % 7));
    final daysToShow = firstCell.add(const Duration(days: 34)).isBefore(lastDay)
        ? 42
        : 35;
    return List.generate(
      daysToShow,
      (index) => firstCell.add(Duration(days: index)),
    );
  }
}
