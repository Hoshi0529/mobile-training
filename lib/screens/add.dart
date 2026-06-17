import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/menu.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final _manualFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _volumeController = TextEditingController();
  final _abvController = TextEditingController();

  int _selectedTabIndex = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _volumeController.dispose();
    _abvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '飲み物を記録',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(children: [_buildTab('定番', 0), _buildTab('手入力', 1)]),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _selectedTabIndex == 0
                ? _buildMenuGrid()
                : _buildManualForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
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

  Widget _buildMenuGrid() {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: globalMenuItemsNotifier,
      builder: (context, menuItems, child) {
        if (menuItems.isEmpty) {
          return const Center(
            child: Text(
              '定番メニューがありません。\n設定から追加してください。',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.only(bottom: 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.28,
          ),
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            final item = menuItems[index];
            final name = item['name'].toString();
            final volume = item['volume'] as int;
            final abv = item['abv'] as double;
            final icon = item['icon'] as IconData;

            return Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _recordDrink(
                  name: name,
                  volume: volume,
                  abv: abv,
                  icon: icon,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(icon, color: const Color(0xFF2563EB)),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${volume}ml ・ ${_formatNumber(abv)}%',
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildManualForm() {
    final alcoholGrams = _calculateManualAlcoholGrams();

    return Form(
      key: _manualFormKey,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 20),
        children: [
          _buildLabel('名前'),
          _buildTextField(
            controller: _nameController,
            hintText: '例: グラスワイン',
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
                    _buildLabel('量 (ml)'),
                    _buildTextField(
                      controller: _volumeController,
                      hintText: '120',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                    _buildLabel('度数 (%)'),
                    _buildTextField(
                      controller: _abvController,
                      hintText: '12',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        final abv = double.tryParse(value?.trim() ?? '');
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
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '純アルコール量',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  '${alcoholGrams.toStringAsFixed(1)}g',
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _submitManualRecord,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text(
                '記録する',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF111827),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _buildTextField({
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
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(hintText: hintText, errorMaxLines: 1),
    );
  }

  double _calculateManualAlcoholGrams() {
    final volume = int.tryParse(_volumeController.text.trim()) ?? 0;
    final abv = double.tryParse(_abvController.text.trim()) ?? 0;
    return volume * abv / 100 * 0.8;
  }

  void _submitManualRecord() {
    if (!_manualFormKey.currentState!.validate()) {
      return;
    }

    _recordDrink(
      name: _nameController.text.trim(),
      volume: int.parse(_volumeController.text.trim()),
      abv: double.parse(_abvController.text.trim()),
      icon: Icons.edit_note_outlined,
    );
  }

  void _recordDrink({
    required String name,
    required int volume,
    required double abv,
    required IconData icon,
  }) {
    addDrinkRecord(name: name, volume: volume, abv: abv, icon: icon);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name を記録しました'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).maybePop();
  }

  String _formatNumber(double value) {
    return value == value.toInt() ? value.toInt().toString() : value.toString();
  }
}
