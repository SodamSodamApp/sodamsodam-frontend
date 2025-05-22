/**
 * ### 마이페이지
 * - 프로필 확인 및 수정 (닉네임, 생년월일, 전화번호 등)
 * - 내 리뷰 목록 / 내 찜 목록 요약
 * - 개인정보 및 앱 설정
 */

import 'package:flutter/material.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container(child: Text("profile")));
  }
}
