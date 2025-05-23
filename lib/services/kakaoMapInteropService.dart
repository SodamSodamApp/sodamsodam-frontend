import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe' as u;
import 'package:flutter/material.dart';
import 'package:web/web.dart';

@JS('kakao')
external JSObject get kakao;

@JS('kakao.maps.Map')
extension type KakaoMap._(JSObject _) implements JSObject {
  external factory KakaoMap(HTMLElement container, MapOptions options);

  @JS('setCenter')
  external void _setCenter(JSObject latLng);

  void setCenter(LatLng latLng) => _setCenter(latLng.toJS());
  external void setDraggable(bool enabled);
  external void setZoomable(bool enabled);
}

@JS('kakao.maps.Marker')
extension type Marker._(JSObject _) implements JSObject {
  external factory Marker(MarkerOptions options);
  external void setMap(KakaoMap? map);
}

@JS('kakao.maps.LatLng')
extension type LatLng._(JSObject _) implements JSObject {
  external factory LatLng(double lat, double lng);
  external double get lat;
  external double get lng;

  JSObject toJS() => this;
}

extension type InfoWindow(JSObject _) implements JSObject {
  external void open(JSObject map, JSObject marker);
}

extension type Event._(JSObject _) implements JSObject {
  external void addListener(JSObject target, String type, JSFunction listener);
}

extension type MapOptions._(JSObject _) implements JSObject {
  external factory MapOptions({JSObject? center, int? level});
}

extension type MarkerOptions._(JSObject _) implements JSObject {
  external factory MarkerOptions({JSObject? position, JSObject? map});
}

extension type InfoWindowOptions._(JSObject _) implements JSObject {
  external factory InfoWindowOptions({String? content});
}

extension KakaoMapsExt on JSObject {
  external JSObject get maps;
}

extension MapsNamespace on JSObject {
  external JSFunction get Map;
  external JSFunction get LatLng;
  external JSFunction get Marker;
  external JSFunction get InfoWindow;
  external JSObject get event;
  external JSFunction get load;
}

// 이벤트 등록
extension EventExt on JSObject {
  external void addListener(JSObject target, String type, JSFunction listener);
}

// 팩토리 함수
LatLng createLatLng(double lat, double lng) {
  return LatLng(lat, lng);
}

MapOptions createMapOptions({required JSObject center, int level = 5}) =>
    MapOptions(center: center, level: level);

Marker createMarker(JSObject position, JSObject map) {
  final options = JSObject();
  options.setProperty('position'.toJS, position);
  options.setProperty('map'.toJS, map);
  return kakao.maps.Marker.callAsConstructor(options);
}

InfoWindow createInfoWindow(String content) {
  final options = JSObject();
  options.setProperty('content'.toJS, content.toJS);
  return kakao.maps.InfoWindow.callAsConstructor(options);
}

/// SDK가 완전히 준비될 때까지 대기
Future<void> ensureKakaoLoaded() async {
  while (true) {
    final hasKakao = window.hasProperty('kakao'.toJS).toDartBool;
    if (hasKakao) break;
    await Future.delayed(const Duration(milliseconds: 100));
  }
  final completer = Completer<void>();
  final callback = (() => completer.complete()).toJS;
  kakao.maps.load.callAsFunction(callback);
  await completer.future;
}

extension JSAnyExtensions on JSAny? {
  bool get toDartBool {
    final value = dartify();
    return value is bool ? value : false;
  }
}

Future<void> loadKakaoSdk(String apiKey) async {
  final completer = Completer<void>();

  // SDK 로드 완료 콜백
  void onLoaded() {
    if (!completer.isCompleted) completer.complete();
  }

  if (document.getElementById('kakao-sdk') != null) {
    onLoaded();
    return;
  }

  final script =
      HTMLScriptElement()
        ..id = 'kakao-sdk'
        ..defer = true
        ..src =
            'https://dapi.kakao.com/v2/maps/sdk.js?appkey=$apiKey&autoload=false';
  document.head!.append(script);

  await script.onLoad.first;
}

class KakaoSDKInitializer {
  static const _maxRetries = 5;
  static const _initialDelay = Duration(seconds: 1);
  static const _backoffFactor = 2;

  static Future<void> initializeWithRetry({
    required String apiKey,
    int retryCount = 0,
    Duration? delay,
  }) async {
    try {
      await loadKakaoSdk(apiKey);

      // 실제 로드 여부 검증
      if (!_isSDKLoaded()) {
        throw Exception('SDK 객체 존재하지 않음');
      }
    } catch (e, stack) {
      debugPrint('초기화 실패 (시도 $retryCount): $e\n$stack');

      if (retryCount >= _maxRetries) {
        throw TimeoutException('최대 재시도 횟수 초과', _maxRetries as Duration?);
      }

      final nextDelay = delay ?? _initialDelay;
      await Future.delayed(nextDelay);

      return initializeWithRetry(
        apiKey: apiKey,
        retryCount: retryCount + 1,
        delay: nextDelay * _backoffFactor,
      );
    }
  }

  static bool _isSDKLoaded() {
    final hasKakao = window.has('kakao');
    if (!hasKakao) return false;

    final kakaoObj = window.getProperty('kakao'.toJS) as JSObject;
    return kakaoObj.has('maps');
  }
}
