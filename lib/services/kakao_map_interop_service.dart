// lib/kakao_map_web.dart

@JS() // JS interop용
library kakao;

import 'dart:async';
import 'dart:js_interop';
import 'dart:ui';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:js/js_util.dart' as js_util;
import 'package:web/web.dart';

/*
@JS('kakao.maps.Map')
@staticInterop
class KakaoMap {} // 빈 껍데기

extension KakaoMapJS on KakaoMap {
  // JS 생성자 래핑 – 이름은 자유
  external static KakaoMap create(dom.Element container, MapOptions opts);

  external void setCenter(LatLng latLng);
}

@JS('kakao.maps.LatLng')
@staticInterop
class LatLng {}

extension LatLngJS on LatLng {
  external static LatLng create(num lat, num lng);
}

@JS()
@staticInterop
class MapOptions {}

extension MapOptionsJS on MapOptions {
  external static MapOptions create({LatLng center, int level});
}
*/

@JS('kakao.maps.Map')
@staticInterop
class KakaoMap {}

extension KakaoMapExt on KakaoMap {
  external void setCenter(LatLng pos);
  external LatLng getCenter();

  external void setDraggable(bool bool);

  external void setZoomable(bool bool);
}

@JS('kakao.maps.load')
external void kakaoMapsLoad(JSFunction callback);

// kakao.maps.LatLng
@JS('kakao.maps.LatLng')
@staticInterop
class LatLng {}

extension LatLngExt on LatLng {
  /// 위도 반환
  external double getLat();

  /// 경도 반환
  external double getLng();
}

/// LatLng 생성 헬퍼
LatLng createLatLng(num lat, num lng) {
  final latLngCtor = _jsConstructor(['kakao', 'maps', 'LatLng']);
  return js_util.callConstructor(latLngCtor, [lat, lng]) as LatLng;
}

/// MapOptions 객체 리터럴 생성
JSObject createMapOptions({required LatLng center, int level = 5}) {
  final opts = js_util.newObject();
  js_util.setProperty(opts, 'center', center);
  js_util.setProperty(opts, 'level', level);
  return opts;
}

/// 계층 경로를 따라가 JS Constructor 반환
Object _jsConstructor(List<String> path) {
  Object current = js_util.globalThis;
  for (final segment in path) {
    current = js_util.getProperty<Object?>(current, segment)!;
  }
  return current;
}

/// js_util.newObject() 의 정확한 반환 타입
typedef JSObject = Object;

@JS('kakao.maps.Marker')
@staticInterop
class Marker {}

Marker createMarker(LatLng position, KakaoMap map) {
  final opts = js_util.newObject();
  js_util.setProperty(opts, 'position', position);
  js_util.setProperty(opts, 'map', map);

  final ctor = KakoMapInterop.jsConstructor(['kakao', 'maps', 'Marker']);
  return js_util.callConstructor(ctor, [opts]) as Marker;
}

/// 계층 경로를 따라가 JS Constructor 반환
class KakoMapInterop {
  static Object jsConstructor(List<String> path) {
    Object current = js_util.globalThis;
    for (final segment in path) {
      current = js_util.getProperty<Object?>(current, segment)!;
    }
    return current;
  }

  static Future<void> loadKakaoSdk({
    required String apiKey,
    required VoidCallback onReady,
  }) async {
    // 이미 삽입되어 있으면 바로 콜백 등록
    if (document.getElementById('kakao-sdk') != null) {
      afterSdkLoaded(onReady);
    }

    // 1) autoload=false 로 SDK 삽입
    final script =
        HTMLScriptElement()
          ..id = 'kakao-sdk'
          ..defer = true
          ..src =
              'https://dapi.kakao.com/v2/maps/sdk.js?appkey=$apiKey&autoload=false';
    document.head!.append(script);

    // 2) onLoad 이벤트 → kakao.maps.load(cb)
    script.onLoad.listen((_) => afterSdkLoaded(onReady));
  }

  static void afterSdkLoaded(VoidCallback cb) {
    final kakaoObj = js_util.getProperty(js_util.globalThis, 'kakao');
    if (kakaoObj == null) {
      // 로딩 지연 대비
      Future.delayed(
        const Duration(milliseconds: 100),
        () => afterSdkLoaded(cb),
      );
      return;
    }
    final mapsObj = js_util.getProperty(kakaoObj, 'maps');
    js_util.callMethod(mapsObj, 'load', [js_util.allowInterop(cb)]);
  }
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
      await KakoMapInterop.loadKakaoSdk(
        apiKey: apiKey,
        onReady: () => print('Kakao SDK 초기화 성공'),
      );

      // 실제 로드 여부 검증
      if (!_isSDKLoaded()) {
        throw Exception('SDK 객체 존재하지 않음');
      }
    } catch (e, stack) {
      print('초기화 실패 (시도 $retryCount): $e\n$stack');

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
    final g = js_util.globalThis;
    return js_util.hasProperty(g, 'kakao') &&
        js_util.hasProperty(js_util.getProperty(g, 'kakao'), 'maps');
  }
}

