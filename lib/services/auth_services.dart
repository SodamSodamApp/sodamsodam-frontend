import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:js/js_util.dart' as js_util;
import 'package:sodamsodam_app/config/api_config.dart';
import 'package:sodamsodam_app/services/kakao_map_interop_service.dart';
import 'package:web/web.dart' as html;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_info';
  static bool _isInitialized = false;

  /// 카카오 SDK 초기화
  static Future<void> _initializeKakaoSDK() async {
    if (_isInitialized) return;

    try {
      final jsKey = dotenv.get('KAKAO_JAVASCRIPTKEY');
      if (jsKey.isEmpty) {
        throw Exception('KAKAO_JAVASCRIPTKEY is not set in .env file');
      }

      // Kakao SDK 스크립트 로드
      final script =
          html.document.createElement('script') as html.HTMLScriptElement;
      script.src = 'https://developers.kakao.com/sdk/js/kakao.js';
      script.async = true;
      html.document.head?.appendChild(script);

      // SDK 로드 완료 대기
      await Future.delayed(const Duration(milliseconds: 1000));

      // SDK 초기화
      final kakao = js_util.getProperty(js_util.globalThis, 'Kakao');
      if (kakao == null) {
        throw Exception('Failed to load Kakao SDK');
      }

      js_util.callMethod(kakao, 'init', [jsKey]);
      _isInitialized = true;
      print('Kakao SDK initialized successfully');
    } catch (e) {
      print('Kakao SDK initialization failed: $e');
      rethrow;
    }
  }

  /// 현재 로그인 상태 확인
  static bool isLoggedIn() {
    String? token = html.window.localStorage.getItem(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  /// 카카오 로그인 시작
  static Future<void> startKakaoLogin() async {
    try {
      // SDK 초기화 확인
      await _initializeKakaoSDK();

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
        'redirectUri': ApiConfig.redirectUri,
        'scope': 'profile_nickname,profile_image,account_email',
      });

      try {
        await js_util.promiseToFuture(
          js_util.callMethod(auth, 'authorize', [loginParams]),
        );
      } catch (e) {
        print('Kakao authorize 호출 실패: $e');
        // authorize 메서드가 없는 경우 직접 URL로 리다이렉트
        final kakaoAuthUrl =
            'https://kauth.kakao.com/oauth/authorize'
            '?client_id=${dotenv.get('KAKAO_JAVASCRIPTKEY')}'
            '&redirect_uri=${ApiConfig.redirectUri}'
            '&response_type=code'
            '&scope=profile_nickname,profile_image,account_email';

        html.window.location.href = kakaoAuthUrl;
      }
    } catch (e) {
      print('카카오 로그인 시작 실패: $e');
      rethrow;
    }
  }

  /// 카카오 로그인 콜백 처리
  static Future<void> handleKakaoCallback() async {
    try {
      final code = Uri.base.queryParameters['code'];
      if (code == null) throw Exception('Kakao code not found in URL');

      // 백엔드로 인가 코드 전송
      final response = await http.get(
        Uri.parse('${ApiConfig.kakaoCallbackEndpoint}?code=$code'),
        headers: {'Accept': 'application/json'},
      );

      print('Backend response status: ${response.statusCode}');
      print('Backend response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
          'Backend error: ${response.statusCode} - ${response.body}',
        );
      }

      // 서버에서 사용자 정보를 받아옴
      final userInfo = await _fetchUserInfo();
      if (userInfo == null) {
        throw Exception('Failed to fetch user info');
      }

      // 사용자 정보 저장
      html.window.localStorage.setItem(_userKey, json.encode(userInfo));
    } catch (e) {
      print('카카오 로그인 콜백 처리 실패: $e');
      rethrow;
    }
  }

  /// 사용자 정보 조회
  static Future<Map<String, dynamic>?> _fetchUserInfo() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/user/profile'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        print('사용자 정보 조회 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('사용자 정보 조회 실패: $e');
      return null;
    }
  }

  /// 저장된 사용자 정보 조회
  static Map<String, dynamic>? getUserInfo() {
    final userInfo = html.window.localStorage.getItem(_userKey);
    if (userInfo == null) return null;
    return json.decode(userInfo) as Map<String, dynamic>;
  }

  /// 로그아웃
  static Future<void> logout() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/logout'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        html.window.localStorage.removeItem(_userKey);
      } else {
        throw Exception('로그아웃 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('로그아웃 실패: $e');
      rethrow;
    }
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
        'scope': 'profile_nickname,profile_image,account_email', // 공백 제거
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

      final url = Uri.parse(
        ApiConfig.kakaoCallbackEndpoint,
      ).replace(queryParameters: {'code': code});

      print('Sending request to backend: ${url.toString()}');

      // 단순 GET 요청으로 변경
      final res = await http.get(url, headers: {'Accept': 'application/json'});

      print('Backend response status: ${res.statusCode}');
      print('Backend response body: ${res.body}');

      if (res.statusCode != 200) {
        throw Exception('Backend error: ${res.statusCode} - ${res.body}');
      }

      final Map<String, dynamic> data = jsonDecode(res.body);

      // 다양한 토큰 필드명에 대응
      final token =
          data['accessToken'] ??
          data['token'] ??
          data['access_token'] ??
          (data['data'] != null ? data['data']['accessToken'] : null);

      if (token == null) {
        print('Response data: $data'); // 응답 데이터 전체 출력
        throw Exception('Token not found in response');
      }

      return token as String;
    } catch (e) {
      print('카카오 로그인 콜백 처리 실패: $e');
      rethrow;
    }
  }
}
