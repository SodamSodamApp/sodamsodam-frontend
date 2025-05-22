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
    return Scaffold(body: Container(child: Text("review")));
  }
}
