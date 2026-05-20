import 'package:flutter/material.dart';

void main() {
  runApp(const AlcoholRecordApp());
}

// アプリの根幹となるウィジェット
class AlcoholRecordApp extends StatelessWidget {
  const AlcoholRecordApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'アルコールレコード',
      // 夜間や飲酒時でも目に優しいダークテーマを基調とします
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.cyan,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E293B),
          elevation: 0,
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

// ボトムナビゲーションバーを管理する画面
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // 仕様書に基づく4つのメイン画面のリスト
  final List<Widget> _pages = [
    const HomeScreen(),
    const RecordScreen(),
    const GraphScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E293B),
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.cyan,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: '記録',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '分析'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
        ],
      ),
    );
  }
}

/* ==================================================================
   ここから下は各画面のモック（仮組み）です。
   開発が進んできたら、HomeScreen.dart のように別ファイルに分割していくと
   コードが整理され、設計の勉強にもなります。
   ================================================================== */

// 1. ホーム画面（ダッシュボード）
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 厚生労働省サイトの計算式に基づくモックデータ [cite: 41, 42]
    // ※ T: 必要な時間 (h), Ag: 純アルコール量 (g) [cite: 43]
    double currentAlcoholG = 20.0;
    double timeToSober = currentAlcoholG / 10.0; // 1時間あたり10g分解 [cite: 44]

    return Scaffold(
      appBar: AppBar(title: const Text('ホーム')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'ステータス',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ), // [cite: 53]
            Card(
              color: const Color(0xFF1E293B),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text('運転可能になるまで目安'),
                    const SizedBox(height: 10),
                    Text(
                      '約 ${timeToSober.toStringAsFixed(1)} 時間',
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.cyan,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const LinearProgressIndicator(
                      value: 0.5,
                      color: Colors.cyan,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'クイック入力',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ), // [cite: 52]
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.sports_bar),
                  label: const Text('ビール'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    foregroundColor: Colors.black,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.wine_bar),
                  label: const Text('ワイン'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 2. 記録画面（カレンダー）
class RecordScreen extends StatelessWidget {
  const RecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('記録・カレンダー')),
      body: const Center(
        child: Text('ここに table_calendar パッケージを導入します'), // [cite: 88]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.cyan,
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ), // 通常入力用ボタン [cite: 57]
      ),
    );
  }
}

// 3. 分析画面（グラフ）
class GraphScreen extends StatelessWidget {
  const GraphScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('分析')),
      body: const Center(
        child: Text('ここに fl_chart パッケージで週次グラフを描画します'), // [cite: 38, 87]
      ),
    );
  }
}

// 4. 設定画面
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('個人データ（体重・体質係数）'), // [cite: 46]
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('休肝日リマインド設定'), // [cite: 62]
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            leading: Icon(Icons.warning),
            title: Text('1日の許容量設定'), // [cite: 74]
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
