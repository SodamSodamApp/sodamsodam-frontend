/**
 * 초기 화면
 * kakao login
 */

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sodamsodam_app/services/kakao_map_interop_service.dart';
//import 'package:flutter_svg/flutter_svg.dart';
import 'package:sodamsodam_app/subscreens/navigation_bar_page.dart';
import 'package:sodamsodam_app/main.dart';
import 'package:sodamsodam_app/services/auth_services.dart';
import 'package:sodamsodam_app/services/rest_api_service.dart';

class InitialPage extends StatefulWidget {
  final VoidCallback onLogin;
  final VoidCallback offLogin;

  const InitialPage({
    super.key,
    required this.onLogin,
    required this.offLogin,
  });

  @override
  State<StatefulWidget> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkCallback();
  }

  Future<void> _checkCallback() async {
    // URL에 code 파라미터가 있으면 콜백 처리
    if (Uri.base.queryParameters.containsKey('code')) {
      setState(() => _loading = true);
      try {
        await AuthService.handleKakaoCallback();
        widget.onLogin();
        if (!mounted) return;
        context.go('/home'); // 홈으로 이동
      } catch (e) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _startLogin() async {
    setState(() => _loading = true);
    try {
      await AuthService.startKakaoLogin();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFFFF6EA),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 로고 영역
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 60),
                height: 230,
                width: 230,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    Image.asset('assets/image/logo.png'),
                    const Text(
                      "소담소담",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Gugi',
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // 카카오 로그인 버튼
              if (_loading)
                const CircularProgressIndicator()
              else
                InkWell(
                  onTap: _startLogin,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 60),
                    width: 250,
                    height: 45,
                    child: Image.asset(
                      "assets/kakao_login/ko/kakao_login_large_wide.png",
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
/**
             */