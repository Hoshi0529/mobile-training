import 'dart:math' as math;

import 'package:flutter/material.dart';

class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({
    required this.values,
    required this.labels,
    required this.maxValue,
    required this.barColor,
    required this.unit,
    this.goalValue,
    super.key,
  });

  final List<double> values;
  final List<String> labels;
  final double maxValue;
  final double? goalValue;
  final Color barColor;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final ticks = _ticks();

    return SizedBox(
      height: 292,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ticks
                  .map(
                    (tick) => Text(
                      _formatTick(tick),
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 12,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final plotHeight = constraints.maxHeight - 28;
                final goalTop = goalValue == null
                    ? null
                    : plotHeight -
                          (goalValue!.clamp(0, maxValue) / maxValue) *
                              plotHeight;

                return Stack(
                  children: [
                    Positioned.fill(
                      bottom: 28,
                      child: CustomPaint(
                        painter: _ChartGuidePainter(
                          goalTop: goalTop,
                          goalLabel: goalValue == null ? null : '目標上限',
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(values.length, (index) {
                          final value = values[index];
                          final height = maxValue <= 0
                              ? 0.0
                              : (value / maxValue).clamp(0.0, 1.0) * plotHeight;

                          return Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  height: plotHeight,
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Tooltip(
                                      message:
                                          '${labels[index]}: ${_formatValue(value)} $unit',
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 180,
                                        ),
                                        width: 36,
                                        height: height,
                                        decoration: BoxDecoration(
                                          color: value > 0
                                              ? barColor
                                              : Colors.transparent,
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(6),
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  labels[index],
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<double> _ticks() {
    return List.generate(5, (index) => maxValue - (maxValue / 4 * index));
  }

  String _formatTick(double value) {
    if (unit == 'kcal') {
      return value.round().toString();
    }
    return value == value.toInt()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }

  String _formatValue(double value) {
    if (unit == 'kcal') {
      return value.round().toString();
    }
    return value.toStringAsFixed(1);
  }
}

class _ChartGuidePainter extends CustomPainter {
  const _ChartGuidePainter({this.goalTop, this.goalLabel});

  final double? goalTop;
  final String? goalLabel;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;

    for (var i = 0; i <= 4; i++) {
      final y = size.height / 4 * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final top = goalTop;
    if (top == null) {
      return;
    }

    final goalPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..strokeWidth = 1;
    const dashWidth = 5.0;
    const dashSpace = 5.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, top),
        Offset(math.min(x + dashWidth, size.width), top),
        goalPaint,
      );
      x += dashWidth + dashSpace;
    }

    final label = goalLabel;
    if (label == null) {
      return;
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Color(0xFFEF4444),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(size.width / 2 - textPainter.width / 2, math.max(top - 16, 0)),
    );
  }

  @override
  bool shouldRepaint(covariant _ChartGuidePainter oldDelegate) {
    return oldDelegate.goalTop != goalTop || oldDelegate.goalLabel != goalLabel;
  }
}
