import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double _caloriesPerAlcoholGram = 8.5;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppSettings>(
      valueListenable: globalAppSettingsNotifier,
      builder: (context, settings, child) {
        return ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: globalDrinkRecordsNotifier,
          builder: (context, records, child) {
            final todayRecords = _todayRecords(records);
            final metabolismGramsPerHour = settings.metabolismGramsPerHour;
            final bodyAlcohol = _currentBodyAlcohol(
              records,
              metabolismGramsPerHour,
            );
            final minutesUntilClear = _minutesUntilClear(
              bodyAlcohol,
              metabolismGramsPerHour,
            );
            final todayCalories = _totalCalories(todayRecords);
            final todayAlcoholGrams = _totalAlcoholGrams(todayRecords);
            final soberStreak = _soberStreak(records, DateTime.now());
            final restDayStreak = _restDayStreak(
              records,
              settings,
              DateTime.now(),
            );
            final reminderCards = _buildReminderCards(settings);

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 104),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...reminderCards,
                  if (reminderCards.isNotEmpty) const SizedBox(height: 16),
                  _buildAlcoholStatusCard(
                    minutesUntilClear: minutesUntilClear,
                    bodyAlcohol: bodyAlcohol,
                    metabolismGramsPerHour: metabolismGramsPerHour,
                  ),
                  const SizedBox(height: 16),
                  _buildGoalCard(
                    todayAlcoholGrams: todayAlcoholGrams,
                    dailyGoalGrams: settings.dailyGoalGrams,
                  ),
                  const SizedBox(height: 16),
                  _buildStreakCard(
                    soberStreak: soberStreak,
                    restDayStreak: restDayStreak,
                    drinkCostYen: settings.drinkCostYen,
                    dailyGoalGrams: settings.dailyGoalGrams,
                  ),
                  const SizedBox(height: 24),
                  _buildTodayHeader(todayCalories),
                  const SizedBox(height: 12),
                  _buildTodayRecords(todayRecords),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildReminderCards(AppSettings settings) {
    final today = DateTime.now();
    final cards = <Widget>[];

    if (settings.reminderEnabled && isRestDay(today, settings)) {
      cards.add(
        _buildNoticeCard(
          icon: Icons.event_busy_outlined,
          title: '今日は休肝日です',
          message: '設定した休肝日です。飲酒予定がないか確認しましょう。',
          color: const Color(0xFF10B981),
          backgroundColor: const Color(0xFFECFDF5),
        ),
      );
    }

    if (settings.scheduledDrinkingDates.contains(formatDateKey(today))) {
      cards.add(
        _buildNoticeCard(
          icon: Icons.event_available_outlined,
          title: '今日は飲酒予定日です',
          message: '飲んだ量を忘れずに記録しましょう。',
          color: const Color(0xFF2563EB),
          backgroundColor: const Color(0xFFEFF6FF),
        ),
      );
    }

    return cards;
  }

  Widget _buildNoticeCard({
    required IconData icon,
    required String title,
    required String message,
    required Color color,
    required Color backgroundColor,
  }) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            _iconBubble(icon: icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Color(0xFF4B5563),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlcoholStatusCard({
    required int minutesUntilClear,
    required double bodyAlcohol,
    required double metabolismGramsPerHour,
  }) {
    final hours = minutesUntilClear ~/ 60;
    final minutes = minutesUntilClear % 60;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _iconBubble(
                  icon: Icons.directions_car_filled_outlined,
                  color: const Color(0xFFF97316),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '運転可能目安まで',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$hours',
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 4, right: 10, bottom: 5),
                  child: Text(
                    '時間',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  '$minutes',
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 5),
                  child: Text(
                    '分',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFED7AA)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '現在の体内アルコール量',
                    style: TextStyle(
                      color: Color(0xFF9A3412),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${bodyAlcohol.toStringAsFixed(1)} g',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '分解速度 ${metabolismGramsPerHour.toStringAsFixed(1)}g/時',
                    style: const TextStyle(
                      color: Color(0xFF9A3412),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard({
    required double todayAlcoholGrams,
    required double dailyGoalGrams,
  }) {
    final progress = dailyGoalGrams <= 0
        ? 0.0
        : (todayAlcoholGrams / dailyGoalGrams).clamp(0.0, 1.0);
    final isOverGoal = todayAlcoholGrams > dailyGoalGrams;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _iconBubble(
                  icon: Icons.track_changes_outlined,
                  color: isOverGoal
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF2563EB),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '今日の許容量',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  '${todayAlcoholGrams.toStringAsFixed(1)} / ${_formatNumber(dailyGoalGrams)}g',
                  style: TextStyle(
                    color: isOverGoal
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF2563EB),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                color: isOverGoal
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF2563EB),
                backgroundColor: const Color(0xFFE5E7EB),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isOverGoal ? '目標上限を超えています。今日はここで止めましょう。' : '目標上限内です。',
              style: TextStyle(
                color: isOverGoal
                    ? const Color(0xFFB91C1C)
                    : const Color(0xFF4B5563),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard({
    required int soberStreak,
    required int restDayStreak,
    required double drinkCostYen,
    required double dailyGoalGrams,
  }) {
    final savedYen = (soberStreak * drinkCostYen).round();
    final savedCalories =
        (soberStreak * dailyGoalGrams * _caloriesPerAlcoholGram).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _iconBubble(
                  icon: Icons.emoji_events_outlined,
                  color: const Color(0xFF10B981),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '継続バッジ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildMiniStat('未飲酒', '$soberStreak日')),
                const SizedBox(width: 10),
                Expanded(child: _buildMiniStat('休肝日', '$restDayStreak回')),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildMiniStat('節約目安', '$savedYen円')),
                const SizedBox(width: 10),
                Expanded(child: _buildMiniStat('削減目安', '$savedCalories kcal')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayHeader(int todayCalories) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            '今日の記録',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '摂取カロリー $todayCalories kcal',
            style: const TextStyle(
              color: Color(0xFFEA580C),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodayRecords(List<Map<String, dynamic>> todayRecords) {
    if (todayRecords.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              _iconBubble(
                icon: Icons.local_drink_outlined,
                color: const Color(0xFF6B7280),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'まだ今日の記録がありません',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: List.generate(todayRecords.length, (index) {
        final record = todayRecords[index];
        final name = record['name'].toString();
        final volume = record['volume'];
        final abv = _asDouble(record['abv']);
        final alcoholGrams = _asDouble(record['alcoholGrams']);
        final calories = _calories(alcoholGrams);
        final recordedAt = record['recordedAt'];
        final memo = record['memo']?.toString() ?? '';
        final icon = record['icon'] is IconData
            ? record['icon'] as IconData
            : Icons.local_drink_outlined;

        return Padding(
          padding: EdgeInsets.only(
            bottom: index == todayRecords.length - 1 ? 0 : 10,
          ),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  _iconBubble(icon: icon, color: const Color(0xFF2563EB)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${_formatTime(recordedAt)} ・ ${volume}ml ・ ${_formatNumber(abv)}%',
                          style: const TextStyle(color: Color(0xFF6B7280)),
                        ),
                        if (memo.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            memo,
                            style: const TextStyle(
                              color: Color(0xFF4B5563),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildBadge(
                        '${alcoholGrams.toStringAsFixed(1)}g',
                        const Color(0xFF2563EB),
                        const Color(0xFFEFF6FF),
                      ),
                      const SizedBox(height: 6),
                      _buildBadge(
                        '$calories kcal',
                        const Color(0xFFEA580C),
                        const Color(0xFFFFF7ED),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _iconBubble({required IconData icon, required Color color}) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  Widget _buildBadge(String text, Color color, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w800),
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

  static double _currentBodyAlcohol(
    List<Map<String, dynamic>> records,
    double metabolismGramsPerHour,
  ) {
    final now = DateTime.now();
    return records.fold<double>(0, (sum, record) {
      final recordedAt = record['recordedAt'];
      if (recordedAt is! DateTime) {
        return sum;
      }

      final alcoholGrams = _asDouble(record['alcoholGrams']);
      final elapsedHours = now.difference(recordedAt).inMinutes / 60;
      final remaining = alcoholGrams - (elapsedHours * metabolismGramsPerHour);
      return sum + math.max(remaining, 0);
    });
  }

  static int _minutesUntilClear(
    double bodyAlcohol,
    double metabolismGramsPerHour,
  ) {
    if (bodyAlcohol <= 0) {
      return 0;
    }
    return (bodyAlcohol / metabolismGramsPerHour * 60).ceil();
  }

  static int _totalCalories(List<Map<String, dynamic>> records) {
    return records.fold<int>(0, (sum, record) {
      return sum + _calories(_asDouble(record['alcoholGrams']));
    });
  }

  static double _totalAlcoholGrams(List<Map<String, dynamic>> records) {
    return records.fold<double>(0, (sum, record) {
      return sum + _asDouble(record['alcoholGrams']);
    });
  }

  static int _calories(double alcoholGrams) {
    return (alcoholGrams * _caloriesPerAlcoholGram).round();
  }

  static int _soberStreak(List<Map<String, dynamic>> records, DateTime today) {
    var streak = 0;
    var date = DateUtils.dateOnly(today);
    for (var i = 0; i < 365; i++) {
      if (_recordsForDate(records, date).isNotEmpty) {
        break;
      }
      streak++;
      date = date.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static int _restDayStreak(
    List<Map<String, dynamic>> records,
    AppSettings settings,
    DateTime today,
  ) {
    var streak = 0;
    var foundRestDay = false;
    var date = DateUtils.dateOnly(today);

    for (var i = 0; i < 365; i++) {
      if (isRestDay(date, settings)) {
        foundRestDay = true;
        if (_recordsForDate(records, date).isNotEmpty) {
          break;
        }
        streak++;
      } else if (foundRestDay && streak > 0) {
        return streak;
      }
      date = date.subtract(const Duration(days: 1));
    }

    return streak;
  }

  static List<Map<String, dynamic>> _recordsForDate(
    List<Map<String, dynamic>> records,
    DateTime date,
  ) {
    return records.where((record) {
      final recordedAt = record['recordedAt'];
      return recordedAt is DateTime && DateUtils.isSameDay(recordedAt, date);
    }).toList();
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
