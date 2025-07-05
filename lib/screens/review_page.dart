/**
 * ### 리뷰 남기기
 * - **장소 검색 (카카오 API 연동)** → 검색결과에서 장소 선택
 * - **리뷰 작성 화면**
 *     - 태그 작성 (예: #혼자가기좋은 #대화하기좋은)
 *     - 사진 최대 3장 업로드
 *         - 텍스트 후기 작성 (텍스트 추천 가이드 제공)
 */

import 'package:flutter/material.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Flex(
        direction: Axis.vertical,
        children: [
          Expanded(
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
                          final double size =
                              (MediaQuery.of(context).size.height * kBaseRatio)
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
