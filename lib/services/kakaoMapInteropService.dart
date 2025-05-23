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

  external void setDraggable(bool bool);

  external void setZoomable(bool bool);
}

@JS('kakao.maps.load')
external void kakaoMapsLoad(JSFunction callback);

// kakao.maps.LatLng
@JS('kakao.maps.LatLng')
@staticInterop
class LatLng {}

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

  static void loadKakaoSdk({
    required String apiKey,
    required VoidCallback onReady,
  }) {
    // 이미 삽입되어 있으면 바로 콜백 등록
    if (document.getElementById('kakao-sdk') != null) {
      afterSdkLoaded(onReady);
      return;
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
