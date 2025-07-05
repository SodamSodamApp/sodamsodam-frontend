import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:sodamsodam_app/screens/initial_page.dart';
import 'package:sodamsodam_app/screens/main_page.dart';
import 'package:sodamsodam_app/subscreens/navigation_bar_page.dart';
import 'package:sodamsodam_app/services/auth_services.dart';
import 'package:sodamsodam_app/services/kakao_map_interop_service.dart';

/// 실행 파일

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/config/.env');
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final GoRouter _router;
  bool _loggedIn = true;

  // 원하는 화면 비율 설정
  static const double targetAspectRatio = 375 / 812; // 디자인 기준 비율

  @override
  void initState() {
    super.initState();
    //_loggedIn = AuthService.isLoggedIn();

    _router = GoRouter(
      routerNeglect: true, // 외부 URL 변경 무시
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder:
              (context, state) => _buildResponsiveLayout(
                context,
                _loggedIn
                    ? NavigationBarPage(onLogin: _onLogin, offLogin: _offLogin)
                    : InitialPage(onLogin: _onLogin, offLogin: _offLogin),
              ),
        ),
        GoRoute(
          path: '/kakao-callback',
          builder:
              (context, state) => _buildResponsiveLayout(
                context,
                InitialPage(onLogin: _onLogin, offLogin: _offLogin),
              ),
        ),
        GoRoute(
          path: '/home',
          builder:
              (context, state) => _buildResponsiveLayout(
                context,
                NavigationBarPage(onLogin: _onLogin, offLogin: _offLogin),
              ),
        ),
      ],
    );
  }

  void _onLogin() => setState(() => _loggedIn = true);
  void _offLogin() => setState(() => _loggedIn = false);

  Widget _buildResponsiveLayout(BuildContext context, Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final currentAspectRatio = screenWidth / screenHeight;

        final targetWidth = (screenHeight - 20) * targetAspectRatio;
        return Center(
          child: SizedBox(
            width: targetWidth > 375 ? 375 : targetWidth,
            height: screenHeight - 20 > 812 ? 812 : screenHeight - 20,
            child: child,
          ),
        );
        /*
        if (currentAspectRatio > targetAspectRatio) {
          // 화면이 너무 넓을 때
          final targetWidth = screenHeight * targetAspectRatio;
          return Center(
            child: SizedBox(
              width: targetWidth,
              height: screenHeight,
              child: child,
            ),
          );
        } else {
          // 화면이 너무 높을 때
          final targetHeight = screenWidth / targetAspectRatio;
          return Center(
            child: SizedBox(
              width: screenWidth,
              height: targetHeight,
              child: child,
            ),
          );
        }*/
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: '소담소담',
      theme: ThemeData(
        //primaryColor: const Color(0xFFD9D9D9),
        scaffoldBackgroundColor: const Color(0xFFD9D9D9),
        fontFamily: 'Pretendard',
      ),
      scrollBehavior: MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
        },
      ),
      builder: (context, child) {
        return Scaffold(
          body: MediaQuery(
            // 시스템 설정과 관계없이 앱 내에서 텍스트 크기를 고정
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!,
          ),
        );
      },
    );
  }
}
