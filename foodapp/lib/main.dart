import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:foodapp/screens/froget_password_screen.dart';
import 'package:foodapp/screens/loading_screen.dart';
import 'package:foodapp/screens/sign_in_screen.dart';
import 'package:foodapp/screens/sign_up_screen.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter binding is initialized
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Order App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/sign_in_page', // Set initial route to HomeScreen
      routes: {
        '/loading_page':(context)=>LoadingScreen(),
        '/sign_in_page':(context)=>SignInScreen(),
        '/sign_up_page':(context)=>SignUpScreen(),
        '/froget_password':(context)=>ForgotPasswordScreen(),
        
      },
    );
  }
}