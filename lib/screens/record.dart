import 'package:flutter/material.dart';

/// 新しい記録画面（グラフやサマリーを表示）
class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  // タブの選択状態（0: 週間, 1: 月間）
  int _selectedPeriodIndex = 0;
  // グラフの表示項目（0: アルコール量, 1: カロリー）
  int _selectedChartDataType = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // タイトル
            const Text(
              '記録',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // 週間 / 月間 切り替えスイッチ
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _buildPeriodTab('週間', 0),
                  _buildPeriodTab('月間', 1),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // グラフエリア（カード）
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // アルコール量 | カロリー の切り替えテキスト
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _selectedChartDataType = 0),
                          child: Text(
                            'アルコール量',
                            style: TextStyle(
                              color: _selectedChartDataType == 0
                                  ? Colors.blue[700]
                                  : Colors.grey,
                              fontWeight: _selectedChartDataType == 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text('|', style: TextStyle(color: Colors.grey[300])),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _selectedChartDataType = 1),
                          child: Text(
                            'カロリー',
                            style: TextStyle(
                              color: _selectedChartDataType == 1
                                  ? Colors.blue[700]
                                  : Colors.grey,
                              fontWeight: _selectedChartDataType == 1
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // 数値表示
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _selectedChartDataType == 0 ? '0.0' : '0',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _selectedChartDataType == 0 ? 'g' : 'kcal',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // グラフのモックアップ（軸と目盛り）
                    SizedBox(
                      height: 200,
                      child: Row(
                        children: [
                          // Y軸（数値）
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: ['4', '3', '2', '1', '0']
                                .map((e) => Text(
                                      e,
                                      style: TextStyle(
                                          color: Colors.grey[400], fontSize: 12),
                                    ))
                                .toList(),
                          ),
                          const SizedBox(width: 16),
                          // グラフの描画エリア ＆ X軸（曜日）
                          Expanded(
                            child: Column(
                              children: [
                                // グラフが描画される空間
                                const Expanded(
                                  child: SizedBox(width: double.infinity),
                                ),
                                // X軸
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: ['木', '金', '土', '日', '月', '火', '水']
                                      .map((e) => Text(
                                            e,
                                            style: TextStyle(
                                                color: Colors.grey[400],
                                                fontSize: 12),
                                          ))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // サマリーカード（休肝日・目標超過）
            Row(
              children: [
                // 休肝日達成カード
                Expanded(
                  child: _buildSummaryCard(
                    title: '休肝日達成',
                    value: '7',
                    unit: '日',
                    backgroundColor: const Color(0xFFE8F6F0), // 薄い緑
                    textColor: const Color(0xFF0F7A59), // 濃い緑
                  ),
                ),
                const SizedBox(width: 16),
                // 目標超過カード
                Expanded(
                  child: _buildSummaryCard(
                    title: '目標超過',
                    value: '0',
                    unit: '日',
                    backgroundColor: const Color(0xFFFFF4EC), // 薄いオレンジ
                    textColor: const Color(0xFFD94D1A), // 濃いオレンジ
                  ),
                ),
              ],
            ),
            
            // 下部のFloatingActionButtonに被らないように余白を追加
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // 週間/月間タブを生成するヘルパーメソッド
  Widget _buildPeriodTab(String text, int index) {
    final isSelected = _selectedPeriodIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriodIndex = index;
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
                    )
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

  // サマリーカードを生成するヘルパーメソッド
  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String unit,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: textColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}