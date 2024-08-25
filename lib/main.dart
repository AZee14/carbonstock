import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Uint8List? _imageData;

  Future<void> _captureAndDetectFace() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      final mat = cv.imread(image.path);
      final gray = cv.cvtColor(mat, cv.COLOR_BGR2GRAY);

      setState(() {
        _imageData = cv.imencode(".png", mat).$2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Face Detection')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_imageData != null) Image.memory(_imageData!),
              ElevatedButton(
                onPressed: _captureAndDetectFace,
                child: const Text('Capture & Detect Face'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
