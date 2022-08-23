// import 'package:email_validator/email_validator.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import "package:flutter/material.dart";

import '../helpers/constants.dart';
import '../main.dart';
import '../services/showsnackbar.dart';
import '../widgets/textfieldcontainer.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final _emailController = TextEditingController();
  bool isloading = false;
  @override
  void dispose() {
    _emailController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor : Colors.white,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Forget Password",
          style: TextStyle(
            color: darkColor,
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: const BackButton(
          color: darkColor,
        ),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                "assets/images/remind.png",
                height: 80,
              ),
              const SizedBox(height: 20),
              const Text(
                "Forget Password",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 15),
              const Text(
                "Enter your registered email below",
                style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 40),
              // email field
              TextFieldContainer(
                controller: _emailController,
                labelText: "Email address",
                hintText: "Eg nameemail@email.com",
                validator: (email) =>
                    email != null && !EmailValidator.validate(email)
                        ? 'Enter a valid email'
                        : null,
              ),

              // Padding(
              //   padding: const EdgeInsets.only(top: 6, left: 12),
              //   child: RichText(
              //     text: TextSpan(
              //       style: const TextStyle(
              //         fontSize: 15,
              //         color: Color(0xFF9CA3AF),
              //         fontWeight: FontWeight.w500,
              //       ),
              //       text: "Remember the password?  ",
              //       children: [
              //         TextSpan(
              //           text: "Sign in",
              //           recognizer: TapGestureRecognizer()
              //             ..onTap = () {
              //               Navigator.of(context).pop();
              //             },
              //           style: const TextStyle(
              //             fontSize: 15,
              //             color: Colors.black,
              //             fontWeight: FontWeight.w500,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    onPressed: () {
                      resetPassword(context, _emailController.text.trim());
                    },
                    child: const Text("Submit"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> resetPassword(BuildContext context, email) async {
    setState(() {
      isloading = true;
    });
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // ignore: use_build_context_synchronously
      showSnackBar(context, "Email for Password Reset has been sent");
      navigatorKey.currentState!.popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
      Navigator.of(context).pop();
    }
    setState(() {
      isloading = false;
    });
  }
}

// class Success extends StatelessWidget {
//   const Success({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: Center(
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 50),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Expanded(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(80),
//                     child: Icon(
//                       Icons.check_box,
//                       size: 90,
//                       color: maincolor,
//                     ),
//                   ),
//                   const Text(
//                     "Success",
//                     style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
//                   ),
//                   const FormSpacer(),
//                   const Text(
//                     "Please check your email for create\na new password",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                         color: Color(0xFF9CA3AF),
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500),
//                   ),
//                   const SizedBox(height: 30),
//                   Padding(
//                     padding: const EdgeInsets.only(top: 6, left: 12),
//                     child: RichText(
//                       text: TextSpan(
//                         style: const TextStyle(
//                           fontSize: 15,
//                           color: Color(0xFF9CA3AF),
//                           fontWeight: FontWeight.w700,
//                         ),
//                         text: "Can't get email?  ",
//                         children: [
//                           TextSpan(
//                             text: "Resubmit",
//                             recognizer: TapGestureRecognizer()
//                               ..onTap = () {
//                                 Navigator.of(context).pop();
//                               },
//                             style: const TextStyle(
//                               fontSize: 15,
//                               color: maincolor,
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   //
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 50),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       primary: maincolor,
//                       padding: const EdgeInsets.symmetric(vertical: 20),
//                     ),
//                     onPressed: () {
//                       Navigator.of(context).push(MaterialPageRoute(
//                           builder: (context) => const LoginScreen()));
//                     },
//                     child: const Text("Back Email"),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     ));
//   }
// }

// //         resetPassword(context, _emailController.text.trim()),


