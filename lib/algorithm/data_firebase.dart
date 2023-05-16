import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;
final documentPatient = firestore.collection('patient').doc('LatLng');
final documentHome = firestore.collection('homeLocation').doc('home');

class DataFirebase extends ChangeNotifier {
  double homeLatitude = 0.0;
  double homeLongitude = 0.0;
  double radius = 0.0;
  double patientLatitude = 0.0;
  double patientLongitude = 0.0;

  Future<void> patient() async {
    final documentSnapshot = await documentPatient.get();
    final patientData = documentSnapshot.data();
    patientLatitude = double.parse(patientData!['latitude'].toString());
    patientLongitude = double.parse(patientData['longitude'].toString());

    // อัพค่าตัวแปร
    notifyListeners();
  }

  Future<void> home() async {
    final documentSnapshot = await documentHome.get();
    final homeData = documentSnapshot.data();
    homeLatitude = double.parse(homeData!['latitude'].toString());
    homeLongitude = double.parse(homeData['longitude'].toString());
    radius = double.parse(homeData['radius'].toString());

    // อัพค่าตัวแปร
    notifyListeners();

    // return {'currentHome': _currentHome, 'radiusLongitude': radiusLongitude};
  }

  void saveHomeLocation(double lat, double lon, double radius) async {
    var homeData = {"latitude": lat, "longitude": lon, "radius": radius};

    FirebaseFirestore.instance
        .collection('homeLocation')
        .doc('home')
        .set(homeData)
        .catchError((error) {
      print('Error save home location:   $error');
    });
  }

  //notifyListeners();
}
