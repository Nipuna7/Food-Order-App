import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodapp/models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register with email and password
  Future<UserModel?> registerWithEmailAndPassword(
      String email, String password, String name, String contactNumber, String profilePicture) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      if (user != null) {
        // Save user details to Firestore
        UserModel userModel = UserModel(
          uid: user.uid,
          email: email,
          name: name,
          contactNumber: contactNumber,
          profilePicture: profilePicture,
        );

        await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

        return userModel;
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      if (user != null) {
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  // Google Sign-In
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      if (user != null) {
        // Check if user already exists in Firestore
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();

        if (!doc.exists) {
          // Save user details to Firestore
          UserModel userModel = UserModel(
            uid: user.uid,
            email: user.email,
            name: user.displayName,
            contactNumber: '',
            profilePicture: user.photoURL != null ? base64Encode(user.photoURL!.codeUnits) : null,
          );

          await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
        }

        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  // Password Reset
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}