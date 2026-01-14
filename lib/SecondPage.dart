import 'package:flutter/material.dart';
import 'ThirdPage.dart';

class SecondPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ページ2"),
      ),
      body: Center(
        child: TextButton(
          child: Text("3ページ目に遷移する"),
          onPressed: (){
            // （1） 指定した画面に遷移する
            Navigator.push(context, MaterialPageRoute(
              // （2） 実際に表示するページ(ウィジェット)を指定する
              builder: (context) => ThirdPage()
            ));
          },
        ),
      ),
    );
  }
}