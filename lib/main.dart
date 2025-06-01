import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sodamsodam_app/screens/initial_page.dart';
import 'package:sodamsodam_app/screens/main_page.dart';
import 'package:sodamsodam_app/subscreens/navigation_bar_page.dart';
import 'package:sodamsodam_app/services/auth_services.dart';
import 'package:sodamsodam_app/services/kakao_map_interop_service.dart';

/// 실행 파일

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/config/.env');

  // Kakao SDK 초기화
  KakaoSdk.init(
    javaScriptAppKey: dotenv.get('KAKAO_JAVASCRIPTKEY'),
    loggingEnabled: true,
  );

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final GoRouter _router;
  late final KakaoLoginService _kakaoService;
  bool _loggedIn = false;
  
  // 원하는 화면 비율 설정
  static const double targetAspectRatio = 375 / 812;  // 디자인 기준 비율

  @override
  void initState() {
    super.initState();
    _loggedIn = AuthService.isLoggedIn();
    
    _kakaoService = KakaoLoginService(
      backendBaseUrl: dotenv.get('BACKEND_URL'),
      jsAppKey: dotenv.get('KAKAO_JAVASCRIPTKEY'),
    );

    _router = GoRouter(
      routerNeglect: true, // 외부 URL 변경 무시
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => _buildResponsiveLayout(
            context,
            _loggedIn
                ? NavigationBarPage(
                    onLogin: _onLogin,
                    offLogin: _offLogin,
                  )
                : InitialPage(
                    service: _kakaoService,
                    onLogin: _onLogin,
                    offLogin: _offLogin,
                  ),
          ),
        ),
        GoRoute(
          path: '/kakao-callback',
          builder: (context, state) => _buildResponsiveLayout(
            context,
            InitialPage(
              service: _kakaoService,
              onLogin: _onLogin,
              offLogin: _offLogin,
            ),
          ),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => _buildResponsiveLayout(
            context,
            NavigationBarPage(
              onLogin: _onLogin,
              offLogin: _offLogin,
            ),
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
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: '소담소담',
      theme: ThemeData(
        primaryColor: const Color(0xFFD9D9D9),
        scaffoldBackgroundColor: const Color(0xFFD9D9D9),
        fontFamily: 'Pretendard',
      ),
      builder: (context, child) {
        return MediaQuery(
          // 시스템 설정과 관계없이 앱 내에서 텍스트 크기를 고정
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}
