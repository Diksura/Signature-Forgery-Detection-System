import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../model/result_enum.dart';
import '../model/verify_result.dart';

class Connectivity {
  Connectivity();


  Future<VerifyResult> sendPredictionRequest(File image) async {

    // Android emulator = 10.0.2.2
    const String apiUrl = "https://signature-forgery-model-966374620579.us-central1.run.app/predict";

    // if (image == null) {
    //   return VerifyResult(status: 400, errorMessage: "No image selected");
    // }

    try {
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      request.files.add(await http.MultipartFile.fromPath('image1', image.path));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      final jsonResponse = json.decode(responseData);

      if (response.statusCode != 200) {
        return VerifyResult(status: response.statusCode, errorMessage: "Server error ${response.statusCode}");
      }

      // Safe parsing
      final String responseResult = (jsonResponse["result"] ?? "none").toString();

      double confidence = (jsonResponse["prediction"] ?? 0.0).toDouble();

      // Normalize confidence (0–1 → 0–100)
      if (confidence <= 1) {
        confidence *= 100;
      }

      confidence = confidence.clamp(0.0, 100.0);

      // Safe enum mapping
      Result result;

      switch (responseResult.toLowerCase()) {
        case "genuine":
          result = Result.genuine;
          break;
        case "forged":
          result = Result.forged;
          break;
        default:
          result = Result.none;
      }

      return VerifyResult(status: 200, confidence: confidence, result: result);
    } catch (e) {
      debugPrint("Error: $e");

      return VerifyResult(status: 500, errorMessage: "Request failed");
    }
  }
}
