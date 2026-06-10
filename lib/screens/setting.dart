import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/menu.dart'; // 共有データをインポート

/// 設定画面
class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  // 状態管理用の変数
  final TextEditingController _weightController = TextEditingController(
    text: '60',
  );
  final TextEditingController _goalController = TextEditingController(
    text: '20',
  );

  // 休肝日の選択状態 (日〜土)
  final List<bool> _restDays = [false, true, true, false, false, false, false];

  // リマインダーのON/OFF
  bool _reminderEnabled = true;

  @override
  void dispose() {
    _weightController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ページタイトル
            const Text(
              '設定',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // 1. プロフィール
            _buildSectionTitle(Icons.person_outline, 'プロフィール'),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text('体重 (kg)', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(width: 12),
                      _buildTextField(_weightController),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '※アルコール分解時間の計算に使用します',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),

            // 2. 目標設定
            _buildSectionTitle(Icons.track_changes_outlined, '目標設定'),
            _buildCard(
              child: Row(
                children: [
                  const Expanded(
                    child: Text('1日の目標上限 (g)', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(width: 12),
                  _buildTextField(_goalController),
                ],
              ),
            ),

            // 3. 休肝日の設定
            _buildSectionTitle(Icons.event_busy_outlined, '休肝日の設定'),
            _buildCard(child: _buildRestDayToggles()),

            // 4. 飲酒予定日 (飲み会など)
            _buildSectionTitle(Icons.calendar_month_outlined, '飲酒予定日 (飲み会など)'),
            _buildCard(child: _buildCalendarMock()),
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 8),
              child: Text(
                '※予定日はカレンダーにハイライト表示されます',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ),

            // 5. リマインダー
            _buildSectionTitle(Icons.notifications_none_outlined, 'リマインダー'),
            _buildCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('休肝日リマインダー', style: TextStyle(fontSize: 16)),
                subtitle: Text(
                  '休肝日の夕方に通知を送ります',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                trailing: Switch(
                  value: _reminderEnabled,
                  onChanged: (value) {
                    setState(() {
                      _reminderEnabled = value;
                    });
                  },
                  activeThumbColor: Colors.white,
                  activeTrackColor: Colors.blue[600],
                ),
              ),
            ),

            // 6. 定番メニューの編集
            _buildSectionTitle(
              Icons.add_circle_outline,
              '定番メニューの編集',
              trailing: TextButton(
                // ==========================================
                // ここが重要：追加ボタンを押したときの処理
                // ==========================================
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const _AddMenuDialog(),
                  );
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  backgroundColor: Colors.blue[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  '追加',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // 定番メニューのリスト表示（ValueListenableBuilderで自動更新）
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
                              vertical: 4,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                item['icon'],
                                color: Colors.grey[700],
                              ),
                            ),
                            title: Text(
                              item['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Text(
                              '${volumeStr}ml • $abvStr%',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: Colors.grey,
                                  ),
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
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    // 削除処理
                                    final newList =
                                        List<Map<String, dynamic>>.from(
                                          globalMenuItemsNotifier.value,
                                        );
                                    newList.removeAt(index);
                                    globalMenuItemsNotifier.value = newList;
                                  },
                                ),
                              ],
                            ),
                          ),
                          // 最後の要素以外は区切り線を表示
                          if (index != menuItems.length - 1)
                            const Divider(
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                              color: Color(0xFFEEEEEE),
                            ),
                        ],
                      );
                    }),
                  ),
                );
              },
            ),

            // 下部余白
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // --- ヘルパーメソッド群 ---

  Widget _buildSectionTitle(IconData icon, String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 24),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          if (trailing != null) ...[const Spacer(), trailing],
        ],
      ),
    );
  }

  Widget _buildCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(20),
  }) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(padding: padding, child: child),
    );
  }

  Widget _buildTextField(TextEditingController controller) {
    return SizedBox(
      width: 80,
      height: 40,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue.shade300, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildRestDayToggles() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const days = ['日', '月', '火', '水', '木', '金', '土'];
        final itemSize = ((constraints.maxWidth - 24) / 7).clamp(28.0, 40.0);

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
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? const Color(0xFF00B578) : Colors.grey[100],
        ),
        alignment: Alignment.center,
        child: Text(
          day,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[400],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarMock() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text(
                '6月 2026',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['日', '月', '火', '水', '木', '金', '土']
              .map(
                (e) => Text(
                  e,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        _buildCalendarRow(
          ['31', '1', '2', '3', '4', '5', '6'],
          isOut: [true, false, false, false, false, false, false],
        ),
        _buildCalendarRow(['7', '8', '9', '10', '11', '12', '13']),
        _buildCalendarRow(['14', '15', '16', '17', '18', '19', '20']),
        _buildCalendarRow(['21', '22', '23', '24', '25', '26', '27']),
        _buildCalendarRow(
          ['28', '29', '30', '1', '2', '3', '4'],
          isOut: [false, false, false, true, true, true, true],
        ),
      ],
    );
  }

  Widget _buildCalendarRow(List<String> days, {List<bool>? isOut}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final outOfRange = isOut != null && isOut[index];
          return SizedBox(
            width: 32,
            child: Center(
              child: Text(
                days[index],
                style: TextStyle(
                  color: outOfRange ? Colors.grey[300] : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ============================================================================
// ポップアップダイアログ用ウィジェット
// ============================================================================
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

  // 選択可能なアイコンのリスト
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
              mainAxisSize: MainAxisSize.min, // コンテンツの高さに合わせる
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? '定番を編集' : '定番を追加',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // 名前
                const Text(
                  '名前',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
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

                // 量と度数（横並び）
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '量 (ml)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
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
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '度数 (%)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
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

                // アイコン選択
                const Text(
                  'アイコン',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(_icons.length, (index) {
                    final isSelected = _selectedIconIndex == index;
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => setState(() => _selectedIconIndex = index),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue.withValues(alpha: 0.1)
                              : Colors.grey[50],
                          border: Border.all(
                            color: isSelected
                                ? Colors.blue
                                : Colors.grey.shade200,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _icons[index],
                          color: isSelected ? Colors.blue : Colors.grey[500],
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),

                // 保存ボタン
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _saveMenuItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isEditing ? '更新' : '保存',
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
    globalMenuItemsNotifier.value = newList;

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
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade300, width: 2),
        ),
      ),
    );
  }
}
