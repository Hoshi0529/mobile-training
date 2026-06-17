import 'package:flutter/material.dart';

class PeriodSwitch extends StatelessWidget {
  const PeriodSwitch({
    required this.selectedIndex,
    required this.onChanged,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _PeriodTab(
            text: '週間',
            index: 0,
            isSelected: selectedIndex == 0,
            onChanged: onChanged,
          ),
          _PeriodTab(
            text: '月間',
            index: 1,
            isSelected: selectedIndex == 1,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _PeriodTab extends StatelessWidget {
  const _PeriodTab({
    required this.text,
    required this.index,
    required this.isSelected,
    required this.onChanged,
  });

  final String text;
  final int index;
  final bool isSelected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isSelected
                  ? const Color(0xFF111827)
                  : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }
}
