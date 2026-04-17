import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signx/view/prediction_results_screen.dart';
import 'package:signx/view_model/image_picker.dart';

import '../constants/background_gradient.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  XFile? _selectedImage;
  final ImagePickerHelper _imageHelper = ImagePickerHelper();

  void _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const _ImageSourceSheet(),
    );

    if (source == null) return;

    XFile? image;
    if (source == ImageSource.camera) {
      image = await _imageHelper.pickFromCamera();
    } else {
      image = await _imageHelper.pickFromGallery();
    }

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgery Prediction'), elevation: 0, backgroundColor: Colors.transparent),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: kBGLinearGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                /// Title
                const Text(
                  "Upload Signature",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500, color: Color(0xFF5F58D5)),
                ),

                const SizedBox(height: 8),

                /// Description
                const Text(
                  "We analyze writing patterns like stroke consistency, pressure, and ink distribution to detect possible forgery.",
                  style: TextStyle(fontSize: 14, color: Color(0xFF66667A), height: 1.4),
                ),

                const SizedBox(height: 30),

                /// Upload Card
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: _selectedImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(CupertinoIcons.cloud_upload, size: 60, color: Color(0xFF6C63FF)),
                                  SizedBox(height: 16),
                                  Text(
                                    "Tap to upload signature",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    "PNG, JPG from camera or gallery",
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
                              ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedImage == null
                        ? null
                        : () async {
                            final imageFile = File(_selectedImage!.path);

                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => PredictionResultScreen(image: imageFile)),
                            );

                            setState(() {
                              _selectedImage = null;
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF6C63FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text("Run Prediction", style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom Sheet UI
class _ImageSourceSheet extends StatelessWidget {
  const _ImageSourceSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Select Image Source", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text("Camera"),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text("Gallery"),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    );
  }
}
