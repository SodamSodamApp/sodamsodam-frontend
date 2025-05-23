/**
 * 초기 화면
 * kakao login
 */

import 'package:flutter/material.dart';
//import 'package:flutter_svg/flutter_svg.dart';
import 'package:sodamsodam_app/subscreens/naviationBarPage.dart';
import 'package:sodamsodam_app/main.dart';
import 'package:sodamsodam_app/services/auth_services.dart';
import 'package:sodamsodam_app/services/kakaoRestApiService.dart';

class InitialPage extends StatefulWidget {
  final VoidCallback onLogin;
  final VoidCallback offLogin;
  const InitialPage({super.key, required this.onLogin, required this.offLogin});

  @override
  State<StatefulWidget> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    const double ratio = 375 / 812;

    return SizedBox.expand(
      child: Container(
        color: Color(0xFFFFF6EA),
        child: FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.topCenter,
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(60, 0, 60, 0),
                  height: 230,
                  width: 230,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Image.asset(
                        'assets/image/logo.png',
                      ), // 깨짐. svg 파일이나 원본(고화질) png 받아야할 듯,

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
                ),

                InkWell(
                  hoverColor: const Color.fromARGB(0x50, 0xe8, 0xea, 0xf6),

                  onTap: () {
                    AuthService.login();
                    print("kakao login");
                    widget.onLogin();

                    /**Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => NavigationBarPage(
                        onLogin: widget.onLogin,
                        offLogin: widget.offLogin,
                      ),
                ),
              ); */
                  },
                  child: Container(
                    margin: EdgeInsets.fromLTRB(60, 0, 60, 0),
                    width: 250,
                    height: 45,
                    child: Image.asset(
                      "assets/kakao_login/ko/kakao_login_large_wide.png",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
/**
             */