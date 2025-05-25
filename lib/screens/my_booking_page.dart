/**
 * ### 나의 예약 확인
 * - 예약한 장소 목록 구성
 * - 장소 예약 일정을 확인 할 수있고 예약을 취소 할 수 있음
 */

import 'package:flutter/material.dart';

class MyBookingPage extends StatefulWidget {
  const MyBookingPage({super.key});

  @override
  State<MyBookingPage> createState() => _MyBookingPageState();
}

class _MyBookingPageState extends State<MyBookingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(color: Colors.white, child: Text("booking")),
    );
  }
}
