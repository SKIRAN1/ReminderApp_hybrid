import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../helpers/constants.dart';
import '../widgets/textfieldcontainer.dart';

class EditProfieScreen extends StatefulWidget {
  final String name;
  final String phoneNumber;
  final Function onPop;
  const EditProfieScreen(
      {required this.name,
      required this.phoneNumber,
      required this.onPop,
      Key? key})
      : super(key: key);

  @override
  State<EditProfieScreen> createState() => _EditProfieScreenState();
}

class _EditProfieScreenState extends State<EditProfieScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    _nameController.text = widget.name;
    _numberController.text = widget.phoneNumber;
    super.initState();
  }

  Future<void> update() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(
              {'name': _nameController.text, 'phone': _numberController.text});
      setState(() {
        isLoading = false;
      });
      widget.onPop();
      Navigator.of(context).pop();
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
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    TextFieldContainer(
                      controller: _nameController,
                      labelText: "Full Name",
                      hintText: "Enter your full name",
                      validator: (name) => name!.isEmpty
                          ? "Please enter the profile name"
                          : null,
                    ),
                    TextFieldContainer(
                      controller: _numberController,
                      labelText: "Phone Number",
                      hintText: "Enter your phone number",
                      keyboard: TextInputType.number,
                      validator: (v) => v!.isEmpty || v.length < 10
                          ? "Please enter the phone number"
                          : null,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                ),
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: primaryColor))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () => update(),
                            style: ElevatedButton.styleFrom(
                              primary: primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              // textStyle: const TextStyle(fontSize: 20,),
                            ),
                            child: Text(
                              "Update",
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
