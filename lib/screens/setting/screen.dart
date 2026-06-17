import 'package:flutter/material.dart';

import '../../data/menu.dart';
import 'widgets/common/section.dart';
import 'widgets/goal/card.dart';
import 'widgets/menu/dialog.dart';
import 'widgets/menu/list.dart';
import 'widgets/profile/card.dart';
import 'widgets/reminder/card.dart';
import 'widgets/rest_days/toggles.dart';
import 'widgets/schedule/calendar.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final TextEditingController _weightController = TextEditingController(
    text: '60',
  );
  final TextEditingController _goalController = TextEditingController(
    text: '20',
  );
  final TextEditingController _factorController = TextEditingController(
    text: '1.0',
  );
  final TextEditingController _costController = TextEditingController(
    text: '500',
  );

  late List<bool> _restDays;
  late bool _reminderEnabled;
  late DateTime _visibleScheduleMonth;

  @override
  void initState() {
    super.initState();
    final settings = globalAppSettingsNotifier.value;
    _weightController.text = _formatNumber(settings.weightKg);
    _goalController.text = _formatNumber(settings.dailyGoalGrams);
    _factorController.text = settings.metabolismFactor.toStringAsFixed(1);
    _costController.text = _formatNumber(settings.drinkCostYen);
    _restDays = List<bool>.from(settings.restDays);
    _reminderEnabled = settings.reminderEnabled;
    final now = DateTime.now();
    _visibleScheduleMonth = DateTime(now.year, now.month);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _goalController.dispose();
    _factorController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 104),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '設定',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const SectionTitle(Icons.person_outline, 'プロフィール'),
          SettingCard(
            child: ProfileCard(
              weightController: _weightController,
              factorController: _factorController,
              onWeightChanged: (value) {
                final weight = double.tryParse(value.trim());
                if (weight != null) {
                  updateWeightKg(weight);
                }
              },
              onFactorChanged: (value) {
                final factor = double.tryParse(value.trim());
                if (factor != null) {
                  updateMetabolismFactor(factor);
                }
              },
            ),
          ),
          const SectionTitle(Icons.track_changes_outlined, '目標設定'),
          SettingCard(
            child: GoalCard(
              goalController: _goalController,
              costController: _costController,
              onGoalChanged: (value) {
                final goal = double.tryParse(value.trim());
                if (goal != null) {
                  updateDailyGoalGrams(goal);
                }
              },
              onCostChanged: (value) {
                final cost = double.tryParse(value.trim());
                if (cost != null) {
                  updateDrinkCostYen(cost);
                }
              },
            ),
          ),
          const SectionTitle(Icons.event_busy_outlined, '休肝日の設定'),
          SettingCard(
            child: RestDayToggles(
              restDays: _restDays,
              onChanged: (index, value) {
                setState(() {
                  _restDays[index] = value;
                });
                updateRestDay(index, value);
              },
            ),
          ),
          const SectionTitle(Icons.calendar_month_outlined, '飲酒予定日'),
          ValueListenableBuilder<AppSettings>(
            valueListenable: globalAppSettingsNotifier,
            builder: (context, settings, child) {
              return SettingCard(
                child: ScheduleCalendar(
                  visibleMonth: _visibleScheduleMonth,
                  scheduledDates: settings.scheduledDrinkingDates,
                  onMonthChanged: (month) {
                    setState(() {
                      _visibleScheduleMonth = month;
                    });
                  },
                  onDateTapped: (date) {
                    setState(() {
                      toggleScheduledDrinkingDate(date);
                    });
                  },
                ),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.only(left: 8, top: 8),
            child: Text(
              '予定日はカレンダーにハイライト表示されます。',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
            ),
          ),
          const SectionTitle(Icons.notifications_none_outlined, 'リマインダー'),
          SettingCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ReminderCard(
              enabled: _reminderEnabled,
              onChanged: (value) {
                setState(() {
                  _reminderEnabled = value;
                });
                updateReminderEnabled(value);
              },
            ),
          ),
          SectionTitle(
            Icons.add_circle_outline,
            '定番メニューの編集',
            trailing: TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const AddMenuDialog(),
                );
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('追加'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
                backgroundColor: const Color(0xFFEFF6FF),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
          const MenuList(),
        ],
      ),
    );
  }

  String _formatNumber(double value) {
    return value == value.toInt() ? value.toInt().toString() : value.toString();
  }
}
