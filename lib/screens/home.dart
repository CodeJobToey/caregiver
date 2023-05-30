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
  Set<Circle> circlesPosition = {};
  List<LatLng> latLngs = [];
  List<double> radiusPosition = [];
  List<double> distancesPatient = [];

  GoogleMapController? mapController;

  double patientLat = 0.0;
  double patientLon = 0.0;

  LatLng _currentPatient = const LatLng(0, 0);

  DataFirebase saveData = DataFirebase();
  DataFirebase dataPositions = DataFirebase();
  DataFirebase dataLocation = DataFirebase();
  Calculate calculateDistances = Calculate();

  TextEditingController radiusController = TextEditingController();
  TextEditingController documentController = TextEditingController();
  TextEditingController homeLat = TextEditingController();
  TextEditingController homeLon = TextEditingController();
  TextEditingController homeRadius = TextEditingController();

  Future<void> getCirclesData() async {
    latLngs.clear();
    radiusPosition.clear();
    circlesPosition.clear();
    distancesPatient.clear();

    await calculateDistances.distance();
    distancesPatient = calculateDistances.distancesPatient;

    await dataLocation.locationCollection();
    LatLng home = dataLocation.homeData;
    double radiusHome = dataLocation.radius;
    latLngs.add(home);
    radiusPosition.add(radiusHome);

    await dataPositions.positionCollection();
    List<Map<String, dynamic>> positions = dataPositions.position;

    for (var pos in positions) {
      double posLat = pos['latitude'];
      double posLon = pos['longitude'];
      double radius = pos['radius'];

      LatLng position = LatLng(posLat, posLon);
      latLngs.add(position);
      radiusPosition.add(radius);
    }
    for (var i = 0; i < latLngs.length; i++) {
      if (distancesPatient[i] <= radiusPosition[i]) {
        setState(() {
          circlesPosition.add(
            Circle(
              circleId: CircleId(i.toString()),
              center: latLngs[i],
              radius: radiusPosition[i],
              fillColor: Colors.blue.withOpacity(0.3),
              strokeColor: Colors.blue,
              strokeWidth: 2,
            ),
          );
        });
      } else {
        if (i == 0) {
          showAlert();
        }
        setState(() {
          circlesPosition.add(
            Circle(
              circleId: CircleId(i.toString()),
              center: latLngs[i],
              radius: radiusPosition[i],
              fillColor: Colors.red.withOpacity(0.3),
              strokeColor: Colors.red,
              strokeWidth: 2,
            ),
          );
        });
      }
    }
  }

  void showCautionAlert(double meters) {
    final currentContext = context;
    showDialog(
      context: currentContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Please be careful'),
          content: Text(
              'Please be careful when patients are about to exit the area within another $meters meters.'),
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

  void showAlert() {
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

  @override
  void initState() {
    super.initState();
    getCirclesData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Set home location'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: homeLat,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Home Latitude',
                          ),
                        ),
                        TextField(
                          controller: homeLon,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Home Longitude',
                          ),
                        ),
                        TextField(
                          controller: homeRadius,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Home Radius',
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          double lat = double.parse(homeLat.text);
                          double lon = double.parse(homeLon.text);
                          double radius = double.parse(homeRadius.text);
                          saveData.saveHomeLocation(lat, lon, radius);
                          getCirclesData();

                          Navigator.of(context).pop();
                        },
                        child: const Text('Set'),
                      )
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.add_location_alt),
          )
        ],
      ),
      body: StreamBuilder(
        stream: firestore.collection('Location').doc('patient').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          patientLat = snapshot.data!['latitude'];
          patientLon = snapshot.data!['longitude'];

          _currentPatient = LatLng(patientLat, patientLon);

          return GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition:
                CameraPosition(target: _currentPatient, zoom: _zoom),
            onMapCreated: (controller) {
              setState(() {
                mapController = controller;
              });
            },
            markers: {
              Marker(
                markerId: const MarkerId('currentLocation'),
                position: _currentPatient,
              ),
            },
            circles: circlesPosition,
            onTap: (LatLng position) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Set Circle Radius'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: documentController,
                          decoration: const InputDecoration(
                            labelText: 'Name Circle',
                          ),
                        ),
                        TextField(
                          controller: radiusController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Radius',
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          String document =
                              documentController.text.toLowerCase();
                          double radius = double.parse(radiusController.text);
                          saveData.savePositions(position.latitude,
                              position.longitude, radius, document);
                          getCirclesData();

                          Navigator.of(context).pop();
                        },
                        child: const Text('Set'),
                      )
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
