@JS() // JS interop용
library kakao;

import 'dart:async';
import 'dart:js_interop';
import 'dart:ui_web' as ui;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:js/js_util.dart' as js_util;
import 'package:sodamsodam_app/services/kakaoMapInteropService.dart';
import 'package:web/web.dart' as dom;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class KakaoMapView extends StatefulWidget {
  const KakaoMapView({
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
  State<KakaoMapView> createState() => _KakaoMapViewState();
}

class _KakaoMapViewState extends State<KakaoMapView>
    with AutomaticKeepAliveClientMixin<KakaoMapView> {
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

    KakoMapInterop.loadKakaoSdk(
      apiKey: dotenv.get("KAKAO_JAVASCRIPTKEY"),
      onReady: _initMap,
    );
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

    final mapCtor = KakoMapInterop.jsConstructor(['kakao', 'maps', 'Map']);
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
