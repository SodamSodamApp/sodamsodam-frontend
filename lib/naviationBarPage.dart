import 'package:flutter/material.dart';
import 'package:sodamsodam_app/likePage.dart';
import 'package:sodamsodam_app/mainPage.dart';
import 'package:sodamsodam_app/myBookingPage.dart';
import 'package:sodamsodam_app/myProfilePage.dart';
import 'package:sodamsodam_app/reviewPage.dart';

class NavigationBarPage extends StatefulWidget {
  const NavigationBarPage({super.key});

  @override
  State<NavigationBarPage> createState() => _NavigationBarPageState();
}

class _NavigationBarPageState extends State<NavigationBarPage> {
  final List<Widget> _pageList = [
    Mainpage(),
    MyBookingPage(),
    LikePage(),
    ReviewPage(),
    MyProfilePage(),
  ];

  int _selectedIndex = 0;

  void onItemTap(int currentIndex) {
    setState(() {
      _selectedIndex = currentIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        height: 62,
        color: Colors.white,
        child: Row(
          children: [
            InkWell(
              onTap: () => onItemTap(1),
              child: Container(
                height: 62,
                width: 62,
                alignment: Alignment.center,
                child: Icon(Icons.calendar_today, size: 20),
              ),
            ),
            InkWell(
              onTap: () => onItemTap(2),
              child: Container(
                height: 62,
                width: 62,
                alignment: Alignment.center,
                child: Icon(Icons.favorite_border_outlined, size: 24),
              ),
            ),
            InkWell(
              onTap: () => onItemTap(0),
              child: Container(
                height: 62,
                width: 62,
                alignment: Alignment.center,
                child: Image.asset('assets/image/logo.png'),
              ),
            ),
            InkWell(
              onTap: () => onItemTap(3),
              child: Container(
                height: 62,
                width: 62,
                alignment: Alignment.center,
                child: Icon(Icons.add_box_outlined, size: 24),
              ),
            ),
            InkWell(
              onTap: () => onItemTap(4),
              child: Container(
                height: 62,
                width: 62,
                alignment: Alignment.center,
                child: Icon(Icons.account_circle_outlined, size: 24),
              ),
            ),
          ],
        ),
      ),
      body: _pageList[_selectedIndex],
    );
  }
}
