/**
 * ### 메인 화면
 * **리뷰,장소 추천 피드**: 찜한 장소나 리뷰가 없으면 주변의 장소나 해당 장소의 리뷰를 보여줌(사진 중심 카드뷰) 찜한 장소나 리뷰가 있으면 해당 태그와 유사한 태그를 받은 장소나 유사한 태그를 가진 리뷰를 보여줌
 * **추천 지도**: GPS 기반 내 위치 표시
 */

import 'package:flutter/material.dart';
import 'package:sodamsodam_app/subscreens/kakao_map_view.dart';
import 'package:sodamsodam_app/subscreens/place_suggestion_card.dart';
import 'package:sodamsodam_app/services/rest_api_service.dart';

class MainPageController {
  MainPageController._(this._state);
  final _MainpageState _state;

  //int getCurrentIndex() => _state._currentIndex;

  void setCurrentIndex(int index) => _state._setCurrentIndex(index);
}

class Mainpage extends StatefulWidget {
  const Mainpage({super.key});

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  late final MainPageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = MainPageController._(this);
  }

  void _setCurrentIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
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
          children: [
            FirstMainPage(pageController: _pageController),
            SecondMainPage(pageController: _pageController),
          ],
        ),

        //Map ? mainView() : mapView(),
      ),
    );
  }
}

class FirstMainPage extends StatefulWidget {
  final MainPageController pageController;
  const FirstMainPage({super.key, required this.pageController});

  @override
  State<FirstMainPage> createState() => _FirstMainPageState();
}

class _FirstMainPageState extends State<FirstMainPage> {
  final _formKey1 = GlobalKey<FormState>();

  List<KakaoPlace> places = List.empty(growable: true);

  final FocusNode _node = FocusNode();

  late String _textVal;

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
                    _textVal = newValue!;
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
                    onMapReady: (controller) {},
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
                    widget.pageController.setCurrentIndex(1);
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
}

class SecondMainPage extends StatefulWidget {
  final MainPageController pageController;
  const SecondMainPage({super.key, required this.pageController});

  @override
  State<SecondMainPage> createState() => _SecondMainPageState();
}

class _SecondMainPageState extends State<SecondMainPage> {
  final _formKey2 = GlobalKey<FormState>();
  KakaoMapController? _controller;

  List<KakaoPlace> places = List.empty(growable: true);
  bool _isMarkerSelected = false;
  Map<String, dynamic>? _selectedinfo;

  final FocusNode _node = FocusNode();

  late String _textVal;

  @override
  Widget build(BuildContext context) {
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
                borderRadius: 0,
                onChanged: (info) {
                  setState(() {
                    _selectedinfo = info;
                    _isMarkerSelected = !_isMarkerSelected;
                  });
                  _controller?.clearMarkers();
                  _controller?.addMarker(
                    info?['y'],
                    info?['x'],
                    info!,
                  ); // 앱 캐릭터 이미지로 마커 설정하는 기능으로 바꿀예정정
                },
                onMapReady: (controller) {
                  setState(() => _controller = controller);
                },
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

                  widget.pageController.setCurrentIndex(0);
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
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: PlaceInfo(_selectedinfo, isSelected: _isMarkerSelected),
        ),
      ],
    );
  }

  void getSearchResult(String keyword) async {
    (double, double) pos = _controller!.getCenter();
    List<KakaoPlace> data = await KakaoApiService.keywordSearch(
      keyword: keyword,
      x: pos.$2,
      y: pos.$1,
    );
    setState(() {
      places
        ..clear()
        ..addAll(data);
    });

    _controller?.clearMarkers();
    for (KakaoPlace e in places) {
      print(e.name);

      _controller?.addMarker(e.lat, e.lng, e.toJson());
    }
  }
}

class PlaceInfo extends StatefulWidget {
  final Map<String, dynamic>? info;
  bool isSelected = false;
  PlaceInfo(this.info, {super.key, required this.isSelected});

  @override
  State<PlaceInfo> createState() => _PlaceInfoState();
}

class _PlaceInfoState extends State<PlaceInfo> {
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.isSelected,
      child: Container(
        alignment: Alignment.bottomCenter,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Container(
          height: 277,
          width: 375,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    //이미지 자리 -> 카카오 지도에서 못들고 온다네요...?
                    decoration: BoxDecoration(
                      color: Color(0xFFE6E5E2),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    height: 129,
                    width: 375,
                  ),

                  Positioned(
                    top: 20,
                    right: 15,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          widget.isSelected = !widget.isSelected;
                        });
                      },
                      child: Icon(Icons.close, size: 15),
                    ),
                  ),
                ],
              ),

              Expanded(
                child: Container(
                  color: Colors.white,
                  margin: EdgeInsets.fromLTRB(10, 20, 10, 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.info?['place_name'],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            InkWell(
                              onTap: () {
                                // 찜 여부 변경경
                              },
                              child: Icon(
                                Icons
                                    .favorite_border_outlined, //여기도 조건으로 해야할 것임 <-> Icons.favorite_outlined,
                                size: 15,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        height: 30,
                        child: Text(
                          "장소 설명 적는 곳입니다. Kakao 장소 겁새으로는 얻을 수 없을 거 같고 앱에 설명을 등록하고 불러와야하지않나...띄우면 업종 정도 바로 띄울 수 있습니다.",
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.fade,
                        ),
                      ),

                      Container(
                        margin: EdgeInsets.fromLTRB(0, 3, 0, 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "리뷰 ", //{우리 DB에서 들고 올 데이터}
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w400,
                              ),
                            ),

                            Text(
                              "{리뷰개수}", //{우리 DB에서 들고 올 데이터}
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            Text(
                              " / 평균 ", //{우리 DB에서 들고 올 데이터}
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w400,
                              ),
                            ),

                            Text(
                              "{평균금액}", //{우리 DB에서 들고 올 데이터}
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            Text(
                              "원", //{우리 DB에서 들고 올 데이터}
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Row(
                        children: [
                          Container(
                            height: 56,
                            margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "주소",
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff535353),
                                  ),
                                ),

                                Text(
                                  "영업시간",
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff535353),
                                  ),
                                ),

                                Text(
                                  "전화번호",
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff535353),
                                  ),
                                ),

                                Text(
                                  "주차",
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff535353),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            height: 56,
                            width: 220,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.info?['road_address_name'],
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff535353),
                                  ),
                                ),

                                Text(
                                  "{우리 DB에서 들고 올 데이터}",
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff535353),
                                  ),
                                ),

                                Text(
                                  widget.info?['phone'],
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff535353),
                                  ),
                                ),

                                Text(
                                  "{우리 DB에서 들고 올 데이터}",
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff535353),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            alignment: Alignment.bottomRight,
                            height: 56,
                            child: InkWell(
                              onTap: () {},
                              child: Container(
                                alignment: Alignment.center,
                                height: 22,
                                width: 68,
                                decoration: BoxDecoration(
                                  color: Color(0xFFD9D9D9),
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: Text(
                                  "예약하기",
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
