import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:signature_forgery/model/result_enum.dart';
import 'package:signature_forgery/model/verify_results.dart';

class Connectivity {
  Connectivity({required this.image});

  File? image;

  Future<VerifyResults> sendRequest() async {
    // Local Testing
    // const String apiUrl = "http://127.0.0.1:5000/predict";

    // Google Cloud Host
    const String apiUrl = "https://signature-forgery-model-966374620579.us-central1.run.app/predict";

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(await http.MultipartFile.fromPath('image1', image!.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      if (response.statusCode == 200) {
        String responseResult = jsonResponse["result"] ?? "ERROR! No Results";
        double confidence = jsonResponse["prediction"] ?? 0.0;
        Result result = Result.none;

        if (responseResult == "Genuine") {
          result = Result.genuine;
          if (confidence < 1 && confidence > 0) {
            confidence = (1 - confidence) * 100;
          } else {
            confidence = 100;
          }
        } else {
          result = Result.forged;
          if (confidence < 1 && confidence > 0) {
            confidence = confidence * 100;
          } else {
            confidence = 100;
          }
        }

        return VerifyResults(status: 200, confidence: confidence, result: result);

      } else {
        return VerifyResults(status: 500, errorMessage: "Error - Response Code ${response.statusCode}");
      }

    } catch (e) {
      print("Error ${e.toString()}");
      return VerifyResults(status: 404, errorMessage: "Error Making Verifying Requests");
    }


  }

}
