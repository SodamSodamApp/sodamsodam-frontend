/**
 * ### 메인 화면
 * **리뷰,장소 추천 피드**: 찜한 장소나 리뷰가 없으면 주변의 장소나 해당 장소의 리뷰를 보여줌(사진 중심 카드뷰) 찜한 장소나 리뷰가 있으면 해당 태그와 유사한 태그를 받은 장소나 유사한 태그를 가진 리뷰를 보여줌
 * **추천 지도**: GPS 기반 내 위치 표시
 */

import 'package:flutter/material.dart';
import 'package:sodamsodam_app/kakoMapView.dart';

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

    return LayoutBuilder(
      builder: (context, constraints) {
        double scale = constraints.maxWidth / 375.0; // 300이 원래 디자인 기준
        return Scaffold(
          bottomNavigationBar: Container(
            height: 62 * scale,
            color: Colors.blue,
          ),
          body: Container(
            color: Colors.white,
            width: size.width,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                IndexedStack(
                  index: _currentIndex,
                  children: [mainView(), mapView()],
                ),

                //Map ? mainView() : mapView(),

                // 검색창
                Transform.scale(
                  scale: scale < 1.0 ? scale : 1.0, // 부모보다 클 땐 1.0로 제한
                  child: Form(
                    key: _formKey,
                    child: Container(
                      margin: EdgeInsets.fromLTRB(0, 50 * scale, 0, 20 * scale),
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
                            borderRadius: BorderRadius.all(
                              Radius.circular(20.5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1,
                              color: Color(0xFFFEAB2D),
                              strokeAlign: BorderSide.strokeAlignCenter,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(20.5),
                            ),
                          ),

                          hintText: focused ? '' : '장소, 주소 등 검색 ',
                          hintStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                        cursorColor: Colors.black,
                        cursorHeight: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget mainView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double scale = constraints.maxWidth / 375.0; // 300이 원래 디자인 기준
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Transform.scale(
              scale: scale < 1.0 ? scale : 1.0, // 부모보다 클 땐 1.0로 제한
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 50 * scale, 0, 20 * scale),
                height: 41,
                width: 327,
              ),
            ),

            Transform.scale(
              scale: scale < 1.0 ? scale : 1.0, // 부모보다 클 땐 1.0로 제한
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
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
                    borderRadius: BorderRadius.circular(30 * scale),
                    child: Container(
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

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: scale < 1.0 ? scale : 1.0, // 부모보다 클 땐 1.0로 제한
                  child: Container(
                    height: 113,
                    width: 164,
                    decoration: BoxDecoration(
                      color: Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                Transform.scale(
                  scale: scale < 1.0 ? scale : 1.0, // 부모보다 클 땐 1.0로 제한
                  child: Container(
                    height: 113,
                    width: 105,
                    decoration: BoxDecoration(
                      color: Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),

            Transform.scale(
              scale: scale < 1.0 ? scale : 1.0, // 부모보다 클 땐 1.0로 제한
              child: Container(
                height: 166,
                width: 292,
                decoration: BoxDecoration(
                  color: Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        );
      },
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
              double scale = constraints.maxWidth / 375.0; // 300이 원래 디자인 기준
              return Transform.scale(
                scale: scale < 1.0 ? scale : 1.0, // 부모보다 클 땐 1.0로 제한
                child: IconButton(
                  onPressed: () {
                    print('Move to Main');

                    setState(() {
                      _currentIndex = 0;
                      //isMap = !isMap;
                    });
                  },
                  icon: Icon(Icons.arrow_back_ios, size: 20),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
