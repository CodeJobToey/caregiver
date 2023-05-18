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
  GoogleMapController? _mapController;
  final double _zoom = 16.0;
  final Set<Circle> _circles = {}; // Set to store circles on the map

  var getDataHome = DataFirebase();
  var getDataPatient = DataFirebase();

  double patientLat = 0.0;
  double patientLon = 0.0;

  LatLng _currentPatient = const LatLng(0, 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(onPressed: () {}, icon: const Icon(Icons.add_location_alt))
        ],
      ),
      body: StreamBuilder(
        stream: firestore.collection('patient').doc('LatLng').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          patientLat = snapshot.data!['latitude'];
          patientLon = snapshot.data!['longitude'];

          _currentPatient = LatLng(patientLat, patientLon);
          return GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: _currentPatient,
              zoom: _zoom,
            ),
            onMapCreated: (controller) {
              setState(() {
                _mapController = controller;
              });
            },
            markers: {
              Marker(
                markerId: const MarkerId('currentLocation'),
                position: _currentPatient,
              ),
            },
            circles: _circles,
          );
        },
      ),
    );
  }
}
