/**
 * ### 마이페이지
 * - 프로필 확인 및 수정 (닉네임, 생년월일, 전화번호 등)
 * - 내 리뷰 목록 / 내 찜 목록 요약
 * - 개인정보 및 앱 설정
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sodamsodam_app/services/auth_services.dart';
import 'package:sodamsodam_app/services/rest_api_service.dart';

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
