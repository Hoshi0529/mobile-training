import 'package:flutter/material.dart';

import '../data/menu.dart';

/// ホーム画面（グラフと最近の記録を表示）。
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '今週の摂取量',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/graph.png',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.show_chart,
                              size: 64,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Text(
              '最近の記録',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: globalDrinkRecordsNotifier,
            builder: (context, records, child) {
              if (records.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text(
                    'まだ記録がありません',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              final itemCount = records.length < 3 ? records.length : 3;
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  final record = records[index];
                  final icon = record['icon'] as IconData;
                  final name = record['name'].toString();
                  final volume = record['volume'];
                  final abv = _asDouble(record['abv']);
                  final alcoholGrams = _asDouble(record['alcoholGrams']);

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.secondaryContainer,
                      child: Icon(
                        icon,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                      ),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      '${volume}ml • アルコール ${_formatNumber(abv)}% • ${alcoholGrams.toStringAsFixed(1)}g',
                    ),
                    trailing: Text(
                      _formatDateLabel(record['recordedAt']),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
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

  static String _formatDateLabel(dynamic value) {
    if (value is! DateTime) {
      return '';
    }

    final now = DateTime.now();
    if (DateUtils.isSameDay(value, now)) {
      return '今日';
    }

    final days = now.difference(value).inDays;
    return '$days日前';
  }
}
