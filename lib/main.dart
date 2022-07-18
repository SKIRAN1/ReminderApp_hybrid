// packages
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:reminder/helpers/constants.dart';

// Screens
import 'screens/login_screen.dart';
import '/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: "key1",
      channelName: "Reminder",
      channelDescription: "Reminder notification",
      defaultColor: mainColor,
      enableLights: true,
      ledColor: Colors.white,
    )
  ]);
  AwesomeNotifications()
      .actionStream
      .listen((ReceivedNotification receivedNotification) {});
  runApp(const MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    print("////////");
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Remind',
      theme: ThemeData(
        primaryColor: mainColor,
        fontFamily: fontFamily3,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            print("a");
            return const Center(
                child: CircularProgressIndicator(color: mainColor));
          } else if (userSnapshot.hasData) {
            print("b");
            return const HomeScreen();
          } else {
            print("entering loginpage");
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
