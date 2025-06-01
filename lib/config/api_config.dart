import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static const String apiVersion = 'v1';  // API 버전
  static String get baseUrl => '${dotenv.get('BACKEND_URL')}/api/$apiVersion';
  
  // 카카오 로그인 관련 엔드포인트
  static String get loginEndpoint => '$baseUrl/auth/login';
  static String get kakaoCallbackEndpoint => '$baseUrl/auth/kakao/callback';
  static String get userProfileEndpoint => '$baseUrl/users/me';
} 