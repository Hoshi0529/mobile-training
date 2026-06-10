import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/menu.dart';

/// ホーム画面（現在の体内アルコール量と今日の記録を表示）。
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const double _metabolismGramsPerHour = 5.0;
  static const double _caloriesPerAlcoholGram = 8.5;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: globalDrinkRecordsNotifier,
      builder: (context, records, child) {
        final todayRecords = _todayRecords(records);
        final bodyAlcohol = _currentBodyAlcohol(records);
        final minutesUntilClear = _minutesUntilClear(bodyAlcohol);
        final todayCalories = _totalCalories(todayRecords);

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              _buildAlcoholStatusCard(
                minutesUntilClear: minutesUntilClear,
                bodyAlcohol: bodyAlcohol,
              ),
              const SizedBox(height: 24),
              _buildTodayHeader(todayCalories),
              _buildTodayRecords(context, todayRecords),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlcoholStatusCard({
    required int minutesUntilClear,
    required double bodyAlcohol,
  }) {
    final hours = minutesUntilClear ~/ 60;
    final minutes = minutesUntilClear % 60;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.directions_car, color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  const Text(
                    '運転可能目安まで',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$hours',
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      '時間',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '$minutes',
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      '分',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '現在の体内アルコール量',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${bodyAlcohol.toStringAsFixed(1)} g',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayHeader(int todayCalories) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              '今日の記録',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: '摂取カロリー: ',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: '$todayCalories',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(
                  text: ' kcal',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayRecords(
    BuildContext context,
    List<Map<String, dynamic>> todayRecords,
  ) {
    if (todayRecords.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Text('まだ今日の記録がありません', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: todayRecords.length,
      itemBuilder: (context, index) {
        final record = todayRecords[index];
        final name = record['name'].toString();
        final volume = record['volume'];
        final abv = _asDouble(record['abv']);
        final alcoholGrams = _asDouble(record['alcoholGrams']);
        final calories = _calories(alcoholGrams);
        final recordedAt = record['recordedAt'];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade100),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_formatTime(recordedAt)} • ${volume}ml • ${_formatNumber(abv)}%',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildBadge(
                        '${alcoholGrams.toStringAsFixed(1)}g',
                        Colors.blue,
                      ),
                      const SizedBox(height: 6),
                      _buildBadge('$calories kcal', Colors.orange),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadge(String text, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(color: color[700], fontWeight: FontWeight.bold),
      ),
    );
  }

  static List<Map<String, dynamic>> _todayRecords(
    List<Map<String, dynamic>> records,
  ) {
    final now = DateTime.now();
    return records.where((record) {
      final recordedAt = record['recordedAt'];
      return recordedAt is DateTime && DateUtils.isSameDay(recordedAt, now);
    }).toList();
  }

  static double _currentBodyAlcohol(List<Map<String, dynamic>> records) {
    final now = DateTime.now();
    return records.fold<double>(0, (sum, record) {
      final recordedAt = record['recordedAt'];
      if (recordedAt is! DateTime) {
        return sum;
      }

      final alcoholGrams = _asDouble(record['alcoholGrams']);
      final elapsedHours = now.difference(recordedAt).inMinutes / 60;
      final remaining = alcoholGrams - (elapsedHours * _metabolismGramsPerHour);
      return sum + math.max(remaining, 0);
    });
  }

  static int _minutesUntilClear(double bodyAlcohol) {
    if (bodyAlcohol <= 0) {
      return 0;
    }
    return (bodyAlcohol / _metabolismGramsPerHour * 60).ceil();
  }

  static int _totalCalories(List<Map<String, dynamic>> records) {
    return records.fold<int>(0, (sum, record) {
      return sum + _calories(_asDouble(record['alcoholGrams']));
    });
  }

  static int _calories(double alcoholGrams) {
    return (alcoholGrams * _caloriesPerAlcoholGram).round();
  }

  static double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString()) ?? 0;
  }

  static String _formatNumber(double value) {
    return value == value.toInt() ? value.toInt().toString() : value.toString();
  }

  static String _formatTime(dynamic value) {
    if (value is! DateTime) {
      return '';
    }

    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
