import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/menu.dart';

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

  late List<bool> _restDays;
  late bool _reminderEnabled;
  late DateTime _visibleScheduleMonth;

  @override
  void initState() {
    super.initState();
    final settings = globalAppSettingsNotifier.value;
    _weightController.text = _formatNumber(settings.weightKg);
    _goalController.text = _formatNumber(settings.dailyGoalGrams);
    _restDays = List<bool>.from(settings.restDays);
    _reminderEnabled = settings.reminderEnabled;
    final now = DateTime.now();
    _visibleScheduleMonth = DateTime(now.year, now.month);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _goalController.dispose();
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
          _buildSectionTitle(Icons.person_outline, 'プロフィール'),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '体重 (kg)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildSmallTextField(
                      _weightController,
                      onChanged: (value) {
                        final weight = double.tryParse(value.trim());
                        if (weight != null) {
                          updateWeightKg(weight);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'アルコール分解時間の計算に使用します。',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                ),
              ],
            ),
          ),
          _buildSectionTitle(Icons.track_changes_outlined, '目標設定'),
          _buildCard(
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '1日の目標上限 (g)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 12),
                _buildSmallTextField(
                  _goalController,
                  onChanged: (value) {
                    final goal = double.tryParse(value.trim());
                    if (goal != null) {
                      updateDailyGoalGrams(goal);
                    }
                  },
                ),
              ],
            ),
          ),
          _buildSectionTitle(Icons.event_busy_outlined, '休肝日の設定'),
          _buildCard(child: _buildRestDayToggles()),
          _buildSectionTitle(Icons.calendar_month_outlined, '飲酒予定日'),
          _buildCard(child: _buildCalendarMock()),
          const Padding(
            padding: EdgeInsets.only(left: 8, top: 8),
            child: Text(
              '予定日はカレンダーにハイライト表示されます。',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
            ),
          ),
          _buildSectionTitle(Icons.notifications_none_outlined, 'リマインダー'),
          _buildCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                '休肝日リマインダー',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              subtitle: const Text(
                '休肝日の夕方に通知を送ります。',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
              ),
              trailing: Switch(
                value: _reminderEnabled,
                onChanged: (value) {
                  setState(() {
                    _reminderEnabled = value;
                  });
                  updateReminderEnabled(value);
                },
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFF2563EB),
              ),
            ),
          ),
          _buildSectionTitle(
            Icons.add_circle_outline,
            '定番メニューの編集',
            trailing: TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const _AddMenuDialog(),
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
          ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: globalMenuItemsNotifier,
            builder: (context, menuItems, child) {
              return _buildCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: List.generate(menuItems.length, (index) {
                    final item = menuItems[index];
                    final volumeStr = item['volume'].toString();
                    final abvValue = item['abv'] as double;
                    final abvStr = abvValue == abvValue.toInt()
                        ? abvValue.toInt().toString()
                        : abvValue.toString();

                    return Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          leading: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              item['icon'] as IconData,
                              color: const Color(0xFF2563EB),
                            ),
                          ),
                          title: Text(
                            item['name'].toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text(
                            '${volumeStr}ml ・ $abvStr%',
                            style: const TextStyle(color: Color(0xFF6B7280)),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                color: const Color(0xFF6B7280),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => _AddMenuDialog(
                                      editIndex: index,
                                      initialItem: item,
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                color: const Color(0xFF6B7280),
                                onPressed: () {
                                  final newList =
                                      List<Map<String, dynamic>>.from(
                                        globalMenuItemsNotifier.value,
                                      );
                                  newList.removeAt(index);
                                  saveMenuItems(newList);
                                },
                              ),
                            ],
                          ),
                        ),
                        if (index != menuItems.length - 1)
                          const Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: Color(0xFFE5E7EB),
                          ),
                      ],
                    );
                  }),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 24),
      child: Row(
        children: [
          Icon(icon, size: 22, color: const Color(0xFF6B7280)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF374151),
            ),
          ),
          if (trailing != null) ...[const Spacer(), trailing],
        ],
      ),
    );
  }

  Widget _buildCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(18),
  }) {
    return Card(
      child: Padding(padding: padding, child: child),
    );
  }

  Widget _buildSmallTextField(
    TextEditingController controller, {
    ValueChanged<String>? onChanged,
  }) {
    return SizedBox(
      width: 82,
      height: 42,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        decoration: const InputDecoration(contentPadding: EdgeInsets.zero),
      ),
    );
  }

  Widget _buildRestDayToggles() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const days = ['日', '月', '火', '水', '木', '金', '土'];
        final itemSize = ((constraints.maxWidth - 24) / 7).clamp(30.0, 42.0);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(days.length, (index) {
            return _buildDayToggle(days[index], index, itemSize);
          }),
        );
      },
    );
  }

  Widget _buildDayToggle(String day, int index, double size) {
    final isSelected = _restDays[index];
    return GestureDetector(
      onTap: () {
        setState(() {
          _restDays[index] = !_restDays[index];
        });
        updateRestDay(index, _restDays[index]);
      },
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

  Widget _buildCalendarMock() {
    const weekdays = ['日', '月', '火', '水', '木', '金', '土'];
    final cells = _calendarCells(_visibleScheduleMonth);
    final settings = globalAppSettingsNotifier.value;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  '${_visibleScheduleMonth.month}月 ${_visibleScheduleMonth.year}',
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
                setState(() {
                  _visibleScheduleMonth = DateTime(
                    _visibleScheduleMonth.year,
                    _visibleScheduleMonth.month - 1,
                  );
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  _visibleScheduleMonth = DateTime(
                    _visibleScheduleMonth.year,
                    _visibleScheduleMonth.month + 1,
                  );
                });
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
            final inVisibleMonth = date.month == _visibleScheduleMonth.month;
            final isScheduled = settings.scheduledDrinkingDates.contains(
              formatDateKey(date),
            );
            final isToday = DateUtils.isSameDay(date, DateTime.now());

            return InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () {
                setState(() {
                  toggleScheduledDrinkingDate(date);
                });
              },
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

  String _formatNumber(double value) {
    return value == value.toInt() ? value.toInt().toString() : value.toString();
  }
}

class _AddMenuDialog extends StatefulWidget {
  const _AddMenuDialog({this.editIndex, this.initialItem});

  final int? editIndex;
  final Map<String, dynamic>? initialItem;

  @override
  State<_AddMenuDialog> createState() => _AddMenuDialogState();
}

class _AddMenuDialogState extends State<_AddMenuDialog> {
  final _nameController = TextEditingController();
  final _volumeController = TextEditingController();
  final _abvController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<IconData> _icons = [
    Icons.sports_bar_outlined,
    Icons.wine_bar_outlined,
    Icons.local_bar_outlined,
    Icons.emoji_food_beverage_outlined,
    Icons.local_drink_outlined,
  ];
  int _selectedIconIndex = 0;

  bool get _isEditing => widget.editIndex != null;

  @override
  void initState() {
    super.initState();

    final item = widget.initialItem;
    if (item == null) {
      return;
    }

    _nameController.text = item['name'].toString();
    _volumeController.text = item['volume'].toString();
    final abvValue = item['abv'];
    _abvController.text = abvValue is double && abvValue == abvValue.toInt()
        ? abvValue.toInt().toString()
        : abvValue.toString();

    final iconIndex = _icons.indexWhere((icon) => icon == item['icon']);
    if (iconIndex >= 0) {
      _selectedIconIndex = iconIndex;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _volumeController.dispose();
    _abvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24,
            top: 24,
            right: 24,
            bottom: 24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? '定番を編集' : '定番を追加',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 20),
                _buildDialogLabel('名前'),
                _buildDialogTextField(
                  controller: _nameController,
                  hintText: '例: ハイボール',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '名前を入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDialogLabel('量 (ml)'),
                          _buildDialogTextField(
                            controller: _volumeController,
                            hintText: '350',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              final volume = int.tryParse(value?.trim() ?? '');
                              if (volume == null || volume <= 0) {
                                return '1以上';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDialogLabel('度数 (%)'),
                          _buildDialogTextField(
                            controller: _abvController,
                            hintText: '5',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              final abv = double.tryParse((value ?? '').trim());
                              if (abv == null || abv <= 0) {
                                return '1以上';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDialogLabel('アイコン'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(_icons.length, (index) {
                    final isSelected = _selectedIconIndex == index;
                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => setState(() => _selectedIconIndex = index),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFEFF6FF)
                              : const Color(0xFFF9FAFB),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF2563EB)
                                : const Color(0xFFE5E7EB),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          _icons[index],
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveMenuItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF111827),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _isEditing ? '更新' : '保存',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      ),
    );
  }

  void _saveMenuItem() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newList = List<Map<String, dynamic>>.from(
      globalMenuItemsNotifier.value,
    );
    final menuItem = {
      'icon': _icons[_selectedIconIndex],
      'name': _nameController.text.trim(),
      'volume': int.parse(_volumeController.text.trim()),
      'abv': double.parse(_abvController.text.trim()),
    };

    final editIndex = widget.editIndex;
    if (editIndex == null) {
      newList.add(menuItem);
    } else if (editIndex >= 0 && editIndex < newList.length) {
      newList[editIndex] = menuItem;
    }
    saveMenuItems(newList);

    Navigator.of(context).pop();
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(hintText: hintText),
    );
  }
}
