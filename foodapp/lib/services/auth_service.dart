import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Update user details
  Future<bool> updateUserDetails(
    String uid,
    String name,
    String contactNumber,
    String profilePicture,
  ) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'name': name,
        'contactNumber': contactNumber,
        'profilePicture': profilePicture,
      });
      return true;
    } on FirebaseException catch (e) {
      print("Firebase Error: \${e.message}");
      return false;
    } catch (e) {
      print("Unexpected Error: \${e.toString()}");
      return false;
    }
  }

  // Register with email and password
  Future<UserModel?> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
    String contactNumber,
    String profilePicture,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        UserModel userModel = UserModel(
          uid: user.uid,
          email: email,
          name: name,
          contactNumber: contactNumber,
          profilePicture: profilePicture,
        );
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap());
        return userModel;
      }
    } on FirebaseAuthException catch (e) {
      print("Auth Error: \${e.message}");
    } catch (e) {
      print("Unexpected Error: \${e.toString()}");
    }
    return null;
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        DocumentSnapshot doc =
            await _firestore.collection('users').doc(user.uid).get();
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } on FirebaseAuthException catch (e) {
      print("Auth Error: \${e.message}");
    } catch (e) {
      print("Unexpected Error: \${e.toString()}");
    }
    return null;
  }

  // Google Sign-In
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        print("Google Sign-In cancelled.");
        return null;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      if (user != null) {
        DocumentSnapshot doc =
            await _firestore.collection('users').doc(user.uid).get();

        if (!doc.exists) {
          UserModel userModel = UserModel(
            uid: user.uid,
            email: user.email,
            name: user.displayName ?? '',
            contactNumber: '',
            profilePicture:
                user.photoURL != null
                    ? base64Encode(user.photoURL!.codeUnits)
                    : null,
          );
          await _firestore
              .collection('users')
              .doc(user.uid)
              .set(userModel.toMap());
        }
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } on FirebaseAuthException catch (e) {
      print("Google Auth Error: \${e.message}");
    } catch (e) {
      print("Unexpected Error: \${e.toString()}");
    }
    return null;
  }

  // Password Reset
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print("Password Reset Error: \${e.message}");
    } catch (e) {
      print("Unexpected Error: \${e.toString()}");
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Sign Out Error: \${e.toString()}");
    }
  }
}
