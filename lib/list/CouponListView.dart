import 'package:flutter/material.dart';
import '/list/CouponListItem.dart';

// 遷移先のページ（仮）
// 実際は別ファイルで作成しているはずなので、importがあればこのクラスは削除してください
class RecordInputPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("記録入力")),
      body: Center(child: Text("入力画面")),
    );
  }
}

class CouponListView extends StatelessWidget {
  Function onPressed;
  CouponListView(this.onPressed);

  @override
  Widget build(BuildContext context) {
    // ★ ここを Container から Scaffold に変更しました
    return Scaffold(
      backgroundColor: Colors.white, // 背景色はここに移動
      // ★ リスト本体は body に入れます
      body: listViewBuilder(),

      // ★ ここにボタンのコードを入れます（Scaffoldのプロパティです）
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 画面遷移の処理
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RecordInputPage()),
          );
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.edit),
      ),
    );
  }

  // --- 以下は元のコードのまま ---

  Widget buildListView() {
    return ListView(
      children: [
        CouponListItem(onPressed),
        CouponListItem(onPressed),
        CouponListItem(onPressed),
      ],
    );
  }

  //  データの個数に従って、表示する場合
  final items = [0, 1, 2, 3, 4, 5, 6];

  Widget listViewBuilder() {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return CouponListItem(onPressed);
      },
    );
  }
}
