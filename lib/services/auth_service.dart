import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:reminder/screens/home_screen.dart';

import '../screens/login_screen.dart';
import 'showsnackbar.dart';

class AuthScreen {
  final FirebaseAuth _auth;
  AuthScreen(this._auth);
  User get user => _auth.currentUser!;

  // Sign In
  Future<void> signInFb(BuildContext context) async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();

      if (loginResult.status == LoginStatus.success) {
        // Create a credential from the access token
        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(loginResult.accessToken!.token);

        // Once signed in, return the UserCredential
        UserCredential fbuser = await FirebaseAuth.instance
            .signInWithCredential(facebookAuthCredential);
        var userdata = await FacebookAuth.instance.getUserData();
        if (fbuser.user != null) {
          // adding userdata to firebase
          final usersdata = FirebaseFirestore.instance
              .collection('users')
              .doc(fbuser.user!.uid);
          usersdata.set({
            "id": fbuser.user!.uid,
            "name": fbuser.user!.displayName,
            "email": fbuser.user!.email,
            "imgurl": userdata["picture"]["data"]["url"],
          });
          // ignore: use_build_context_synchronously
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (c) => const HomeScreen(),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      print(e.message);
      showSnackBar(context, e.message??"something went wrong");
    }
  }

  // Sign out
  Future<void> signOutFb(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (c) => const LoginScreen()));
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }
}
