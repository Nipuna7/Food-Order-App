import 'package:flutter/material.dart';
import 'package:foodapp/widgets/admin_navbar.dart';


class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState(); // Fixed to use the proper State generic type
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Order App'),
        backgroundColor: const Color(0x00ffffff),
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(
        index: _currentIndex,
      ), // Use IndexedStack to preserve state
      bottomNavigationBar: AdminNavbar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}