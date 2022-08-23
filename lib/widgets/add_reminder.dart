import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:reminder/helpers/constants.dart';
import 'package:google_place/google_place.dart';
import '../models/place.dart';
import 'package:google_maps_webservice/places.dart';

class AddReminder extends StatefulWidget {
  final bool isSelecting;
  final bool view;
  final String title;
  final String notes;
  final String date;
  final bool edit;
  double latitude;
  double longitude;
  String? docId;
  AddReminder(
      {this.view = false,
      this.edit = false,
      this.title = '',
      this.notes = '',
      this.date = '',
      this.isSelecting = false,
      required this.latitude,
      required this.longitude,
      this.docId,
      Key? key})
      : super(key: key);

  @override
  State<AddReminder> createState() => _AddReminderState();
}

class _AddReminderState extends State<AddReminder> {
  var userdata = FirebaseAuth.instance.currentUser;
  TextEditingController titleController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  ScrollController scrollController = ScrollController();

  PlaceLocation? _pickedLocation;
  LatLng? mylocation;
  String? currentdate;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initialDate();
    getData();
  }

  void getData() {
    if (widget.edit) {
      titleController.text = widget.title;
      notesController.text = widget.notes;
      currentdate = widget.date;
      // mylocation = LatLng(latitude, longitude);
      mylocation = LatLng(widget.latitude, widget.longitude);
    } else if (widget.edit == false && widget.view == false) {
      mylocation = LatLng(widget.latitude, widget.longitude);
    }
    setState(() {});
  }

  void _initialDate() {
    setState(() {
      currentdate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    });
  }

  void pickDate() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2200),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: mainColor, // header background color
              onPrimary: Colors.white, // header text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: mainColor, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    ).then((value) {
      if (value == null) {
        return;
      }
      setState(() {
        currentdate = DateFormat('dd-MM-yyyy').format(value);
      });
    });
  }

  void addToDb() {
    if (_formKey.currentState!.validate()) {
      final result = FirebaseFirestore.instance.collection('Reminders').doc(userdata!.uid);
      DocumentReference<Map<String, dynamic>> resData = result.collection("userReminders").doc();
      resData.set({
        "id": userdata!.uid,
        "title": titleController.text,
        "notes": notesController.text,
        "location": GeoPoint(mylocation!.latitude, mylocation!.longitude),
        "date": currentdate,
      });
      setState(() {
        titleController.text = "";
        notesController.text = "";
      });
      Navigator.of(context).pop();
    }
  }

  void updateDb() {
    if (_formKey.currentState!.validate()) {
      final result = FirebaseFirestore.instance.collection('Reminders').doc(userdata!.uid);

      DocumentReference<Map<String, dynamic>> resData = result.collection("userReminders").doc(widget.docId);
      resData.set({
        "id": userdata!.uid,
        "title": titleController.text,
        "notes": notesController.text,
        "location": GeoPoint(mylocation!.latitude, mylocation!.longitude),
        "date": currentdate,
      });
      setState(() {
        titleController.text = "";
        notesController.text = "";
      });
      Navigator.of(context).pop();
    }
  }

  void _selectLocation(LatLng position) {
    setState(() {
      mylocation = position;
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    notesController.dispose();
    super.dispose();
  }

  String apiKey = 'AIzaSyBd0BojRTwnraL7gRa1KEfC7qV1lyayLEQ';
  List<AutocompletePrediction> predictions = [];

  void autoCompleteSearch(String value) async {
    GooglePlace googlePlace = GooglePlace(apiKey);
    print(value);
    var result = await googlePlace.autocomplete.get(value);
    print(result!.status);
    if (result != null && result.predictions != null && mounted) {
      print(result.predictions);
      print(result.predictions!.first.description);
      setState(() {
        predictions = result.predictions!;
        print("workingfine");
      });
    }
  }

  Completer<GoogleMapController> _controller = Completer();
  Future<void> moveCamera() async {
    final GoogleMapController controller = await _controller.future;
    controller.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: mylocation ?? LatLng(widget.latitude, widget.longitude),
          zoom: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0XFFF1F3F4),
      // for back button on map
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: kToolbarHeight + 20),
        child: FloatingActionButton(
          elevation: 2,
          backgroundColor: Colors.white70,
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // for displaying google maps
            Container(
              height: size.height * 0.65,
              foregroundDecoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.1, 0.3, 0.5, 0.7, 1.0],
                  colors: [Colors.transparent, Colors.transparent, Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.1), const Color(0XFFF1F3F4)],
                ),
              ),
              child: GoogleMap(
                padding: const EdgeInsets.only(bottom: 20),
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    widget.latitude,
                    widget.longitude,
                  ),
                  zoom: 16,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                onTap: widget.view ? null : _selectLocation,
                markers: (_pickedLocation == null && widget.isSelecting)
                    ? {}
                    : {
                        Marker(
                          markerId: const MarkerId('m1'),
                          position: mylocation ?? LatLng(widget.latitude, widget.longitude),
                        ),
                      },
              ),
            ),
            // for user reminder adding
            if (widget.view == false) ...[
              // for displaying date
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: Text(
                  currentdate!,
                  style: const TextStyle(fontSize: 20, fontFamily: fontFamily2),
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 15),
                      child: TextFormField(
                        onChanged: (value) {
                          autoCompleteSearch(value);
                        },
                        textInputAction: TextInputAction.done,
                        controller: searchController,
                        decoration: const InputDecoration(
                            focusColor: mainColor,
                            disabledBorder:
                                OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: Colors.grey, width: 1.5)),
                            focusedBorder:
                                OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: Colors.grey, width: 1.5)),
                            border:
                                OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: Colors.grey, width: 1.5)),
                            labelText: 'Search Location',
                            labelStyle: TextStyle(color: mainColor)),
                      ),
                    ),
                    Container(
                      // height: 200,
                      margin:  EdgeInsets.only(bottom:predictions.isEmpty ? 2 : 10),
                      child: ListView.builder(
                          controller: scrollController,
                          shrinkWrap: true,
                          itemCount: predictions.length,
                          itemBuilder: (c, i) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 30, right: 20, top: 8, bottom: 8),
                              child: InkWell(
                                  onTap: () async {
                                    GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: apiKey);

                                    PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(predictions[i].placeId!);
                                    mylocation = LatLng(detail.result.geometry!.location.lat, detail.result.geometry!.location.lng);
                                    moveCamera();
                                    setState(() {
                                      searchController.text = predictions[i].description!;
                                      predictions.clear();
                                    });
                                  },
                                  child: Text(
                                    predictions[i].description ?? '',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                  )),
                            );
                          }),
                    ),
                    //  for title textfield
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter title';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.done,
                        controller: titleController,
                        decoration: const InputDecoration(
                            focusColor: mainColor,
                            disabledBorder:
                                OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: Colors.grey, width: 1.5)),
                            focusedBorder:
                                OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: Colors.grey, width: 1.5)),
                            border:
                                OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: Colors.grey, width: 1.5)),
                            labelText: 'Title',
                            labelStyle: TextStyle(color: mainColor)),
                      ),
                    ),
                    //  for notes textfield
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
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
                          labelText: 'Notes',
                          labelStyle: TextStyle(color: mainColor),
                        ),
                      ),
                    ),
                    // for adding reminder button
                    Container(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  primary: mainColor,
                                  minimumSize: const Size(
                                    100,
                                    55,
                                  ),
                                ),
                                onPressed: widget.edit ? updateDb : addToDb,
                                child: widget.edit
                                    ? const Text(
                                        'Update Reminder',
                                        style: TextStyle(fontSize: 18),
                                      )
                                    : const Text(
                                        'Add Reminder',
                                        style: TextStyle(fontSize: 18),
                                      ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  primary: mainColor,
                                  onSurface: mainColor,
                                  minimumSize: const Size(
                                    55,
                                    55,
                                  ),
                                ),
                                onPressed: pickDate,
                                child: const Icon(Icons.calendar_month_outlined)),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            //  for user reminder view
            if (widget.view) ...[
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                child: Text(
                  widget.notes,
                  style: TextStyle(fontSize: 17, color: Colors.blueGrey[500]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                child: Text(
                  widget.date,
                  style: const TextStyle(fontSize: 16, color: mainColor),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