/**
 * import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart';

import 'package:flutter/material.dart';

@JS('kakao')
external JSObject get kakao;

@JS('kakao.maps.Map')
extension type KakaoMap._(JSObject _) implements JSObject {
  external factory KakaoMap(HTMLElement container, MapOptions options);

  external void setCenter(JSObject latLng);
  external void setDraggable(bool enabled);
  external void setZoomable(bool enabled);
}

@JS('kakao.maps.Marker')
extension type Marker._(JSObject _) implements JSObject {
  external factory Marker(MarkerOptions options);
  external void setMap(KakaoMap? map);
}

Marker? createMarker(LatLng position) {
  try {
    return Marker(MarkerOptions(position: position));
  } catch (e) {
    debugPrint('Marker 생성 실패: $e');
    return null;
  }
}

@JS('kakao.maps.LatLng')
extension type LatLng._(JSObject _) implements JSObject {
  external factory LatLng(double lat, double lng);
  external double get lat;
  external double get lng;

  JSObject toJS() => this;
}

LatLng createLatLng(double lat, double lng) {
  return LatLng(lat, lng);
}

@JS()
extension type Event._(JSObject _) implements JSObject {
  external factory Event(JSObject _);
  external void addListener(JSObject target, String type, JSFunction listener);
  external void removeListener(
    JSObject target,
    String type,
    JSFunction listener,
  );
}

@JS()
extension type MapOptions._(JSObject _) implements JSObject {
  external factory MapOptions({JSObject? center, int? level});
}

@JS()
extension type MarkerOptions._(JSObject _) implements JSObject {
  external factory MarkerOptions({JSObject? position, JSObject? map});
}

@JS('kakao.maps.InfoWindow')
extension type InfoWindow._(JSObject _) implements JSObject {
  external factory InfoWindow(InfoWindowOptions options);
  external void open(KakaoMap map, Marker marker);
}

@JS()
extension type InfoWindowOptions._(JSObject _) implements JSObject {
  external factory InfoWindowOptions({String? content});
}

@JS('kakao.maps.load')
external JSFunction get _kakaoMapsLoad;

@JS('kakao.maps')
extension type KakaoMapsNamespace(JSObject _) implements JSObject {
  external JSObject get event;
}

// Window 확장 타입
@JS()
extension type Window(JSObject _) implements JSObject {
  external bool has(String property);
}

// 카카오맵 SDK 초기화 클래스
class KakaoMapSDK {
  static final _instance = KakaoMapSDK._internal();
  factory KakaoMapSDK() => _instance;
  KakaoMapSDK._internal();

  static const _maxRetries = 5;
  static const _initialDelay = Duration(seconds: 1);
  static const _backoffFactor = 2;

  static Future<void> initialize(String apiKey) async {
    if (!_isScriptLoaded()) {
      await _injectScript(apiKey);
    }
    await _waitForLoadComplete();
  }

  static bool _isScriptLoaded() =>
      document.getElementById('kakao-maps-sdk') != null;

  static Future<void> _injectScript(String apiKey) async {
    final script =
        HTMLScriptElement()
          ..id = 'kakao-maps-sdk'
          ..async = true
          ..src = 'https://dapi.kakao.com/v2/maps/sdk.js?appkey=$apiKey';

    document.head!.append(script);
    await _waitForScriptLoad(script);
  }

  static Future<void> _waitForScriptLoad(HTMLScriptElement script) async {
    final completer = Completer<void>();
    script.onLoad.listen((_) => completer.complete());
    script.onError.listen((_) => completer.completeError('스크립트 로드 실패'));
    await completer.future.timeout(Duration(seconds: 10));
  }

  static Future<void> _waitForLoadComplete() async {
    final completer = Completer<void>();
    final callback = (() => completer.complete()).toJS;
    _kakaoMapsLoad.callAsFunction(callback);
    await completer.future.timeout(Duration(seconds: 10));
  }

  static Future<void> initializeWithRetry({
    required String apiKey,
    int retryCount = 0,
    Duration? delay,
  }) async {
    try {
      await _injectScript(apiKey);

      // 실제 로드 여부 검증
      if (!_isScriptLoaded()) {
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
}

// 지도 컨트롤러 클래스
class KakaoMapController {
  final KakaoMap _map;
  final List<Marker> _markers = [];
  final List<JSFunction> _eventListeners = [];

  KakaoMapController(this._map);

  factory KakaoMapController.create(
    HTMLElement container, {
    required LatLng center,
    int zoomLevel = 4,
  }) {
    final options = MapOptions(center: center, level: zoomLevel);
    return KakaoMapController(KakaoMap(container, options));
  }

  void addMarker(LatLng position, {String? infoWindowContent}) {
    final marker = Marker(MarkerOptions(position: position, map: _map));
    _markers.add(marker);

    if (infoWindowContent != null) {
      _attachInfoWindow(marker, infoWindowContent);
    }
  }

  void _attachInfoWindow(Marker marker, String content) {
    final infoWindow = InfoWindow(InfoWindowOptions(content: content));
    _addEventListener(marker, 'click', () => infoWindow.open(_map, marker));
  }

  void _addEventListener(
    JSObject target,
    String eventType,
    void Function() handler,
  ) {
    final jsHandler = handler.toJS;
    final event = KakaoMapsNamespace(kakao).event;
    final eventObj = Event(event);

    eventObj.addListener(target, eventType, jsHandler);

    // 이벤트 리스너 추적을 위한 래퍼 객체 생성
    final listener = MapEventListener(eventObj, target, eventType, jsHandler);
    _eventListeners.add(listener as JSFunction);
  }

  void clearMarkers() {
    // 메서드 추가
    for (final marker in _markers) {
      marker.setMap(null);
    }
    _markers.clear();
  }

  void dispose() {
    for (final marker in _markers) {
      marker.setMap(null);
    }
    _markers.clear();

    final event = KakaoMapsNamespace(kakao).event;
    for (final listener in _eventListeners) {
      Event(event).removeListener(_map, 'click', listener);
    }
    _eventListeners.clear();
  }
}

class MapEventListener {
  final JSFunction _listener;
  final Event _event;
  final JSObject _target;
  final String _eventType;

  MapEventListener(this._event, this._target, this._eventType, this._listener);

  void dispose() {
    _event.removeListener(_target, _eventType, _listener);
  }
}

 */
