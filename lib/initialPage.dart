/**
 * 초기 화면
 * kakao login
 */

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<StatefulWidget> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      height: 230,
      color: Color(0xFFFFF6EA),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Image.asset(
                'assets/image/logo.png',
              ), // 깨짐. svg 파일이나 원본(고화질) png 받아야할 듯
              Text(
                "소담소담",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Gugi',
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  textBaseline: TextBaseline.alphabetic,
                ),
              ),
            ],
          ),

          InkWell(
            hoverColor: const Color.fromARGB(0x50, 0xe8, 0xea, 0xf6),

            onTap: () {
              print("kakao login");
            },
            child: Container(
              width: 250,
              height: 45,
              child: Image.asset(
                "assets/kakao_login/ko/kakao_login_large_wide.png",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
/**
             */