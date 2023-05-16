import 'dart:async';

import 'package:caregiver/algorithm/data_firebase.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GoogleMapController? _mapController;
  final double _zoom = 16.0;
  final Set<Circle> _circles = {}; // Set to store circles on the map

  var getDataHome = DataFirebase();
  var getDataPatient = DataFirebase();

  double patientLat = 0.0;
  double patientLon = 0.0;

  LatLng _currentPatient = const LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    _getDataPatient();
  }

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
      body: GoogleMap(
        myLocationEnabled: true,
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: _currentPatient,
          zoom: _zoom,
        ),
        onMapCreated: (controller) {
          print(controller);

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
      ),
    );
  }

  Future<void> _getDataPatient() async {
    await getDataPatient.patient();
    patientLat = getDataPatient.patientLatitude;
    patientLon = getDataPatient.patientLongitude;

    Location location = Location();
    bool serviceEnabled;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        setState(() {
          _currentPatient = const LatLng(0, 0);
        });
        return;
      }
    }

    try {
      print(_mapController);
      setState(() {
        _currentPatient = LatLng(patientLat, patientLon);
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(_currentPatient),
        );
      }
    } catch (e) {
      print('Error getting current location: $e');
      setState(() {
        _currentPatient = const LatLng(0, 0);
      });
    }
  }
}
