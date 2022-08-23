import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../helpers/constants.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({Key? key}) : super(key: key);

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  String fcmapi = 'https://fcm.googleapis.com/fcm/send';
  final TextEditingController notesController = TextEditingController(text: 'Enter Some Text');

  sendNotification(String text) async {
    try {
      await Dio().post(
        fcmapi,
        data: {
          'to': '/topics/remind',
          "priority": "high",
          "mutable_content": true,
          "content_available": true,
          "data": {
            "content": {
              "channelKey": "high_importance_channel",
              'title': 'Remind',
              'body': text,
              "showWhen": true,
              "autoDismissible": true,
              "privacy": "Private"
            }
          }
        },
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization":
              "key=AAAAGJzR4OQ:APA91bEXRTYJMo8bQZnp_XK5srAmytTSJ1McX79vEgv68d6V8zDhmP4JZBdRdA79DFwz0SordeYeHUQ9FEyegpBz4wvdEfBEGnuG3kHmOnIbzO3e2qFq3K_g9_6FqgUjcl0Q9BF09CBk"
        }),
      );
    } catch (error) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Alert Users',
            style: TextStyle(
              fontSize: 35,
              fontFamily: fontFamily2,
              color: darkColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => sendNotification('Add your reminders in the App'),
                  style: ElevatedButton.styleFrom(
                    primary: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    // textStyle: const TextStyle(fontSize: 20,),
                  ),
                  child: const Text(
                    "Remind About App",
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: const [
              Expanded(
                child: Divider(
                  color: Colors.black54,
                  thickness: 1.5,
                  indent: 20,
                  endIndent: 10,
                ),
              ),
              Text('Or'),
              Expanded(
                child: Divider(
                  color: Colors.black54,
                  thickness: 1.5,
                  indent: 10,
                  endIndent: 20,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => sendNotification('Thank you for being a part of Remind App'),
                  style: ElevatedButton.styleFrom(
                    primary: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    // textStyle: const TextStyle(fontSize: 20,),
                  ),
                  child: const Text(
                    "Greet Users",
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: const [
              Expanded(
                child: Divider(
                  color: Colors.black54,
                  thickness: 1.5,
                  indent: 20,
                  endIndent: 10,
                ),
              ),
              Text('Or'),
              Expanded(
                child: Divider(
                  color: Colors.black54,
                  thickness: 1.5,
                  indent: 10,
                  endIndent: 20,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
            child: TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter notes';
                }
                return null;
              },
              textInputAction: TextInputAction.done,
              maxLines: null,
              controller: notesController,
              decoration: const InputDecoration(
                focusColor: mainColor,
                disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: Colors.grey)),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: Colors.grey)),
                labelText: 'Notification',
                labelStyle: TextStyle(color: mainColor),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => sendNotification(notesController.text),
                  style: ElevatedButton.styleFrom(
                    primary: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    // textStyle: const TextStyle(fontSize: 20,),
                  ),
                  child: const Text(
                    "Send Alert",
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
