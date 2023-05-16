import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const Amatrix());
}

class Amatrix extends StatelessWidget {
  const Amatrix({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Caregiver',
      home: Home(),
    );
  }
}
