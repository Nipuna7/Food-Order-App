import 'package:flutter/material.dart';
import 'package:foodapp/models/user_model.dart';
import 'package:foodapp/screens/user/cart_screen.dart';
import 'package:foodapp/services/auth_service.dart';
import 'package:foodapp/widgets/user_navbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  int _currentIndex = 0;
  String _greeting = "";
  String _username = "";

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  void _fetchUserDetails() async {
    final authService = AuthService();
    final user = await authService.getCurrentUser();
    if (user != null) {
      setState(() {
        _currentUser = user;
        _username = user.name;
        _greeting = _getGreeting();
      });
    }
  }

  String _getGreeting() {
    int hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return "Good Morning";
    } else if (hour >= 12 && hour < 17) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '$_greeting, $_username',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.black), // Cart icon
            onPressed: _navigateToCart,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
      ),
      bottomNavigationBar: UserNavbar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Future<void> _navigateToCart() async {
    if (_currentUser != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CartScreen(userId: _currentUser!.uid),
        ),
      );
      
      if (result != null && result is UserModel) {
        setState(() {
          _currentUser = result;
        });
      }
    } else {
      // Handle the case when user is not loaded yet
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to access cart. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}