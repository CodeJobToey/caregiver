import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

class DataFirebase extends ChangeNotifier {
  List<Map<String, dynamic>> position = [];
  List<Map<String, dynamic>> location = [];
  List<Map<String, dynamic>> caculate = [];

  LatLng patientData = const LatLng(0, 0);
  LatLng homeData = const LatLng(0, 0);
  double radius = 0.0;

  Future<void> positionCollection() async {
    position.clear();
    QuerySnapshot snapshot = await firestore.collection('Positions').get();
    for (var doc in snapshot.docs) {
      Map<String, dynamic> documentData = doc.data() as Map<String, dynamic>;
      documentData['Document Name'] = doc.id;

      position.add(documentData);
    }
    notifyListeners();
  }

  Future<void> locationCollection() async {
    location.clear();
    QuerySnapshot snapshot = await firestore.collection('Location').get();
    for (var doc in snapshot.docs) {
      Map<String, dynamic> documentData = doc.data() as Map<String, dynamic>;
      documentData['Document Name'] = doc.id;

      location.add(documentData);
      if (doc.id == 'patient') {
        patientData = LatLng(double.parse(documentData['latitude'].toString()),
            double.parse(documentData['longitude'].toString()));
      } else {
        homeData = LatLng(double.parse(documentData['latitude'].toString()),
            double.parse(documentData['longitude'].toString()));
        radius = double.parse(documentData['radius'].toString());
      }
    }
    notifyListeners();
  }

  Future<void> caculateCollection() async {
    caculate.clear();
    QuerySnapshot snapshot = await firestore.collection('Caculate').get();
    for (var doc in snapshot.docs) {
      Map<String, dynamic> documentData = doc.data() as Map<String, dynamic>;
      documentData['Document Name'] = doc.id;

      caculate.add(documentData);
    }
    notifyListeners();
  }

  void saveHomeLocation(double lat, double lon, double radius) {
    var home = {"latitude": lat, "longitude": lon, 'radius': radius};

    FirebaseFirestore.instance
        .collection('Location')
        .doc('home')
        .set(home)
        .catchError((error) {
      print('Error save home location: $error');
    });
  }

  void savePositions(double lat, double lon, double radius, String document) {
    var position = {'latitude': lat, 'longitude': lon, 'radius': radius};

    FirebaseFirestore.instance
        .collection('Positions')
        .doc(document)
        .set(position)
        .catchError((error) {
      print('Error save home location: $error');
    });
  }

  void saveCaculate(String document, double distance) {
    var cacuclatePosition = {document: distance};

    FirebaseFirestore.instance
        .collection('Positions')
        .doc(document)
        .set(cacuclatePosition)
        .catchError((error) {
      print('Error save home location: $error');
    });
  }
}
