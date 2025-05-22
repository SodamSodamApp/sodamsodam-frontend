import 'package:flutter/material.dart';

import 'package:sodamsodam_app/initialPage.dart';
import 'package:sodamsodam_app/mainPage.dart';
import 'package:sodamsodam_app/naviationBarPage.dart';

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
    Size size = MediaQuery.of(context).size;
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
          width: size.width,
          height: size.height,
          child: AspectRatio(
            aspectRatio: ratio,
            child: NavigationBarPage(),
            //InitialPage(),
          ),
        ),
      ),
    );
  }
}
