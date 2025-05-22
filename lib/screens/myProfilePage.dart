/**
 * ### 마이페이지
 * - 프로필 확인 및 수정 (닉네임, 생년월일, 전화번호 등)
 * - 내 리뷰 목록 / 내 찜 목록 요약
 * - 개인정보 및 앱 설정
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sodamsodam_app/services/auth_services.dart';
import 'package:sodamsodam_app/services/kakaoRestApiService.dart';

class MyProfilePage extends StatefulWidget {
  final VoidCallback onLogin;
  final VoidCallback offLogin;
  const MyProfilePage({
    super.key,
    required this.onLogin,
    required this.offLogin,
  });

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  List? data;

  @override
  void initState() {
    super.initState();
    data = new List.empty(growable: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              AuthService.logout();
              print("logout?");
              widget.offLogin();
            },
            child: Container(color: Colors.blue, child: Text("LogOut")),
          ),
        ],
      ),
    );
  }
}
