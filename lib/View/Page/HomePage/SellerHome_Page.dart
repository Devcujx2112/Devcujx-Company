import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Screen/HomeSeller_Srceen.dart';
import '../../Screen/OrderSeller_Srceen.dart';
import '../../Screen/ProfileSeller_Srceen.dart';
import '../../Screen/StatisicalSeller_Srceen.dart';

class SellerHomePage extends StatefulWidget {
  const SellerHomePage({super.key});

  @override
  State<SellerHomePage> createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  int _selectedIndex = 0;
  late String uid;
  String email = "";
  String role = "Unknow";
  String fullName = "Loading...";
  String avatar = "";

  final List<Widget> _screens = [
    HomeSellerScreen(),
    OrderSellerScreen(),
    StatisicalSellerScreen(),
    ProfileSellerScreen()
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      backgroundColor: const Color(0xFFF5F5F5),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: Colors.white,
        buttonBackgroundColor: const Color(0xFF4CAF50),
        height: 60,
        index: _selectedIndex,
        items: [
          Icon(Icons.home,
              size: 28,
              color:
              _selectedIndex == 0 ? Colors.white : const Color(0xFF4CAF50)),
          Icon(Icons.receipt_long,
              size: 28,
              color:
              _selectedIndex == 1 ? Colors.white : const Color(0xFF4CAF50)),
          Icon(Icons.insert_chart_outlined,
              size: 28,
              color:
              _selectedIndex == 2 ? Colors.white : const Color(0xFF4CAF50)),
          Icon(Icons.person,
              size: 28,
              color:
              _selectedIndex == 3 ? Colors.white : const Color(0xFF4CAF50)),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

