/**
 * ### 찜 화면
 *  **찜한 장소**: 최근 찜순으로 스크롤 화면을 구성
 * **찜한 리뷰**: 좋아요를 누른 리뷰에 대해 모아볼 수 있음
 */

import 'package:flutter/material.dart';
import 'package:sodamsodam_app/subscreens/place_review_card.dart';

class LikePage extends StatefulWidget {
  const LikePage({super.key});

  @override
  State<LikePage> createState() => _LikePageState();
}

class _LikePageState extends State<LikePage> {
  int _isSelected = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      const double kBaseRatio = 0.02;
                      final double size = (MediaQuery.of(context).size.height *
                              kBaseRatio)
                          .clamp(
                            MediaQuery.of(context).size.height * 0.005,
                            MediaQuery.of(context).size.height * 0.05,
                          );

                      return InkWell(
                        onTap: () {},
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
                ],
              ),

              FittedBox(
                fit: BoxFit.contain,
                child: Container(
                  width: 375,
                  padding: EdgeInsets.fromLTRB(30, 20, 30, 20),
                  child: Row(
                    children: [
                      Icon(Icons.favorite, size: 24),
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: Text(
                          "찜",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: 375,
                  child: Flex(
                    direction: Axis.horizontal,
                    children: [
                      Flexible(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _isSelected = 0;
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color:
                                      !(_isSelected == 0)
                                          ? Colors.black
                                          : Color(0xff1b41ff),
                                  width: !(_isSelected == 0) ? 0.3 : 2.0,
                                ),
                              ),
                            ),
                            child: Text(
                              "리뷰",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color:
                                    !(_isSelected == 0)
                                        ? Colors.black
                                        : Color(0xff1b41ff),
                              ),
                            ),
                          ),
                        ),
                      ),

                      Flexible(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _isSelected = 1;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color:
                                      !(_isSelected == 1)
                                          ? Colors.black
                                          : Color(0xff1b41ff),
                                  width: !(_isSelected == 1) ? 0.3 : 2.0,
                                ),
                              ),
                            ),
                            child: Text(
                              "가게",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color:
                                    !(_isSelected == 1)
                                        ? Colors.black
                                        : Color(0xff1b41ff),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: IndexedStack(
                  index: _isSelected,
                  children: [LikeReviewPage(), LikePlacesPage()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////////////

class LikeReviewPage extends StatefulWidget {
  const LikeReviewPage({super.key});

  @override
  State<LikeReviewPage> createState() => _LikeReviewPageState();
}

class _LikeReviewPageState extends State<LikeReviewPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: List.generate(4, (context) {
        return PlaceReviewCard(
          userName: "USER1234",
          isLiked: true,
          tags: ["분위기", "데이트", "가성비"],
          content: "이 부분에 리뷰 내용이 들어갑니다.",
        );
      }),
    );
  }
}

///////////////////////////////////////////////////////////////////////////

class LikePlacesPage extends StatefulWidget {
  const LikePlacesPage({super.key});

  @override
  State<LikePlacesPage> createState() => _LikePlacesPageState();
}

class _LikePlacesPageState extends State<LikePlacesPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
