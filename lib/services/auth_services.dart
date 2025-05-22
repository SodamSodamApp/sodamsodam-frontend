import 'package:web/web.dart' as html;

class AuthService {
  /// 현재 로그인 상태 - 비동기 조회
  static bool isLoggedIn() {
    String? token = html.window.localStorage.getItem('token');
    return token == 'loggedIn';
  }

  /// 로그인(플래그 ON)
  static void login() {
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
