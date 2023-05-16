import 'dart:async';

// import 'package:caregiver/screens/dataFirebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
//   double _setRadius = 0.0;
//   final Set<Circle> _circles = {}; // Set to store circles on the map

//   final double _zoom = 16.0;
//   LatLng _currentLocation = const LatLng(0, 0);

//   final FirebaseFirestore firestore = FirebaseFirestore.instance;

//   final Completer<GoogleMapController> _controllers = Completer();
//   final fieldText = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text('Caregiver'),
//           centerTitle: true,
//           actions: <Widget>[
//             IconButton(
//                 onPressed: () {
//                   popUp(context, fieldText);
//                 },
//                 icon: const Icon(Icons.add_location_alt))
//           ],
//         ),
//         body: GoogleMap(
//           //ขออนุญาตให้เข้าดู location ของเราได้ - เจ้าของบ้านจะอนุญาตให้เข้าถึงตำแหน่งหรือเปล่า?
//           myLocationEnabled: true,
//           // กำหนดให้ แผนที่แสดงออกมาในรูปแบบ normal
//           mapType: MapType.normal,
//           onMapCreated: (GoogleMapController controller) {
//             _controllers.complete(controller);
//           },
//           // กำหนดตำแหน่งเริ่มต้นให้กับแอปพลิเคชัน
//           initialCameraPosition: CameraPosition(
//             target: _currentLocation,
//             zoom: _zoom,
//           ),
//           markers: {
//             Marker(
//                 markerId: const MarkerId('currentLocation'),
//                 position: _currentLocation),
//           },
//           circles: _circles,
//         ));
//   }

//   Future<dynamic> popUp(BuildContext context, TextEditingController fieldText) {
//     return showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: const Text('Set Radius'),
//             content: Column(
//               children: [
//                 TextField(
//                   keyboardType: TextInputType.number,
//                   decoration: const InputDecoration(
//                     labelText: 'Home latitude',
//                   ),
//                   onChanged: (value) {
//                     // homeLatitude = double.parse(value);
//                   },
//                 ),
//                 TextField(
//                   keyboardType: TextInputType.number,
//                   decoration: const InputDecoration(
//                     labelText: 'Home longitude',
//                   ),
//                   onChanged: (value) {
//                     // homeLongitude = double.parse(value);
//                   },
//                 ),
//                 TextField(
//                   keyboardType: TextInputType.number,
//                   decoration: const InputDecoration(
//                     labelText: 'Radius',
//                   ),
//                   onChanged: (value) {
//                     _setRadius = double.parse(value);
//                   },
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 child: const Text('OK'),
//                 onPressed: () {
//                   setHomeLocation();
//                   Navigator.pop(context);
//                 },
//               ),
//               TextButton(
//                 child: const Text('Cancel'),
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//               ),
//             ],
//           );
//         });
//   }

//   void setCircles() {
//     print(_setRadius);
//     return setState(() {
//       _circles.add(
//         Circle(
//           circleId: const CircleId('patient'), // Unique ID for the circle
//           center: const LatLng(0, 0), // Home location (latitude, longitude)
//           radius: _setRadius, // Radius in meters
//           strokeWidth: 2, // Width of the circle's stroke
//           strokeColor: Colors.blue, // Color of the circle's stroke
//           fillColor: Colors.blue.withOpacity(0.2), // Fill color of the circle
//         ),
//       );
//     });
//   }

//   Future setHomeLocation() async {
//     final homeLocation = await _controllers.future;

//     homeLocation.animateCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(
//           target: const LatLng(0, 0),
//           zoom: _zoom,
//         ),
//       ),
//     );
//     setCircles();
//     // print(calculate().compareDistanceRadius(
//     //     homeLocationPatient, _currentLocation, _setRadius));
//     print(_setRadius);

//     // var pp = DataFirebase();
//     // print('tttt ');
//     // print(pp.home());
//     // await pp.home();
//     // print('radiusLongitude : ${pp.radiusLongitude}');
//     // print('tttt : ${dsd['radiusLongitude']}');
//   }
// }

  LatLng _currentLocation = const LatLng(0, 0);
  LocationData? _locationData;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionStatus;

    // Check if location service is enabled
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        setState(() {
          _currentLocation = const LatLng(0, 0);
        });
        return;
      }
    }

    // Check location permission
    permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        setState(() {
          _currentLocation = const LatLng(0, 0);
        });
        return;
      }
    }

    try {
      _locationData = await location.getLocation();
      setState(() {
        _currentLocation =
            LatLng(_locationData!.latitude!, _locationData!.longitude!);
      });

      // Move the map camera to current location
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(_currentLocation),
        );
      }
    } catch (e) {
      print('Error getting current location: $e');
      setState(() {
        _currentLocation = const LatLng(0, 0);
      });
    }
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
        initialCameraPosition: CameraPosition(
          target: _currentLocation,
          zoom: 15.0,
        ),
        onMapCreated: (controller) {
          _mapController = controller;
        },
        markers: {
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: _currentLocation,
          ),
        },
      ),
    );
  }
}


 // Future<void> _createCircle() async {
  //   homeLat = getData.homeLatitude;
  //   homeLon = getData.homeLongitude;
  //   radius = getData.radius;

  //   distance = getCalculate.distanceRadius;

  //   if (distance <= radius) {
  //     setState(() {
  //       _circles.add(
  //         Circle(
  //           circleId: const CircleId('HomeLocation'),
  //           center: LatLng(homeLat, homeLon),
  //           radius: radius,
  //           strokeWidth: 2,
  //           strokeColor: Colors.blue,
  //           fillColor: Colors.blue.withOpacity(0.2),
  //         ),
  //       );
  //     });
  //   } else {
  //     // ignore: use_build_context_synchronously
  //     showDialog(
  //         context: context,
  //         builder: (context) {
  //           return AlertDialog(
  //             title: const Text('The patient is out of area'),
  //             content: const Text('Please find the patient Immedietly.'),
  //             actions: [
  //               TextButton(
  //                 child: const Text('OK'),
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                 },
  //               ),
  //               TextButton(
  //                 child: const Text('Cancel'),
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                 },
  //               ),
  //             ],
  //           );
  //         });

  //     setState(() {
  //       _circles.add(
  //         Circle(
  //           circleId: const CircleId('HomeLocation'),
  //           center: LatLng(homeLat, homeLon),
  //           radius: radius,
  //           strokeWidth: 2,
  //           strokeColor: Colors.red,
  //           fillColor: Colors.red.withOpacity(0.2),
  //         ),
  //       );
  //     });
  //   }
  // }
// }