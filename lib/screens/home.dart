import 'dart:async';

import 'package:caregiver/algorithm/calculate.dart';
import 'package:caregiver/algorithm/data_firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final double _zoom = 16.0;
  final Set<Circle> _circles = {};
  GoogleMapController? _mapController;

  var getDataHome = DataFirebase();
  var getDataPatient = DataFirebase();
  var getCalculate = Calculate();

  double patientLat = 0.0;
  double patientLon = 0.0;
  double radius = 0.0;
  double homeLat = 0.0;
  double homeLon = 0.0;
  double distance = 0.0;

  LatLng _currentPatient = const LatLng(0, 0);
  LatLng _currentHome = const LatLng(0, 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              _showSetRadius();
            },
            icon: const Icon(Icons.add_location_alt),
          )
        ],
      ),
      body: StreamBuilder(
        stream: firestore.collection('patient').doc('LatLng').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          patientLat = snapshot.data!['latitude'];
          patientLon = snapshot.data!['longitude'];

          _currentPatient = LatLng(patientLat, patientLon);
          getData();
          // _configureCircles();

          return GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition:
                CameraPosition(target: _currentPatient, zoom: _zoom),
            onMapCreated: (controller) {
              setState(() {
                _mapController = controller;
              });
            },
            markers: {
              Marker(
                  markerId: const MarkerId('currentLocation'),
                  position: _currentPatient)
            },
            circles: Set.from(_circles),
          );
        },
      ),
    );
  }

  Future<void> getData() async {
    await getDataHome.home();
    homeLat = getDataHome.homeLatitude;
    homeLon = getDataHome.homeLongitude;
    radius = getDataHome.radius;

    await getCalculate.distance();
    distance = getCalculate.distanceRadius;

    _currentHome = LatLng(homeLat, homeLon);
    _configureCircles();

    if (distance <= radius) {
    } else {
      _showAlert();
    }
  }

  void _showSetRadius() {
    double latitude = 0.0;
    double longitude = 0.0;
    double radiusCircle = 0.0;
    final currentContext = context;
    showDialog(
        context: currentContext,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text('Set Radius'),
              content: Column(children: [
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Home latitude',
                  ),
                  onChanged: (value) {
                    latitude = double.parse(value);
                  },
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Home longitude',
                  ),
                  onChanged: (value) {
                    longitude = double.parse(value);
                  },
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Radius',
                  ),
                  onChanged: (value) {
                    radiusCircle = double.parse(value);
                  },
                )
              ]),
              actions: [
                TextButton(
                  onPressed: () {
                    if (latitude != 0.0 && longitude != 0.0) {
                      getDataHome.saveHomeLocation(
                          latitude, longitude, radiusCircle);
                    } else {
                      getDataHome.saveHomeLocation(
                          homeLat, homeLon, radiusCircle);
                    }
                    Navigator.of(currentContext).pop();
                  },
                  child: const Text('OK'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(currentContext).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ]);
        });
  }

  void _configureCircles() {
    Color circleColor = distance > radius ? Colors.red : Colors.blue;

    _circles.clear();
    _circles.add(
      Circle(
        circleId: const CircleId('HomeLocation'),
        center: _currentHome,
        radius: radius, // Circle radius in meters
        fillColor: circleColor.withOpacity(0.3),
        strokeColor: circleColor,
        strokeWidth: 2,
      ),
    );
  }

  void _showAlert() {
    final currentContext = context;
    showDialog(
      context: currentContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('The patient is out of area'),
          content: const Text('Please find the patient Immedietly.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(currentContext).pop();
              },
              child: const Text('OK'),
            )
          ],
        );
      },
    );
  }
}
