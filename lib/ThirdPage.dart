import 'package:flutter/material.dart';



class ThirdPage extends StatelessWidget{
@override
Widget build(BuildContext context) {
return Scaffold(
  appBar: AppBar(
    title: Text("ページ3"),
  ),
  body: Center(
    child: TextButton(
      child: Text("ホームに遷移する"),
        onPressed: (){
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    ),
  ),
);
}
}