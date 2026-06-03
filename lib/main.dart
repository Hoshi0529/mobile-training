import 'package:flutter/material.dart';
// 分割した画面ファイルをインポートします
import 'screens/home.dart';
import 'screens/add.dart';
import 'screens/setting.dart';
import 'screens/record.dart';

void main() {
  runApp(const AlcoholRecordApp());
}

class AlcoholRecordApp extends StatelessWidget {
  const AlcoholRecordApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'アルコールレコード',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        fontFamily: 'NotoSansJP', // フォント
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // タブ切り替えで表示する画面のリスト（外部ファイルのクラスを使用）
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    RecordScreen(),
    SettingScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String formattedDate = "${now.year}年${now.month}月${now.day}日";

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('アルコールレコード', style: TextStyle(fontSize: 20)),
            Text(
              formattedDate,
              style: const TextStyle(fontSize: 12, color: Colors.black),
            ),
          ],
        ),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),

      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // ==========================================
          // ここを追加：ボトムシートを表示する処理
          // ==========================================
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, // 高さを自由に調整できるようにする設定
            shape: const RoundedRectangleBorder(
              // 画像のように上部の角を丸くする
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (BuildContext context) {
              return SizedBox(
                // 画面の高さの約70%のサイズで表示する
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  children: [
                    // ボトムシート上部のつまみ（デザイン的なアクセント）
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // AddScreenを表示（Expandedで残りの高さを埋める）
                    const Expanded(child: AddScreen()),
                  ],
                ),
              );
            },
          );
        },
        icon: const Icon(Icons.add_circle),
        label: const Text(
          '新しい記録を追加',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'データ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: '記録',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: '設定',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}
