/**
 * ### 메인 화면
 * **리뷰,장소 추천 피드**: 찜한 장소나 리뷰가 없으면 주변의 장소나 해당 장소의 리뷰를 보여줌(사진 중심 카드뷰) 찜한 장소나 리뷰가 있으면 해당 태그와 유사한 태그를 받은 장소나 유사한 태그를 가진 리뷰를 보여줌
 * **추천 지도**: GPS 기반 내 위치 표시
 */

import 'package:flutter/material.dart';
import 'package:sodamsodam_app/kakoMapView.dart';
import 'package:sodamsodam_app/placeSuggestionCard.dart';

//const String kakaoMapKey = '95f0a77720a3ac4f74b5ae89927a5a9a'; // .env 전환 해야 함

class Mainpage extends StatefulWidget {
  final double height;
  const Mainpage({super.key, this.height = 450});

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  final _formKey = GlobalKey<FormState>();

  var _textVal;

  final FocusNode _node = FocusNode();

  int _currentIndex = 0;

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
    final bool focused = _node.hasFocus;

    return Scaffold(
      body: Container(
        color: Colors.white,
        width: size.width,
        height: size.height,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            IndexedStack(
              index: _currentIndex,
              children: [mainView(), mapView()],
            ),

            //Map ? mainView() : mapView(),

            // 검색창
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.contain,
                alignment: Alignment.topCenter,
                child: Form(
                  key: _formKey,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget mainView() {
    return SizedBox.expand(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 검색 창 크기의 공백백
          FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.fromLTRB(30, 50, 30, 20),
              height: 41,
              width: 327,
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
                  child: KakaoMapWebView(
                    draggable: false,
                    zoomable: false,
                    borderRadius: 35,
                    tag: 'mainView',
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
          Container(
            margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
            child: Column(
              children: [
                PlaceSuggestionCard(
                  placeName: '스타벅스',
                  review:
                      '리뷰와 이리뷰는 참기네요 아주길어서한 몇 줄되거같아요. 아무튼 이 프로젝트의 트론트를 혼자 맡아서 지냉하니 아주 힘들어. 뭐가ㅣ 이리 할게 많은지 참.......',
                ),
                PlaceSuggestionCard(placeName: '스타벅스', review: '리뷰'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget mapView() {
    return Stack(
      children: [
        KakaoMapWebView(
          draggable: true,
          zoomable: true,
          borderRadius: 0,
          tag: 'mapView',
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
      ],
    );
  }
}
