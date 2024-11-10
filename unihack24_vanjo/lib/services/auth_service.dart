// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in with email and password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Error signing in: $e");
      return null;
    }
  }

  // Register with email and password
  Future<User?> registerWithEmail(
    String email,
    String password,
    SkillCycleUser newUser,
  ) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save additional user data to Firestore
      await _firestore
          .collection('users')
          .doc(userCredential.user?.uid)
          .set(newUser.toMap());

      return userCredential.user;
    } catch (e) {
      print("Error registering: $e");
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Fetch user profile from Firestore
  Future<SkillCycleUser?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      return await SkillCycleUser.fromDocument(doc);
    } catch (e) {
      print("Error fetching user profile: $e");
      return null;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      GoogleSignInAccount? googleUser = googleSignIn.currentUser;

      // Check if there is already a signed-in Google account
      googleUser ??= await googleSignIn.signIn();

      if (googleUser == null) return null; // The user canceled the sign-in

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          List<String> nameParts = (user.displayName ?? 'User').split(' ');
          String firstName = nameParts.first;
          String lastName = nameParts.length > 1 ? nameParts.last : '';

          final newUser = SkillCycleUser(
            id: user.uid,
            email: user.email,
            firstName: firstName,
            lastName: lastName,
            username: user.email?.split('@').first,
            learningSubjects: [],
            teachingSubjects: [],
          );

          await _firestore
              .collection('users')
              .doc(user.uid)
              .set(newUser.toMap());
        }
      }

      return user;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  Future<List<String>> fetchClasses() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('classes').get();
      List<String> subjects = snapshot.docs.map((doc) => doc.id).toList();
      return subjects;
    } catch (e) {
      print('Error fetching classes: $e');
      return [];
    }
  }

  Future<void> updateUserProfile(SkillCycleUser user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      print("Error updating user profile: $e");
    }
  }
}
