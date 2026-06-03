import 'package:flutter/material.dart';
import '../data/menu.dart'; // 共有データをインポート

/// 新しい記録を追加する画面（ボトムシートの中身）
class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  // タブの選択状態（0: 定番, 1: 手動入力）
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '飲み物を記録',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // 週間 / 月間 のような切り替えスイッチ（定番 / 手動入力）
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(children: [_buildTab('定番', 0), _buildTab('手動入力', 1)]),
          ),
          const SizedBox(height: 20),

          // タブの中身（定番リスト）
          Expanded(
            child: _selectedTabIndex == 0
                ? _buildTeibanGrid()
                : const Center(child: Text('手動入力フォームがここに入ります')),
          ),
        ],
      ),
    );
  }

  // 定番・手動入力タブを生成
  Widget _buildTab(String text, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.black87 : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  // 共有データを監視してグリッド表示する部分
  Widget _buildTeibanGrid() {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      // ここで menu_data.dart に定義した globalMenuItemsNotifier を監視しています
      valueListenable: globalMenuItemsNotifier,
      builder: (context, menuItems, child) {
        if (menuItems.isEmpty) {
          return const Center(
            child: Text(
              '定番メニューがありません。\n設定から追加してください。',
              textAlign: TextAlign.center,
            ),
          );
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2列
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.4, // カードの縦横比（少し横長）
          ),
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  // ここに記録処理を書く（今はトースト表示）
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${item['name']} を記録しました！'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pop(context); // ボトムシートを閉じる
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Icon(item['icon'], color: Colors.blueGrey[700]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['name'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
