import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static const String apiVersion = 'v1'; // API 버전
  static const String baseUrl =
      'https://knu-univ-f4hhgjeggkg6dcbs.koreacentral-01.azurewebsites.net/api/$apiVersion';

  // 카카오 로그인 관련 엔드포인트
  static String get kakaoLoginEndpoint => '$baseUrl/auth/kakao/login';
  static String get kakaoCallbackEndpoint => '$baseUrl/auth/kakao/callback';
  static String get userProfileEndpoint => '$baseUrl/users/me';

  // 프론트엔드 리다이렉트 URI
  static const String redirectUri = 'http://localhost:5100/kakao-callback';
}
