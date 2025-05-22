import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:sodamsodam_app/initialPage.dart';
import 'package:sodamsodam_app/mainPage.dart';

/// 실행 파일

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  static const double ratio = 375 / 812;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xFFD9D9D9),
        scaffoldBackgroundColor: Colors.black12,
        fontFamily: 'Pretendard',
      ),
      home: Scaffold(
        body: Container(
          margin: EdgeInsets.all(30),
          alignment: Alignment.center,
          width: double.infinity,
          height: double.infinity,
          child: AspectRatio(
            aspectRatio: ratio,
            child: Mainpage(),
            //InitialPage(),
          ),
        ),
      ),
    );
  }
}
