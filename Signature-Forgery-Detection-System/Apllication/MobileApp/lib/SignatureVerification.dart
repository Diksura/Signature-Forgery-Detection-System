import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignatureVerification extends StatefulWidget {
  @override
  _SignatureVerificationState createState() => _SignatureVerificationState();
}

class _SignatureVerificationState extends State<SignatureVerification> {
  File? _image1;
  File? _image2;
  String _result = "";

  final ImagePicker _picker = ImagePicker();
  final String apiUrl = "http://127.0.0.1:5000/predict"; // Change this when deploying

  // Pick an image from gallery or camera
  Future<void> _pickImage(bool isFirstImage) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (isFirstImage) {
          _image1 = File(pickedFile.path);
        } else {
          _image2 = File(pickedFile.path);
        }
      });
    }
  }

  // Send images to backend
  Future<void> _verifySignature() async {
    if (_image1 == null || _image2 == null) {
      setState(() => _result = "Please select both images.");
      return;
    }

    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.files.add(await http.MultipartFile.fromPath('image1', _image1!.path));
    request.files.add(await http.MultipartFile.fromPath('image2', _image2!.path));

    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    var jsonResponse = json.decode(responseData);

    setState(() {
      _result = jsonResponse["result"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Signature Verification")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _image1 != null ? Image.file(_image1!, width: 100, height: 100) : Placeholder(fallbackHeight: 100, fallbackWidth: 100),
              _image2 != null ? Image.file(_image2!, width: 100, height: 100) : Placeholder(fallbackHeight: 100, fallbackWidth: 100),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(onPressed: () => _pickImage(true), child: Text("Pick Genuine Signature")),
          ElevatedButton(onPressed: () => _pickImage(false), child: Text("Pick Test Signature")),
          SizedBox(height: 20),
          ElevatedButton(onPressed: _verifySignature, child: Text("Verify Signature")),
          SizedBox(height: 20),
          Text("Result: $_result", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
