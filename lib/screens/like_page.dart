/**
 * ### 찜 화면
 *  **찜한 장소**: 최근 찜순으로 스크롤 화면을 구성
 * **찜한 리뷰**: 좋아요를 누른 리뷰에 대해 모아볼 수 있음
 */

import 'package:flutter/material.dart';

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
        child: FittedBox(
          child: Column(
            children: [
              Container(
                height: 155,
                width: 375,
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              bottom: BorderSide(
                                color:
                                    _isSelected == 0
                                        ? Colors.black
                                        : Color(0xFF1B41FF),
                                width: _isSelected == 0 ? 1 : 3,
                              ),
                            ),
                          ),
                          child: Text(
                            "리뷰",
                            style: TextStyle(
                              color:
                                  _isSelected == 0
                                      ? Colors.black
                                      : Color(0xFF1B41FF),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
