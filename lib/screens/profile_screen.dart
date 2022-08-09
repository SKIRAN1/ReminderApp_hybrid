import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:reminder/helpers/constants.dart';
import 'package:reminder/screens/change_password_screen.dart';
import 'package:reminder/screens/edit_profile_screen.dart';
import '../services/auth_service.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _imgUrl =
      "https://static.vecteezy.com/system/resources/previews/002/534/006/original/social-media-chatting-online-blank-profile-picture-head-and-body-icon-people-standing-icon-grey-background-free-vector.jpg";
  String? userName;
  String? phoneNumber;
  late encrypt.Encrypter encrypter;

  Future<void> getUd() async {
    final ud = await FacebookAuth.instance.getUserData();
    setState(() {
      _imgUrl = ud["picture"]["data"]["url"];
    });
  }

  Future<void> getuserdata() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    print(uid);
    final DocumentSnapshot data =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();
    userName = (data.data() as Map<String, dynamic>)["name"];
    phoneNumber = (data.data() as Map<String, dynamic>)["phone"];
    // final encrypted = encrypter.encrypt((data.data() as Map<String, dynamic>)["password"], iv: iv);
    // print(encrypted.base64);
    // print(encrypter.decrypt(encrypted, iv: iv));
    setState(() {});
  }

  @override
  void initState() {
    encrypter = encrypt.Encrypter(encrypt.AES(key));
    // getUd();
    getuserdata();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // physics: const BouncingScrollPhysics(),
          // padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: buildImage(),
            ),
            const SizedBox(height: 22),
            buildUser(),
          ],
        ),
      ),
    );
  }

  Widget buildImage() {
    final img = NetworkImage(_imgUrl!, scale: 1.1);
    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: Ink.image(
          image: img,
          fit: BoxFit.cover,
          width: 160,
          height: 160,
        ),
      ),
    );
  }

  Widget buildUser() {
    var userdata = FirebaseAuth.instance.currentUser!;
    String? username = userdata.displayName;
    String? useremail = userdata.email;
    return Column(
      children: [
        Text(
          // "mon",
          userName ?? "",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          useremail!,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          phoneNumber ?? '',
          style: const TextStyle(color: mainColor),
        ),
        const SizedBox(height: 10),
        if (FirebaseAuth.instance.currentUser!.email != 'admin@remind.com') ...[
          OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                primary: mainColor,
                onSurface: mainColor,
                minimumSize: const Size(
                  100,
                  40,
                ),
              ),
              onPressed: () async {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (c) => EditProfieScreen(
                      name: userName ?? '',
                      phoneNumber: phoneNumber ?? '',
                      onPop: () => getuserdata(),
                    ),
                  ),
                );
              },
              child: const Text(
                'Edit Profile',
                style: TextStyle(color: mainColor),
              )),
          // const SizedBox(height: 10),
          if (FirebaseAuth.instance.currentUser!.email != 'admin@remind.com' ||
              FirebaseAuth.instance.currentUser!.email != null) ...[
            TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (c) => const ChangePassword()));
                },
                child: const Text('Reset Password')),
          ]
        ],
        OutlinedButton(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              primary: mainColor,
              onSurface: mainColor,
              minimumSize: const Size(
                100,
                40,
              ),
            ),
            onPressed: () async {
              await AuthScreen(FirebaseAuth.instance).signOutFb(context);
            },
            child: const Text(
              'Log Out',
              style: TextStyle(color: mainColor),
            ))
      ],
    );
  }
}
