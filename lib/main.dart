import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sodamsodam_app/screens/initialPage.dart';
import 'package:sodamsodam_app/screens/mainPage.dart';
import 'package:sodamsodam_app/subscreens/naviationBarPage.dart';
import 'package:sodamsodam_app/services/auth_services.dart';
import 'package:sodamsodam_app/services/kakaoMapInteropService.dart';

/// 실행 파일

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/config/.env');

  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  static const double ratio = 375 / 812;
  bool _loggedIn = AuthService.isLoggedIn();

  void _onLogin() {
    setState(() {
      _loggedIn = true;
    });
  }

  void _offLogin() {
    setState(() {
      _loggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xFFD9D9D9),
        scaffoldBackgroundColor: Colors.white,

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
            child:
                AuthService.isLoggedIn()
                    ? NavigationBarPage(onLogin: _onLogin, offLogin: _offLogin)
                    : InitialPage(onLogin: _onLogin, offLogin: _offLogin),
          ),
        ),
      ),
    );
  }
}
