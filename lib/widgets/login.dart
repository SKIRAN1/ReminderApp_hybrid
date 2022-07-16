import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:reminder/widgets/textfieldcontainer.dart';

import '../helpers/constants.dart';
import '../main.dart';
import '../screens/home_screen.dart';
import '../services/showsnackbar.dart';
import 'forget_password.dart';

class Authpage extends StatefulWidget {
  final bool login;
  const Authpage(this.login, {Key? key}) : super(key: key);

  @override
  State<Authpage> createState() => _AuthpageState();
}

class _AuthpageState extends State<Authpage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isuserLogging = false;
  bool isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();

    setState(() {
      isuserLogging = widget.login;
    });
  }

  // @override
  // void dispose() {
  //   // _nameController.clear();
  //   // _emailController.clear();
  //   // _passwordController.clear();
  //   super.dispose();
  // }

  // @override
  // void didChangeDependencies() {

  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          isuserLogging ? "Login" : "Register",
          style: const TextStyle(
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
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Lottie.asset(
                  'assets/images/location.json',
                  animate: true,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),
                isuserLogging
                    // profile field
                    ? const SizedBox()
                    : TextFieldContainer(
                        controller: _nameController,
                        labelText: "Full Name",
                        hintText: "Enter your full name",
                        validator: (name) => name!.isEmpty ? "Please enter the profile name" : null,
                      ),
                // email field
                TextFieldContainer(
                  controller: _emailController,
                  labelText: "Email address",
                  hintText: "Eg nameemail@email.com",
                  validator: (email) => email != null && !EmailValidator.validate(email) ? 'Enter a valid email' : null,
                ),

                // password field
                TextFieldContainer(
                  controller: _passwordController,
                  labelText: "Password",
                  hintText: "Password",
                  validator: (value) => value != null && value.length < 8 ? 'Enter minimum 8 characters' : null,
                  obscureText: true,
                ),

                // Forgot Password
                isuserLogging
                    ? Padding(
                        padding: const EdgeInsets.all(10),
                        child: GestureDetector(
                          child: const Text(
                            'Forget Password?',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ForgetPasswordPage()));
                          },
                        ),
                      )
                    : const SizedBox(),

                isuserLogging
                    ? signbtn(
                        _nameController.text.trim(),
                        _emailController,
                        _passwordController,
                      )
                    : signbtn(
                        _nameController.text.trim(),
                        _emailController,
                        _passwordController,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget signbtn(name, email, password) {
    print("1" + name);
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async => isuserLogging ? await login(context, email, password) : await register(context, name, email, password),
                  style: ElevatedButton.styleFrom(
                    primary: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    // textStyle: const TextStyle(fontSize: 20,),
                  ),
                  child: Text(
                    isuserLogging ? "Login" : "Register",
                  ),
                ),
              ),
            ),
    );
  }

  // signing up user and logining user in firebase functions

  Future<void> login(ctx, email, password) async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      setState(() {
        isLoading = true;
      });
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.text.trim(),
          password: password.text.trim(),
        );
      } on FirebaseAuthException catch (e) {
        showSnackBar(ctx, e.message.toString());
      }

      setState(() {
        isLoading = false;
      });
      if (FirebaseAuth.instance.currentUser != null) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (c) => const HomeScreen()));
      }
    }
  }

  Future register(ctx, name, email, password) async {
    final isValid = _formKey.currentState!.validate();
    print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
    print(name);
    if (!isValid) return;
    setState(() {
      isLoading = true;
    });
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );
      await uploaddata(name);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (c) => const HomeScreen()));
    } on FirebaseAuthException catch (e) {
      showSnackBar(ctx, e.message.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> uploaddata(name) async {
    final firestore = FirebaseFirestore.instance.collection("users");
    final userdata = FirebaseAuth.instance.currentUser!;
    print(userdata.uid);
    print(name);
    await firestore.doc(userdata.uid).set({
      "id": userdata.uid,
      "username": _nameController.text,
      "email": userdata.email,
      "imgurl": "",
    });
  }
}
