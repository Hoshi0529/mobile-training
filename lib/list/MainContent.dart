import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// 遷移先の画面（仮）を作成しておきます。
// すでにファイルがある場合は、importしてこのクラスは削除してください。
class RecordInputPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("記録入力")),
      body: Center(child: Text("入力画面です")),
    );
  }
}

class MainContent extends StatelessWidget {
  Function onPressed;
  MainContent(this.onPressed);

  @override
  Widget build(BuildContext context) {
    // ★変更点1：全体をScaffoldで囲みます
    return Scaffold(
      // ★変更点2：右下のボタンをここで設定します

      // ★変更点3：もともとのColumnをbodyに入れます
      body: Column(
        children: [
          Container(
            height: 20,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    "飲酒日〇月×日"
                    "午後8時",
                    style: TextStyle(
                      color: Colors.black,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                padding: EdgeInsets.all(2),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Image.asset('assets/images/strong.jpg'),
                Image.asset('assets/images/medium.jpg'),
                Image.asset('assets/images/soft.jpg'),
              ],
            ),
          ),
          Container(
            height: 40, // ★少し高さを広げました（ボタンと日付が見やすくなるように）
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () => {onPressed()},
                  child: Padding(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Text("過去のデータの推移"),
                    ),
                    padding: EdgeInsets.all(2),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.red,
                    ),
                    foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.white,
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        side: BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: FittedBox(
                    fit: BoxFit.fitHeight,
                    child: Text(
                      "記入日:2021/07/21",
                      style: TextStyle(
                        color: Colors.black,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
          ),
        ],
      ),
    );
  }
}
