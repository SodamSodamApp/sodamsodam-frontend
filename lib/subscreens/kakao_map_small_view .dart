import 'dart:async';
import 'dart:ui_web' as ui;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:js/js_util.dart' as js_util;
import 'package:sodamsodam_app/services/kakaoSmallMapInteropService.dart';
import 'package:web/web.dart' as dom;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class KakaoSmallMapController {
  KakaoSmallMapController._(this._state);
  final _KakaoSmallMapViewState _state;

  void addMarker(double lat, double lng, Map<String, dynamic> info) =>
      _state._addMarker(createLatLng(lat, lng), info); // 내부 실제 로직 호출

  void clearMarkers() => _state._clearMarkers();
}

class MarkerWithInfo {
  final Marker marker;
  final Map<String, dynamic> info;
  MarkerWithInfo(this.marker, this.info);
}

class KakaoSmallMapView extends StatefulWidget {
  const KakaoSmallMapView({
    super.key,
    required this.draggable,
    required this.zoomable,
    required this.borderRadius,
    required this.tag,
    this.onMapReady,
  });
  final bool draggable;
  final bool zoomable;
  final double borderRadius;

  final String tag;

  final void Function(KakaoSmallMapController controller)? onMapReady;

  @override
  State<KakaoSmallMapView> createState() => _KakaoSmallMapViewState();
}

class _KakaoSmallMapViewState extends State<KakaoSmallMapView>
    with AutomaticKeepAliveClientMixin<KakaoSmallMapView> {
  final _htmlId = 'kakao-map-${DateTime.now().millisecondsSinceEpoch}';

  late KakaoMap _map;
  final List<Marker> _markers = <Marker>[];

  void _addMarker(LatLng pos, Map<String, dynamic> info) {
    final map = _map;
    final m = createMarker(pos, map);

    js_util.callMethod(m, 'setMap', [map]);
    _markers.add(m);

    js_util.callMethod(
      js_util.getProperty(js_util.globalThis, 'kakao').maps.event,
      'addListener',
      [
        m,
        'click',
        js_util.allowInterop((event) {
          _onMarkerClicked(m, info);
        }),
      ],
    );
  }

  void _onMarkerClicked(Marker clickedMarker, Map<String, dynamic> info) {
    final content = '''
    <div style="
      padding: 10px;
      background: white;
      border-radius: 5px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.2);
    ">
      <strong>${info['place_name']}</strong><br>
      id:${info['id']}<br>x:${info['x']}<br>y:${info['y']}
    </div>
  ''';

    final infowindowCtor = KakoMapInterop.jsConstructor([
      'kakao',
      'maps',
      'InfoWindow',
    ]);
    final opts = js_util.jsify({'content': content});
    final infowindow = js_util.callConstructor(infowindowCtor, [opts]);

    // 클릭된 마커에 인포윈도우 연결
    js_util.callMethod(infowindow, 'open', [_map, clickedMarker]);
  }

  void _clearMarkers() {
    // 모든 마커를 지도에서 제거
    for (final marker in _markers) {
      js_util.callMethod(marker, 'setMap', [null]);
    }

    // 리스트 초기화
    _markers.clear();
  }

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

    KakoMapInterop.loadKakaoSdk(
      apiKey: dotenv.get("KAKAO_JAVASCRIPTKEY"),
      onReady: _initMap,
    );
    //_initMap();
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
    _initMap();
  }

  Future<void> _initMap() async {
    // await ensureKakaoLoaded();

    final pos = await Geolocator.getCurrentPosition();
    final container = dom.document.getElementById(_htmlId)!;

    final center = createLatLng(pos.latitude, pos.longitude);
    final opts = createMapOptions(center: center, level: 5);

    final mapCtor = KakoMapInterop.jsConstructor(['kakao', 'maps', 'Map']);
    _map = js_util.callConstructor(mapCtor, [container, opts]) as KakaoMap;

    _map!
      ..setDraggable(widget.draggable)
      ..setZoomable(widget.zoomable)
      ..setCenter(center);

    widget.onMapReady?.call(KakaoSmallMapController._(this));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FutureBuilder(
      future: ensureKakaoLoaded(), //_initMap(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return HtmlElementView(viewType: _htmlId);
      },
    );
  }
}
