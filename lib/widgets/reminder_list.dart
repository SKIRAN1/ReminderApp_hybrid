import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:reminder/helpers/constants.dart';
import 'package:reminder/widgets/add_reminder.dart';
import 'package:reminder/services/showsnackbar.dart';

class ReminderList extends StatefulWidget {
  const ReminderList({Key? key}) : super(key: key);

  @override
  State<ReminderList> createState() => _ReminderListState();
}

class _ReminderListState extends State<ReminderList> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  var formatter = DateFormat('MMM, yyyy');

  @override
  Widget build(BuildContext context) {
    final fireStore = FirebaseFirestore.instance.collection("Reminders").doc(userId);

    void editNote(String docid, Map<String, dynamic> doc) async {
      showModalBottomSheet(
        isDismissible: false,
        enableDrag: false,
        isScrollControlled: true,
        context: context,
        builder: (context) => AddReminder(
            edit: true,
            latitude: (doc["location"] as GeoPoint).latitude,
            longitude: (doc["location"] as GeoPoint).longitude,
            title: doc["title"],
            notes: doc["notes"],
            date: doc["date"],
            docId: docid),
      );
      // Navigator.of(context).push(
      //   MaterialPageRoute(
      //     builder: (c) => AddReminder(
      //         edit: true,
      //         latitude: (doc["location"] as GeoPoint).latitude,
      //         longitude: (doc["location"] as GeoPoint).longitude,
      //         title: doc["title"],
      //         notes: doc["notes"],
      //         date: doc["date"],
      //         docId : docid),
      //   ),
      // );
    }

    void deletenote(docid) async {
      fireStore.collection("userReminders").doc(docid).delete();
    }

    bool filterYesterday(String date) {
      return DateFormat('dd-MM-yyyy').parse(date).isBefore(DateFormat('dd-MM-yyyy').parse(DateFormat('dd-MM-yyyy').format(DateTime.now())));
    }

    return StreamBuilder(
        stream: fireStore.collection("userReminders").snapshots(),
        builder: (BuildContext ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            showSnackBar(context, 'Something went wrong,pls try again');
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.data!.docs.isEmpty) {
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset('assets/images/reminder.json', fit: BoxFit.cover, repeat: false, height: 300),
                  const Text(
                    "No Reminders added yet !",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 100)
                ],
              ),
            );
          }
          final tempdata = snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return data;
          }).toList();
          List userData = tempdata.where((element) => !filterYesterday(element['date'])).toList();

          List docId = [];
          for (var element in snapshot.data!.docs) {
            if (!filterYesterday((element.data() as Map<String, dynamic>)['date'])) {
              docId.add(element.id);
            }
          }
          // final docId = snapshot.data!.docs.wh ((DocumentSnapshot document) {
          //   String data = document.id;
          //   return data;
          // }).toList();
          // return Center(child: Text("title"));
          return Container(
              padding: const EdgeInsets.all(12.0),
              child: ListView.builder(
                itemCount: userData.length,
                itemBuilder: (BuildContext context, int index) {
                  if (filterYesterday(userData[index]['date'])) {
                    return Container();
                  }
                  return Dismissible(
                    // direction: DismissDirection.none,
                    onDismissed: (v) {},
                    confirmDismiss: (v) async {
                      if (v == DismissDirection.endToStart) {
                        deletenote(docId[index]);
                      } else if (v == DismissDirection.startToEnd) {
                        editNote(docId[index], userData[index]);
                      }
                      return false;
                    },
                    background: Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(16)),
                      child: const Padding(
                        padding: EdgeInsets.only(left: 40),
                        child: Text(
                          'EDIT',
                          textAlign: TextAlign.end,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    secondaryBackground: Container(
                      alignment: Alignment.centerRight,
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(16)),
                      child: const Padding(
                        padding: EdgeInsets.only(right: 40),
                        child: Text(
                          'DELETE',
                          textAlign: TextAlign.end,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    key: UniqueKey(),
                    child: InkWell(
                      onTap: () => showModalBottomSheet(
                        isDismissible: false,
                        enableDrag: false,
                        isScrollControlled: true,
                        context: context,
                        builder: (context) => AddReminder(
                          view: true,
                          title: userData[index]['title'],
                          notes: userData[index]['notes'],
                          date: userData[index]['date'],
                          latitude: (userData[index]["location"] as GeoPoint).latitude,
                          longitude: (userData[index]["location"] as GeoPoint).longitude,
                        ),
                        //initial Location
                      ),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        shadowColor: backgroundColor,
                        elevation: 3,
                        color: Colors.white,
                        child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        (userData[index]['date'] as String).substring(0, 2),
                                        style: const TextStyle(color: mainColor, fontSize: 40, fontWeight: FontWeight.bold, fontFamily: fontFamily2),
                                      ),
                                      Text(
                                        // userData[index]['date'],
                                        formatter.format(DateFormat('dd-MM-yyyy').parse(userData[index]['date'])).toString(),
                                        style: const TextStyle(color: darkColor),
                                      )
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    // mainAxisSize: MainAxisSize.min,

                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        (userData[index]['title']),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        userData[index]['notes'],
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: Colors.blueGrey[500]),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            )),
                      ),
                    ),
                  );
                },
              ));
        });
  }
}
