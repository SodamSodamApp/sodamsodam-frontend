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
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container(color: Colors.white, child: Text("like")));
  }
}
