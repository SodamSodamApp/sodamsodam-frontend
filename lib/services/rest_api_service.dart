import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class KakaoApiService {
  static Future<List<KakaoPlace>> keywordSearch({
    required String keyword,
    double? x,
    double? y,
    int radius = 1000,
  }) async {
    String? apiKey = dotenv.get("KAKAO_RESTAPIKEY");

    final params = <String, String>{'query': keyword};
    if (x != null && y != null) {
      params['x'] = x.toString();
      params['y'] = y.toString();
      params['radius'] = radius.toString();
    }

    final url = Uri.https(
      'dapi.kakao.com',
      '/v2/local/search/keyword.json',
      params,
    );

    final resp = await http.get(
      url,
      headers: {'Authorization': 'KakaoAK $apiKey'},
    );

    if (resp.statusCode != 200) {
      // ← 500·401·400 등 모두 여기로
      throw Exception('Kakao API error ${resp.statusCode}: ${resp.body}');
    }

    final json = jsonDecode(resp.body) as Map<String, dynamic>;

    final docs = (json['documents'] as List?) ?? []; // null-safe
    return docs.map((e) => KakaoPlace.fromJson(e)).toList();
  }
}

class KakaoPlace {
  final String id; // 장소 ID
  final String name; // place_name
  final String category; // category_name
  final String phone; // 전화번호
  final String address; // 지번 주소
  final String roadAddress; // 도로명 주소
  final double lng; // x
  final double lat; // y

  KakaoPlace({
    required this.id,
    required this.name,
    required this.category,
    required this.phone,
    required this.address,
    required this.roadAddress,
    required this.lng,
    required this.lat,
  });

  /// JSON → Model
  factory KakaoPlace.fromJson(Map<String, dynamic> json) => KakaoPlace(
    id: json['id'] as String,
    name: json['place_name'] as String,
    category: json['category_name'] as String,
    phone: json['phone'] as String? ?? '',
    address: json['address_name'] as String? ?? '',
    roadAddress: json['road_address_name'] as String? ?? '',
    lng: double.parse(json['x'] as String),
    lat: double.parse(json['y'] as String),
  );

  /// Model → JSON (필요할 때만)
  Map<String, dynamic> toJson() => {
    'id': id,
    'place_name': name,
    'category_name': category,
    'phone': phone,
    'address_name': address,
    'road_address_name': roadAddress,
    'x': lng.toString(),
    'y': lat.toString(),
  };
}

class KakaoLoginApi {
  signWithKakao() async {
    bool talkInstalled = await isKakaoTalkInstalled();
    var response;

    // 카카오톡 실행 가능 여부 확인
    // 카카오톡 실행이 가능하면 카카오톡으로 로그인, 아니면 카카오계정으로 로그인
    if (talkInstalled) {
      // 카카오톡으로 로그인
      try {
        response = await AuthCodeClient.instance.authorizeWithTalk(
          redirectUri: 'http://localhost:8080/login/oauth2/code/kakao',
        );
      } catch (error) {
        print('Login with Kakao Talk fails $error');
      }
    } else {
      // 카카오계정으로 로그인
      try {
        response = await AuthCodeClient.instance.authorize(
          redirectUri: 'http://localhost:8080/login/oauth2/code/kakao',
        );
      } catch (error) {
        print('Login with Kakao Account fails. $error');
      }
    }

    var tokenResponse = AccessTokenResponse.fromJson(response);
    var token = OAuthToken.fromResponse(tokenResponse);

    // 토큰 저장
    TokenManagerProvider.instance.manager.setToken(token);
  }
}
