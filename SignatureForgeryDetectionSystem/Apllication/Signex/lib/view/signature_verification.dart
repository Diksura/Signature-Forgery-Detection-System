import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../view/results_page.dart';

class SignatureVerification extends StatefulWidget {
  const SignatureVerification({super.key});

  @override
  State<SignatureVerification> createState() => _SignatureVerification1State();
}

class _SignatureVerification1State extends State<SignatureVerification> {
  File? _image;

  final ImagePicker _picker = ImagePicker();

  // Pick an image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Image Source Bottom Sheet
  void _showImageSourceSelection() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18.0, 32.0, 18.0, 18.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    "Select an Option:",
                    style: TextStyle(fontSize: 24.0, color: Colors.blue.shade800),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.camera);
                        },
                        label: const Text("Camera"),
                        icon: const Icon(CupertinoIcons.camera),
                        iconAlignment: IconAlignment.end,
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.gallery);
                        },
                        label: const Text("Gallery"),
                        icon: const Icon(CupertinoIcons.photo_on_rectangle),
                        iconAlignment: IconAlignment.end,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Verify images
  Future<void> _verifySignature() async {
    if (_image == null) {
      _showAlert("No image selected", "No images has selected, Please select an image to verify.");
    } else {
      String extension = _image!.path.split('.').last.toLowerCase();

      if (extension != 'png' && extension != 'jpeg' && extension != 'jpg') {
        _showAlert(
            "Invalid file format", "Unsupported file format, Please upload an image with PNG or JPEG file format.");
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ResultsPage(image: _image!)),
        );
      }
    }
  }

  // Alert Dialog
  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Signature Verification")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Icon(
                Icons.info_outline,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: GestureDetector(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _image != null
                      ? Image.file(
                          _image!,
                          height: 400,
                          width: 400,
                        )
                      : Image.asset(
                          "assets/images/upload_logo.png",
                          color: Colors.grey.shade400,
                        ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      "Note: Only compatible with JPEG and PNG. Make sure upload compatible file format",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                    child: OutlinedButton(
                      onPressed: () => _showImageSourceSelection(),
                      child: const Text("Choose Signature"),
                    ),
                  ),
                ],
              ),
              onTap: () => _showImageSourceSelection(),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30.0, top: 90.0, right: 10.0),
              child: ElevatedButton.icon(
                onPressed: _verifySignature,
                label: const Text("Verify"),
                icon: const Icon(Icons.arrow_forward_ios),
                iconAlignment: IconAlignment.end,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  iconColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
