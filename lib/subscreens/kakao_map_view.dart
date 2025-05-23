import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as ui;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sodamsodam_app/services/kakaoMapInteropService.dart';
import 'package:web/web.dart' as dom;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class KakaoMapController {
  KakaoMapController._(this._state);
  final _KakaoMapViewState _state;

  void addMarker(double lat, double lng, Map<String, dynamic> info) {
    print('tlqkfd');
    _state._addMarker(createLatLng(lat, lng), info); // 내부 실제 로직 호출
  }

  void clearMarkers() => _state._clearMarkers();
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
  final _htmlId = 'kakao-map-${DateTime.now().millisecondsSinceEpoch}';

  late KakaoMap _map;
  final List<Marker> _markers = [];

  bool flag = false;

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
  }

  Future<void> _initMap() async {
    try {
      if (!flag) {
        await KakaoSDKInitializer.initializeWithRetry(
          apiKey: dotenv.get("KAKAO_JAVASCRIPTKEY"),
        );

        final pos = await Geolocator.getCurrentPosition();
        final container =
            dom.document.getElementById(_htmlId)! as dom.HTMLElement;

        final LatLng center = createLatLng(pos.latitude, pos.longitude);
        final MapOptions opts = createMapOptions(center: center, level: 5);

        _map = kakao.maps.Map.callAsConstructor(container, opts);

        _map.setDraggable(widget.draggable);
        _map.setZoomable(widget.zoomable);
        _map.setCenter(center);

        widget.onMapReady?.call(KakaoMapController._(this));
        flag = !flag;
      }
    } catch (e) {
      debugPrint('최종 초기화 실패: $e');
    }
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

  void _addMarker(JSObject pos, Map<String, dynamic> info) {
    final marker = Marker(MarkerOptions(position: pos, map: _map));
    _markers.add(marker);

    if (kakao.maps.event == null) {
      throw Exception('카카오 맵 이벤트 모듈 초기화 실패');
    }

    JSFunction callback =
        ((JSObject event) {
          _onMarkerClicked(marker, info);
        }).toJS;

    kakao.maps.event.addListener(marker, 'click', callback);
  }

  void _onMarkerClicked(JSObject clickedMarker, Map<String, dynamic> info) {
    final content = '''
    <div style="padding:10px;background:white;border-radius:5px;box-shadow:0 2px 4px rgba(0,0,0,0.2)">
      <strong>${info['place_name']}</strong><br>
      id:${info['id']}<br>x:${info['x']}<br>y:${info['y']}
    </div>
    ''';

    // 4. 인포윈도우 생성 방식 변경
    final infowindow = InfoWindow(InfoWindowOptions(content: content));
    infowindow.open(_map, clickedMarker);
  }

  void _clearMarkers() {
    for (final Marker marker in _markers) {
      marker.setMap(null);
    }
    _markers.clear();
  }
}
