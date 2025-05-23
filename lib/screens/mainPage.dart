/**
 * ### 메인 화면
 * **리뷰,장소 추천 피드**: 찜한 장소나 리뷰가 없으면 주변의 장소나 해당 장소의 리뷰를 보여줌(사진 중심 카드뷰) 찜한 장소나 리뷰가 있으면 해당 태그와 유사한 태그를 받은 장소나 유사한 태그를 가진 리뷰를 보여줌
 * **추천 지도**: GPS 기반 내 위치 표시
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sodamsodam_app/subscreens/kakao_map_view.dart';
import 'package:sodamsodam_app/subscreens/placeSuggestionCard.dart';
import 'package:sodamsodam_app/services/kakaoRestApiService.dart';

//const String kakaoMapKey = '95f0a77720a3ac4f74b5ae89927a5a9a'; // .env 전환 해야 함

class Mainpage extends StatefulWidget {
  final double height;
  const Mainpage({super.key, this.height = 450});

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  // KakaoMapController? _controller;

  List<KakaoPlace> places = List.empty(growable: true);

  late var _textVal;

  final FocusNode _node = FocusNode();

  int _currentIndex = 1;

  @override
  void initState() {
    _node.addListener(() => setState(() {}));

    super.initState();
  }

  @override
  void dispose() {
    _node.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        color: Colors.white,
        width: size.width,
        height: size.height,
        child: IndexedStack(
          index: _currentIndex,
          children: [mainView(), mapView()],
        ),

        //Map ? mainView() : mapView(),
      ),
    );
  }

  Widget mainView() {
    final bool focused = _node.hasFocus;
    return SizedBox.expand(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 검색창
          FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.topCenter,
            child: Form(
              key: _formKey1,
              child: Container(
                margin: EdgeInsets.fromLTRB(30, 50, 30, 20),
                height: 41,
                width: 327,
                child: TextFormField(
                  focusNode: _node,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search, size: 16),
                    filled: true,
                    fillColor: Color(0xFFFFFFFF),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                        color: Color(0xFFFEAB2D),
                        strokeAlign: BorderSide.strokeAlignCenter,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                        color: Color(0xFFFEAB2D),
                        strokeAlign: BorderSide.strokeAlignCenter,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20.5)),
                    ),

                    hintText: focused ? '' : '장소, 주소 등 검색 ',
                    hintStyle: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                  cursorColor: Colors.black,
                  cursorHeight: 18,

                  onChanged:
                      (value) => setState(() {
                        _textVal = value;
                      }),

                  onSaved: (newValue) {
                    _textVal = newValue;
                    //검색 이벤트 발생
                  },
                ),
              ),
            ),
          ),

          FittedBox(
            fit: BoxFit.contain,
            child: Container(
              margin: EdgeInsets.fromLTRB(40, 0, 40, 0),
              width: 288,
              child: Text(
                "내 위치",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
          ),

          // 내 위치 지도 : 큰 지도로 넘어갈 수 있다.
          FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.topCenter,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                  alignment: Alignment.center,
                  height: 253,
                  width: 288,
                  decoration: BoxDecoration(
                    color: Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(35),
                  ),
                  child: KakaoMapView(
                    tag: 'main', // 고유 태그 지정
                    draggable: false,
                    zoomable: false,
                    borderRadius: 35,
                  ),
                ),

                Image.asset('assets/image/logo.png', height: 49, width: 49),

                InkWell(
                  autofocus: true,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                    alignment: Alignment.center,
                    height: 253,
                    width: 288,
                    decoration: BoxDecoration(
                      color: Color(0x00000000),
                      borderRadius: BorderRadius.circular(35),
                    ),
                  ),
                  onTap: () {
                    print('Move to Map');

                    setState(() {
                      _currentIndex = 1;
                      //isMap = !isMap;
                    });
                  },
                ),
              ],
            ),
          ),

          FittedBox(
            fit: BoxFit.contain,
            child: Container(
              margin: EdgeInsets.fromLTRB(40, 10, 40, 10),
              width: 288,
              child: Text(
                "추천 장소",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
          ),

          //추천 장소
          FittedBox(
            fit: BoxFit.contain,
            child: Container(
              margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: Column(
                children: List.generate(2, (context) {
                  // 추천 장소 받아올 api 데이터 받아서 아래에 넣으면 될듯? 여기 Container를 FutureBuilder로 바꿔야 할지도?
                  return PlaceSuggestionCard(placeName: '스타벅스', review: '리뷰');
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget mapView() {
    final bool focused = _node.hasFocus;
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: KakaoMapView(
                tag: 'map1', // 고유 태그 지정
                draggable: true,
                zoomable: true,
                borderRadius: 16,
                //onMapReady: (controller) {
                // setState(() => _controller = controller);
                //},
              ),
            ),
          ],
        ),

        Positioned(
          top: 0,
          left: 0,
          child: LayoutBuilder(
            builder: (context, constraints) {
              const double kBaseRatio = 0.02;
              final double size =
                  (MediaQuery.of(context).size.height * kBaseRatio).clamp(
                    MediaQuery.of(context).size.height * 0.005,
                    MediaQuery.of(context).size.height * 0.05,
                  );

              return InkWell(
                onTap: () {
                  print('Move to Main');

                  setState(() {
                    _currentIndex = 0;
                    //isMap = !isMap;
                  });
                },
                child: Container(
                  margin: EdgeInsets.all(size * 0.5),
                  height: size * 1.5,
                  width: size * 1.5,
                  decoration: BoxDecoration(
                    //color: Colors.amber,
                    shape: BoxShape.circle,
                  ),

                  child: Icon(Icons.arrow_back_ios, size: size),
                ),
              );
            },
          ),
        ),
        // 검색창
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.topCenter,
            child: Form(
              key: _formKey2,
              child: Container(
                margin: EdgeInsets.fromLTRB(30, 50, 30, 20),
                height: 41,
                width: 327,
                child: TextFormField(
                  focusNode: _node,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search, size: 16),
                    filled: true,
                    fillColor: Color(0xFFFFFFFF),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                        color: Color(0xFFFEAB2D),
                        strokeAlign: BorderSide.strokeAlignCenter,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                        color: Color(0xFFFEAB2D),
                        strokeAlign: BorderSide.strokeAlignCenter,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20.5)),
                    ),

                    hintText: focused ? '' : '장소, 주소 등 검색 ',
                    hintStyle: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                  cursorColor: Colors.black,
                  cursorHeight: 18,

                  textInputAction:
                      TextInputAction.search, // ↵ 키에 “Search” 아이콘 표시
                  onFieldSubmitted: getSearchResult,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void getSearchResult(String keyword) async {
    final pos = await Geolocator.getCurrentPosition();
    List<KakaoPlace> data = await KakaoApiService.keywordSearch(
      keyword: keyword,
      x: pos.longitude,
      y: pos.latitude,
    );
    setState(() {
      places
        ..clear()
        ..addAll(data);
    });

    for (KakaoPlace e in places) {
      print(e.name);

      ///_controller?.addMarker(e.lat, e.lng, e.toJson());
    }
  }
}
