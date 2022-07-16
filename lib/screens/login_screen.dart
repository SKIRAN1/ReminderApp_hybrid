// packages
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:lottie/lottie.dart';

// helpers
import 'package:reminder/helpers/constants.dart';
// services
import '../services/auth_service.dart';
import '../widgets/login.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFBDE3FF),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Lottie.asset(
                    'assets/images/location.json',
                    animate: true,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const Text(
              'remind',
              style: TextStyle(
                fontSize: 50,
                fontFamily: fontFamily2,
                color: Color(0XFF1F1C38),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "All Your Reminders At One Place",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            authbutton("Register", false),
            authbutton("Login", true),
            // Facebook sign-in Button
            Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20)),
              margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              width: double.infinity,
              height: 60,
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0XFF705DA0),
                      ),
                    )
                  : SignInButton(
                      Buttons.FacebookNew,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      onPressed: () async {
                        setState(() {
                          loading = true;
                        });
                        await AuthScreen(FirebaseAuth.instance)
                            .signInFb(context);
                        setState(() {
                          loading = false;
                        });
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget authbutton(String text, bool islogging) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      height: 60,
      child: ElevatedButton(
        style: ButtonStyle(
            textStyle: MaterialStateProperty.all(
              const TextStyle(
                fontSize: 18,

              ),
            ),
            backgroundColor: MaterialStateProperty.all(darkColor),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)))),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (c) => Authpage(islogging)));
        },
        child: Text(text, ),
      ),
    );
  }
}
