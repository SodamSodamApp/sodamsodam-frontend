// lib/kakao_map_web.dart

@JS() // JS interop용
library kakao;

import 'dart:async';
import 'dart:js_interop';
import 'dart:ui_web' as ui;
import 'package:js/js_util.dart' as js_util;
import 'package:web/web.dart' as dom;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

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

class KakaoMapWebView extends StatefulWidget {
  const KakaoMapWebView({
    super.key,
    required this.draggable,
    required this.zoomable,
    required this.borderRadius,
    required this.tag,
  });
  final bool draggable;
  final bool zoomable;
  final double borderRadius;

  final String tag;

  @override
  State<KakaoMapWebView> createState() => _KakaoMapWebViewState();
}

class _KakaoMapWebViewState extends State<KakaoMapWebView>
    with AutomaticKeepAliveClientMixin<KakaoMapWebView> {
  final _htmlId = 'kakao-map-${DateTime.now().millisecondsSinceEpoch}';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // 뷰팩토리 등록
    ui.platformViewRegistry.registerViewFactory(_htmlId, (int viewId) {
      final div =
          dom.HTMLDivElement()
            ..id = _htmlId
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.borderRadius = '${widget.borderRadius}px';
      return div;
    });
    _initMap();
  }

  Future<void> ensureKakaoLoaded() async {
    final g = js_util.globalThis;
    if (js_util.hasProperty(g, 'kakao') &&
        js_util.hasProperty(js_util.getProperty(g, 'kakao'), 'maps')) {
      return;
    }
    final c = Completer<void>();
    js_util.callMethod(
      js_util.getProperty(js_util.getProperty(g, 'kakao'), 'maps'),
      'load',
      [js_util.allowInterop(() => c.complete())],
    );
    await c.future;
  }

  Future<void> _initMap() async {
    await ensureKakaoLoaded();
    final pos = await Geolocator.getCurrentPosition();
    final container = dom.document.getElementById(_htmlId)!;

    final center = createLatLng(pos.latitude, pos.longitude);
    final opts = createMapOptions(center: center, level: 5);

    final mapCtor = _jsConstructor(['kakao', 'maps', 'Map']);
    final KakaoMap map =
        js_util.callConstructor(mapCtor, [container, opts]) as KakaoMap;

    map.setDraggable(widget.draggable);
    map.setZoomable(widget.zoomable);
    map.setCenter(center);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: _initMap(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return HtmlElementView(viewType: _htmlId);
      },
    );
  }
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
