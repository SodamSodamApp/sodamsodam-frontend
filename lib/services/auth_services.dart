import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:js/js_util.dart' as js_util;
import 'package:sodamsodam_app/config/api_config.dart';
import 'package:sodamsodam_app/services/kakao_map_interop_service.dart';
import 'package:web/web.dart' as html;

import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_info';

  /// 현재 로그인 상태 확인
  static bool isLoggedIn() {
    String? token = html.window.localStorage.getItem(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  /// 카카오 로그인 시작
  static Future<void> startKakaoLogin(KakaoLoginService service) async {
    try {
      await service.startLogin();
    } catch (e) {
      print('카카오 로그인 시작 실패: $e');
      rethrow;
    }
  }

  /// 카카오 로그인 콜백 처리
  static Future<void> handleKakaoCallback(KakaoLoginService service) async {
    try {
      // 백엔드로부터 JWT 토큰 받기
      final jwt = await service.handleCallback();
      
      // 토큰 저장
      html.window.localStorage.setItem(_tokenKey, jwt);
      
      // 사용자 정보 조회 및 저장 (백엔드 API 호출)
      await _fetchAndSaveUserInfo(jwt);
    } catch (e) {
      print('카카오 로그인 콜백 처리 실패: $e');
      rethrow;
    }
  }

  /// 로그아웃
  static Future<void> logout() async {
    html.window.localStorage.removeItem(_tokenKey);
    html.window.localStorage.removeItem(_userKey);
  }

  /// 사용자 정보 조회 및 저장
  static Future<void> _fetchAndSaveUserInfo(String jwt) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.userProfileEndpoint),
        headers: {
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final userInfo = response.body;
        html.window.localStorage.setItem(_userKey, userInfo);
      } else {
        throw Exception('사용자 정보 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('사용자 정보 조회 실패: $e');
      rethrow;
    }
  }

  /// 저장된 사용자 정보 조회
  static Map<String, dynamic>? getUserInfo() {
    final userInfo = html.window.localStorage.getItem(_userKey);
    if (userInfo == null) return null;
    return json.decode(userInfo) as Map<String, dynamic>;
  }
}
/**
 * 
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

 */

class KakaoLoginService {
  KakaoLoginService({required this.backendBaseUrl, required this.jsAppKey});

  final String backendBaseUrl;
  final String jsAppKey;

  /// 로그인 시작 - Kakao Auth 화면으로 이동
  Future<void> startLogin() async {
    try {
      // SDK 로드 및 초기화
      await KakaoAuthLoader.load(jsAppKey: jsAppKey);

      // 리다이렉트 URI 설정 (해시 라우팅 대신 일반 경로 사용)
      final redirectUri = 'http://localhost:5100/kakao-callback';
      print('Using redirect URI: $redirectUri');

      // Kakao 객체 가져오기
      final kakao = js_util.getProperty(js_util.globalThis, 'Kakao');
      if (kakao == null) {
        throw Exception('Kakao SDK not initialized');
      }

      // Auth 객체 가져오기
      final auth = js_util.getProperty(kakao, 'Auth');
      if (auth == null) {
        throw Exception('Kakao Auth not available');
      }

      // 로그인 요청
      final loginParams = js_util.jsify({
        'redirectUri': redirectUri,
        'scope': 'profile_nickname, profile_image, account_email',
      });

      js_util.callMethod(auth, 'authorize', [loginParams]);
      
    } catch (e) {
      print('카카오 로그인 시작 실패: $e');
      rethrow;
    }
  }

  /// 콜백 라우트에서 호출 – 인가 코드 → JWT 교환
  Future<String> handleCallback() async {
    try {
      final code = Uri.base.queryParameters['code'];
      if (code == null) throw Exception('Kakao code not found in URL');

      final url = Uri.parse(ApiConfig.kakaoCallbackEndpoint).replace(
        queryParameters: {'code': code},
      );

      print('Sending request to backend: ${url.toString()}');

      final res = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Backend response status: ${res.statusCode}');
      print('Backend response body: ${res.body}');

      if (res.statusCode != 200) {
        throw Exception('Backend error: ${res.statusCode}');
      }

      final Map<String, dynamic> data = jsonDecode(res.body);
      final token = data['accessToken'];
      if (token == null) {
        throw Exception('Token not found in response');
      }

      return token as String;
    } catch (e) {
      print('카카오 로그인 콜백 처리 실패: $e');
      rethrow;
    }
  }
}
