// packages
import 'dart:async';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:reminder/screens/users_screen.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
// screens
import '../screens/profile_screen.dart';
//helpers
import '../helpers/constants.dart';
// Widgets
import '../widgets/custom_bottom_navigation_bar.dart';
import '../widgets/reminder_list.dart';

getContinousLocation() async {
  await Firebase.initializeApp();
  if (FirebaseAuth.instance.currentUser != null) {
    // Position position = await Geolocator.getCurrentPosition();
    // print(position.latitude);
    // getnearby(position.latitude, position.longitude, 0.5);
  }
  // print(position.first.then((value) => value.latitude));
}

getnearby(lata, lonb, distance) async {
  if (FirebaseAuth.instance.currentUser != null) {
  var latt = 0.0144927536231884;
  var lonn = 0.0181818181818182;

  var lowerLat = lata - (latt * distance);
  var lowerLon = lonb - (lonn * distance);

  var greaterLat = lata + (latt * distance);
  var greaterLon = lonb + (lonn * distance);

  var lesserGeopoint = GeoPoint(lowerLat, lowerLon);
  var greaterGeopoint = GeoPoint(greaterLat, greaterLon);
  QuerySnapshot<Map<String, dynamic>> query = await FirebaseFirestore.instance
      .collection("Reminders")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('userReminders')
      .where('location', isGreaterThan: lesserGeopoint)
      .where('location', isLessThan: greaterGeopoint)
      .limit(30)
      .get();
  // print(query.docs.length);
  // ignore: avoid_function_literals_in_foreach_calls
  query.docs.forEach((element) async {
    // print(element.data()['notified']);
    // print(DateFormat('dd-MM-yyyy').format(DateTime.now()));
    print('/////////////////////////////////////////');
    if (element.data()['notified'] == null && element.data()['date'] == DateFormat('dd-MM-yyyy').format(DateTime.now())) {
      print('ggggggggggggggggggggggggggggggggggggggg');
      FirebaseFirestore.instance
          .collection("Reminders")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('userReminders')
          .doc(element.id)
          .update({'notified': true});
      // notify(context);
      await AwesomeNotifications().createNotification(
        content: NotificationContent(id: 10, channelKey: "key1", title: element.data()['title'], body: element.data()['notes']),
      );
    }
  });
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _imgUrl;

  Future<void> getUd() async {
    final ud = await FacebookAuth.instance.getUserData();
    setState(() {
      _imgUrl = ud["picture"]["data"]["url"];
    });
  }

  @override
  void initState() {
    super.initState();
    // setBack();
    // getUd();
    // getContinousLocation();
     FirebaseMessaging.instance.subscribeToTopic('remind');
    print(FirebaseAuth.instance.currentUser!.email);
  }

  // setBack() async {
  //   await initializeService();
  // }

  // Future<void> initializeService() async {
  //   final service = FlutterBackgroundService();
  //   await service.configure(
  //     androidConfiguration: AndroidConfiguration(
  //       onStart: onStart,
  //       autoStart: true,
  //       isForegroundMode: false,
  //     ),
  //     iosConfiguration: IosConfiguration(
  //       autoStart: true,
  //       onForeground: onStart,
  //       onBackground: onIosBackground,
  //     ),
  //   );
  //   service.startService();
  // }

  // bool onIosBackground(ServiceInstance service) {
  //   WidgetsFlutterBinding.ensureInitialized();
  //   return true;
  // }

  // void onStart(ServiceInstance service) async {
  //   WidgetsFlutterBinding.ensureInitialized();
  //   DartPluginRegistrant.ensureInitialized();

  //   if (service is AndroidServiceInstance) {
  //     service.on('setAsForeground').listen((event) {
  //       service.setAsForegroundService();
  //     });

  //     service.on('setAsBackground').listen((event) {
  //       service.setAsBackgroundService();
  //     });
  //   }

  //   service.on('stopService').listen((event) {
  //     service.stopSelf();
  //   });
  //   Timer.periodic(const Duration(seconds: 1), (timer) async {
  //     print('hello');

  //     if (service is AndroidServiceInstance) {
  //       // service.setForegroundNotificationInfo(
  //       //   title: "My App Service",
  //       //   content: "Updated at ${DateTime.now()}",
  //       // );
  //     }

  //     /// you can see this log in logcat
  //     print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            'remind',
            style: TextStyle(
              fontSize: 35,
              fontFamily: fontFamily2,
              color: darkColor,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: CustomBottomNavigationBar(
        bottomNavigationBarColor: Colors.white60,
        selectedIconTheme: const IconThemeData(color: Color(0XFF705DA0)),
        items: [
          //  for reminders icon in nav_bar
          if (FirebaseAuth.instance.currentUser!.email == 'admin@remind.com') ...[
            const BottomNavigationBarItem(
              activeIcon: Icon(
                Icons.group,
                size: 30,
              ),
              icon: Icon(
                Icons.group,
                size: 30,
              ),
              label: 'Users',
            ),
          ] else ...[
            const BottomNavigationBarItem(
              activeIcon: Icon(
                Icons.article_outlined,
                size: 30,
              ),
              icon: Icon(
                Icons.article_outlined,
                size: 30,
              ),
              label: 'Reminders',
            ),
          ],
          //  for profile icon in nav_bar
          BottomNavigationBarItem(
            activeIcon: _imgUrl != null
                ? AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), border: Border.all(color: const Color(0XFF705DA0), width: 2)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        backgroundImage: NetworkImage(_imgUrl ?? '', scale: 0.5),
                        // fit: BoxFit.cover,
                        // width: 20,
                        // height: 20,
                      ),
                    ),
                  )
                : const Icon(
                    CupertinoIcons.person_alt_circle,
                    size: 30,
                  ),
            icon: _imgUrl != null
                ? AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        backgroundImage: NetworkImage(_imgUrl!, scale: 0.5),
                        // fit: BoxFit.cover,
                        // width: 20,
                        // height: 20,
                      ),
                    ),
                  )
                : const Icon(
                    CupertinoIcons.person_alt_circle,
                    size: 30,
                  ),
            label: 'Profile',
          ),
        ],
        screens: [
          (FirebaseAuth.instance.currentUser!.email == 'admin@remind.com') ? UsersScreen() : ReminderList(),
          SizedBox(),
          ProfileScreen(),
        ],
        // for center button in navbar
        centerItemBorderColor: const Color(0XFF705DA0),
        centerItem: const CircleAvatar(
          radius: 60,
          backgroundColor: Color(0XFF705DA0),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.add_circle_outline_rounded,
              size: 35,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
