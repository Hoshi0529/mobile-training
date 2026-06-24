import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../data/menu.dart';

class AddMenuDialog extends StatefulWidget {
  const AddMenuDialog({this.editIndex, this.initialItem, super.key});

  final int? editIndex;
  final Map<String, dynamic>? initialItem;

  @override
  State<AddMenuDialog> createState() => _AddMenuDialogState();
}

class _AddMenuDialogState extends State<AddMenuDialog> {
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
                              if (volume > 10000) {
                                return '10000以下';
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
                                return '0より大きく';
                              }
                              if (abv > 100) {
                                return '100以下';
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
