import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';


const platform = MethodChannel('com.example/height');


void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File? _image;
  double? _treeHeight;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _calculateHeight(pickedFile.path);
    }
  }

  Future<void> _calculateHeight(String imagePath) async {
    try {
      final double result = await platform.invokeMethod('processImage', {
        'imagePath': imagePath,
        'referenceHeight': 2.0, // Example reference height in meters
      });
      setState(() {
        _treeHeight = result;
      });
    } on PlatformException catch (e) {
      print("Failed to get height: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Tree Height Measurement'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _image == null
                  ? const Text('No image selected.')
                  : Image.file(_image!),
              const SizedBox(height: 20),
              _treeHeight == null
                  ? const Text('Tree height not calculated yet.')
                  : Text('Estimated Tree Height: ${_treeHeight!.toStringAsFixed(2)} meters'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Capture Image'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
