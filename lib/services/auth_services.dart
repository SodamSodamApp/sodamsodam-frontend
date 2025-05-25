import 'package:flutter/material.dart';
import 'package:sodamsodam_app/services/rest_api_service.dart';
import 'package:web/web.dart' as html;

import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class AuthService {
  /// 현재 로그인 상태 - 비동기 조회
  static bool isLoggedIn() {
    String? token = html.window.localStorage.getItem('token');
    return token == 'loggedIn';
  }

  /// 로그인(플래그 ON)
  static void login() async {
    //UserController controller = UserController(kakaoLoginApi: KakaoLoginApi());

    //controller.kakaoLogin();
    html.window.localStorage.setItem('token', 'loggedIn');
  }

  /// 로그아웃(플래그 OFF + 클리어)
  static void logout() {
    html.window.localStorage.setItem('token', 'loggedOut');
  }

  static void removeToken() {
    html.window.localStorage.removeItem('token');
  }
}

class UserController with ChangeNotifier {
  User? _user;
  KakaoLoginApi kakaoLoginApi;
  User? get user => _user;

  UserController({required this.kakaoLoginApi});

  void kakaoLogin() async {
    kakaoLoginApi.signWithKakao().then((user) {
      // 반환된 값이 NULL이 아니라면
      // 정보 전달
      if (user != null) {
        _user = user;
        notifyListeners();
      }
    });
  }
}
