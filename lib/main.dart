import 'package:flutter/material.dart';
import 'package:ml/home.dart';
import 'package:camera/camera.dart';

List<CameraDescription>? camera;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  camera = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}
