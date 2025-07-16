import 'package:fixastreet_app/pages/home_page.dart';
import 'package:fixastreet_app/pages/maps_page.dart';
import 'package:fixastreet_app/pages/reports_page.dart';
import 'package:flutter/material.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _HomePageState();
}

class _HomePageState extends State<NavigationPage> {
  int selectedIndex = 0;
  List<Widget> pages = [
    HomePage(),
    ReportsPage(),
    MapsPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_outlined),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
        ],
        
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: pages
      ),
      
    );
  }
}