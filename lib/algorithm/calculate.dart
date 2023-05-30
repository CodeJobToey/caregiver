import 'dart:math';

import 'package:caregiver/algorithm/data_firebase.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Calculate extends ChangeNotifier {
  List<double> distancesPatient = [];
  DataFirebase dataPositions = DataFirebase();
  DataFirebase dataLocation = DataFirebase();

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6370000; // รัศมีโลกมีค่าประมาณ 6.37*10^6
    const p = pi / 180; // แปลงค่าคงที่ให้เป็นองศาเรเดียน

    var disLat = (lat1 - lat2) * p;
    var disLon = (lon1 - lon2) * p;

    var a = (sin(disLat / 2) * sin(disLat / 2)) +
        cos(lat1 * p) * cos(lat2 * p) * (sin(disLon / 2) * sin(disLon / 2));
    var c = 2 * asin(sqrt(a));
    var distance = earthRadius * c;

    return distance;
  }

  Future<void> distance() async {
    distancesPatient.clear();

    await dataLocation.locationCollection();
    LatLng patient = dataLocation.patientData;
    LatLng home = dataLocation.homeData;

    double dis = calculateDistance(
        home.latitude, home.longitude, patient.latitude, patient.longitude);

    distancesPatient.add(dis);

    await dataPositions.positionCollection();

    List<Map<String, dynamic>> positions = dataPositions.position;

    for (var pos in positions) {
      double posLat = pos['latitude'];
      double posLon = pos['longitude'];

      double disPosition = calculateDistance(
          posLat, posLon, patient.latitude, patient.longitude);

      distancesPatient.add(disPosition);
    }

    notifyListeners();
  }
}
