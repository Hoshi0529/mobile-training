import 'package:flutter/material.dart';

class RestDayToggles extends StatelessWidget {
  const RestDayToggles({
    required this.restDays,
    required this.onChanged,
    super.key,
  });

  final List<bool> restDays;
  final void Function(int index, bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const days = ['日', '月', '火', '水', '木', '金', '土'];
        final itemSize = ((constraints.maxWidth - 24) / 7).clamp(30.0, 42.0);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(days.length, (index) {
            return _DayToggle(
              day: days[index],
              isSelected: index < restDays.length && restDays[index],
              size: itemSize,
              onTap: () {
                final currentValue = index < restDays.length && restDays[index];
                onChanged(index, !currentValue);
              },
            );
          }),
        );
      },
    );
  }
}

class _DayToggle extends StatelessWidget {
  const _DayToggle({
    required this.day,
    required this.isSelected,
    required this.size,
    required this.onTap,
  });

  final String day;
  final bool isSelected;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? const Color(0xFF10B981) : const Color(0xFFF3F4F6),
        ),
        alignment: Alignment.center,
        child: Text(
          day,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
