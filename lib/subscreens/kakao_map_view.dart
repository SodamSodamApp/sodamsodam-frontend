import 'dart:async';
import 'dart:ui_web' as ui;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:js/js_util.dart' as js_util;
import 'package:sodamsodam_app/services/kakaoMapInteropService.dart';
import 'package:web/web.dart' as dom;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

class KakaoMapController {
  KakaoMapController._(this._state);
  final _KakaoMapViewState _state;

  void addMarker(double lat, double lng, Map<String, dynamic> info) =>
      _state._addMarker(createLatLng(lat, lng), info); // 내부 실제 로직 호출

  void clearMarkers() => _state._clearMarkers();
}

class MarkerWithInfo {
  final Marker marker;
  final Map<String, dynamic> info;
  MarkerWithInfo(this.marker, this.info);
}

class KakaoMapView extends StatefulWidget {
  const KakaoMapView({
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

  final void Function(KakaoMapController controller)? onMapReady;

  @override
  State<KakaoMapView> createState() => _KakaoMapViewState();
}

class _KakaoMapViewState extends State<KakaoMapView>
    with AutomaticKeepAliveClientMixin<KakaoMapView> {
  final _htmlId = 'kakao-map-${const Uuid().v4()}';

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

  Future<void> _checkPermissions() async {
    final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      throw Exception('위치 서비스가 비활성화되었습니다.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse) {
        throw Exception('위치 권한이 거부되었습니다.');
      }
    }
  }

  Future<Position> _getSafeCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('위치 서비스 비활성화');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse) {
          throw Exception('위치 권한 거부');
        }
      }

      // 위치 정보 요청 (타임아웃 10초)
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 10));
    } on TimeoutException {
      final lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null) return lastPosition;

      // 기본 위치 (서울 시청) 반환
      return Position(
        latitude: 37.5665,
        longitude: 126.9780,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        headingAccuracy: 0,
        altitudeAccuracy: 0,
      );
    }
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

    try {
      // SDK 로드 완료 확인
      await ensureKakaoLoaded();

      final pos = await _getSafeCurrentPosition();
      final container = dom.document.getElementById(_htmlId)!;

      // 기본 좌표 설정
      final center = createLatLng(pos.latitude, pos.longitude);
      final opts = createMapOptions(center: center, level: 5);

      final mapCtor = KakoMapInterop.jsConstructor(['kakao', 'maps', 'Map']);
      _map =
          js_util.callConstructor(mapCtor, [container, opts]) as KakaoMap
            ..setDraggable(widget.draggable)
            ..setZoomable(widget.zoomable)
            ..setCenter(center);

      widget.onMapReady?.call(KakaoMapController._(this));
    } catch (e, stack) {
      print('지도 초기화 실패: $e\n$stack');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FutureBuilder(
      future: ensureKakaoLoaded(), //_initMap(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return HtmlElementView(viewType: _htmlId, key: ValueKey(_htmlId));
      },
    );
  }
}
