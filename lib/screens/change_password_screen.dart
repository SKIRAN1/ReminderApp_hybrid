import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../helpers/constants.dart';
import '../services/showsnackbar.dart';
import '../widgets/textfieldcontainer.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _currentController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  RegExp regex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
  final _formKey = GlobalKey<FormState>();

  bool islogged = false;

  resetPassword(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: FirebaseAuth.instance.currentUser!.email ?? '',
          password: _currentController.text.trim(),
        );
        setState(() {
          islogged = true;
        });
      } on FirebaseAuthException catch (e) {
        showSnackBar(context, e.message.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        automaticallyImplyLeading: true,
        bottom: const PreferredSize(
            preferredSize: Size.fromHeight(4.0),
            child: Divider(
              height: 5,
            )),
        centerTitle: true,
        backgroundColor: Colors.white60,
        elevation: 0,
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: 35,
              fontFamily: fontFamily2,
              color: darkColor,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  FirebaseAuth.instance.currentUser!.email ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 20),
              if (islogged) ...[
                TextFieldContainer(
                  controller: _passwordController,
                  labelText: "New Password",
                  hintText: "Enter New Password",
                  validator: (value) => value == null || value.length < 8
                      ? 'Enter minimum 8 characters'
                      : !regex.hasMatch(value)
                          ? 'Should contain \nOne Upper Case, \nOne Lower Case, \nOne Digit, \nOne Special Character'
                          : null,
                  obscureText: true,
                ),
                TextFieldContainer(
                  controller: _confirmController,
                  labelText: "Confirm Password",
                  hintText: "Enter Password Again",
                  validator: (value) => _passwordController.text != _confirmController.text ? 'Password doesn\'t match' : null,
                  obscureText: true,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              await FirebaseAuth.instance.currentUser!.updatePassword(_passwordController.text);
                              showSnackBar(context, 'Password Chnages Successfully');
                            } on FirebaseAuthException catch (e) {
                              showSnackBar(context, e.message.toString());
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          primary: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          // textStyle: const TextStyle(fontSize: 20,),
                        ),
                        child: const Text(
                          "Done",
                        ),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                TextFieldContainer(
                  controller: _currentController,
                  labelText: "Current Password",
                  hintText: "Enter Current Password",
                  validator: (value) => value == null || value.length < 8 ? 'Enter minimum 8 characters' : null,
                  obscureText: true,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () => resetPassword(context),
                        style: ElevatedButton.styleFrom(
                          primary: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          // textStyle: const TextStyle(fontSize: 20,),
                        ),
                        child: const Text(
                          "Done",
                        ),
                      ),
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
