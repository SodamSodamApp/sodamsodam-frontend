import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart' show GoRoute, GoRouter;
import 'package:sodamsodam_app/screens/like_page.dart';
import 'package:sodamsodam_app/screens/main_page.dart';
import 'package:sodamsodam_app/screens/my_booking_page.dart';
import 'package:sodamsodam_app/screens/my_profile_page.dart';
import 'package:sodamsodam_app/screens/review_page.dart';
import 'package:sodamsodam_app/services/auth_services.dart';

class NavigationBarPage extends StatefulWidget {
  final VoidCallback onLogin;
  final VoidCallback offLogin;
  const NavigationBarPage({
    super.key,
    required this.onLogin,
    required this.offLogin,
  });

  @override
  State<NavigationBarPage> createState() => _NavigationBarPageState();
}

class _NavigationBarPageState extends State<NavigationBarPage> {
  int _selectedIndex = 0;

  void onItemTap(int currentIndex) {
    setState(() {
      _selectedIndex = currentIndex;
    });
  }

  void _onLogin() {
    widget.onLogin();
  }

  void _offLogin() {
    widget.offLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: FittedBox(
        child: Flex(
          direction: Axis.horizontal,
          children: [
            Expanded(
              child: Container(
                height: 62,
                color: Colors.white,
                child: FittedBox(
                  fit: BoxFit.contain,
                  alignment: Alignment.topCenter,
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => onItemTap(1),
                        child: Container(
                          height: 62,
                          width: 62,
                          alignment: Alignment.center,
                          color:
                              !(_selectedIndex == 1)
                                  ? Colors.white
                                  : Color(0xffd9d9d9),
                          child: Icon(Icons.calendar_today, size: 20),
                        ),
                      ),
                      InkWell(
                        onTap: () => onItemTap(2),
                        child: Container(
                          height: 62,
                          width: 62,
                          alignment: Alignment.center,
                          color:
                              !(_selectedIndex == 2)
                                  ? Colors.white
                                  : Color(0xffd9d9d9),
                          child: Icon(Icons.favorite_border_outlined, size: 24),
                        ),
                      ),
                      InkWell(
                        onTap: () => onItemTap(0),
                        child: Container(
                          height: 62,
                          width: 106,
                          alignment: Alignment.center,
                          child: Image.asset('assets/image/logo.png'),
                        ),
                      ),
                      InkWell(
                        onTap: () => onItemTap(3),
                        child: Container(
                          height: 62,
                          width: 63,
                          alignment: Alignment.center,
                          color:
                              !(_selectedIndex == 3)
                                  ? Colors.white
                                  : Color(0xffd9d9d9),
                          child: Icon(Icons.add_box_outlined, size: 24),
                        ),
                      ),
                      InkWell(
                        onTap: () => onItemTap(4),
                        child: Container(
                          height: 62,
                          width: 62,
                          alignment: Alignment.center,
                          color:
                              !(_selectedIndex == 4)
                                  ? Colors.white
                                  : Color(0xffd9d9d9),
                          child: Icon(Icons.account_circle_outlined, size: 24),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          Mainpage(),
          MyBookingPage(),
          LikePage(),
          ReviewPage(),
          MyProfilePage(onLogin: _onLogin, offLogin: _offLogin),
        ],
      ),
    );
  }
}
