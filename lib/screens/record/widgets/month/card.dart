import 'package:flutter/material.dart';

import '../../../../data/menu.dart';
import 'day_cell.dart';

class MonthCard extends StatelessWidget {
  const MonthCard({
    required this.visibleMonth,
    required this.recordsByDay,
    required this.scheduledDates,
    required this.onMonthChanged,
    required this.onDateTapped,
    super.key,
  });

  final DateTime visibleMonth;
  final Map<DateTime, List<Map<String, dynamic>>> recordsByDay;
  final Set<String> scheduledDates;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onDateTapped;

  @override
  Widget build(BuildContext context) {
    final cells = _calendarCells(visibleMonth);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    onMonthChanged(
                      DateTime(visibleMonth.year, visibleMonth.month - 1),
                    );
                  },
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '${visibleMonth.month}月 ${visibleMonth.year}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
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
            const SizedBox(height: 14),
            Row(
              children: const ['日', '月', '火', '水', '木', '金', '土']
                  .map(
                    (day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            color: Color(0xFF6B7280),
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
                final hasRecord =
                    recordsByDay[DateUtils.dateOnly(date)]?.isNotEmpty ?? false;
                final isToday = DateUtils.isSameDay(date, DateTime.now());
                final isScheduled = scheduledDates.contains(
                  formatDateKey(date),
                );

                return CalendarDayCell(
                  date: date,
                  inVisibleMonth: inVisibleMonth,
                  hasRecord: hasRecord,
                  isToday: isToday,
                  isScheduled: isScheduled,
                  onTap: () => onDateTapped(date),
                );
              },
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Legend(color: Color(0xFFBFDBFE), label: '飲酒日'),
                SizedBox(width: 18),
                _Legend(color: Color(0xFFEF4444), label: '今日'),
                SizedBox(width: 18),
                _Legend(color: Color(0xFF10B981), label: '予定日'),
              ],
            ),
          ],
        ),
      ),
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

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
