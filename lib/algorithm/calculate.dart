import 'dart:math';

import 'package:caregiver/algorithm/data_firebase.dart';
import 'package:flutter/material.dart';

class Calculate extends ChangeNotifier {
  double homeLat = 0.0;
  double homeLon = 0.0;
  double patientLat = 0.0;
  double patientLon = 0.0;
  double radius = 0.0;
  double distanceRadius = 0.0;

  var getData = DataFirebase();

  Future<void> distance() async {
    await getData.patient();
    patientLat = getData.patientLatitude;
    patientLon = getData.patientLongitude;

    await getData.home();
    homeLat = getData.homeLatitude;
    homeLon = getData.homeLongitude;
    radius = getData.radius;

    const earthRadius = 6370000; // รัศมีโลกมีค่าประมาณ 6.37*10^6
    const p = pi / 180; // แปลงค่าคงที่ให้เป็นองศาเรเดียน

    var disLat = (homeLat - patientLat) * p;
    var disLon = (homeLon - patientLon) * p;

    // คำนวณระยะทางระหว่างจุดสองจุดโดยใช้สูตร Haversine
    var a = (sin(disLat / 2) * sin(disLat / 2)) +
        cos(homeLat * p) *
            cos(patientLat * p) *
            (sin(disLon / 2) * sin(disLon / 2));
    var c = 2 * atan(sqrt(a));
    distanceRadius = earthRadius * c;

    notifyListeners();
  }
}
