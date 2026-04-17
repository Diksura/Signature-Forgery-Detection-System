import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:signx/model/result_enum.dart';
import 'package:signx/view_model/connectivity.dart';

import '../model/verify_result.dart';
import 'home_screen.dart';

class PredictionResultScreen extends StatefulWidget {
  final File image;

   const PredictionResultScreen({super.key, required this.image});

  @override
  State<PredictionResultScreen> createState() => _PredictionResultScreenState();
}

class _PredictionResultScreenState extends State<PredictionResultScreen> {
  VerifyResult? _result;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _runPrediction();
  }

  Future<void> _runPrediction() async {
    try {
      var getResults = await Connectivity().sendPredictionRequest(widget.image);

      setState(() {
        _result = getResults;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _result = VerifyResult(
          status: 500,
          errorMessage: "Something went wrong",
          result: Result.none,
        );
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:  Text("Analysis Result")),
      body: Container(
        width: double.infinity,
        padding:  EdgeInsets.all(24),
        decoration:  BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F9FF), Color(0xFFEDE7FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading ? _buildLoading() : _buildResult(),
      ),
    );
  }

  /// Loading UI
  Widget _buildLoading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children:  [
        CircularProgressIndicator(),
        SizedBox(height: 20),
        Text(
          "Analyzing signature...",
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  /// Result UI
  Widget _buildResult() {
    final result = _result!;

    if (result.status != 200) {
      return Center(
        child: Text(
          result.errorMessage,
          style:  TextStyle(color: Colors.red),
        ),
      );
    }

    final isGenuine = result.result == Result.genuine;

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: .min,
        children: [
           SizedBox(height: 20),

          /// Image Preview
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.file(widget.image, height: 180, fit: BoxFit.cover),
          ),

           SizedBox(height: 30),

          /// Result Badge
          Container(
            padding:  EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: isGenuine ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              result.result.value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isGenuine ? Colors.green : Colors.red,
              ),
            ),
          ),

           SizedBox(height: 20),

          /// Confidence
          Column(
            mainAxisAlignment: .center,
            children: [
              Padding(
                padding:  EdgeInsets.all(8.0),
                child: ShaderMask(
                  shaderCallback: (bounds) =>  LinearGradient(
                    colors: [Colors.deepPurpleAccent, Colors.blue],
                  ).createShader(bounds),
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      children: [
                        TextSpan(text: "${result.confidence.round()}"), // main number
                        TextSpan(
                          text: " %",
                          style: TextStyle(
                            fontSize: 32, // smaller %
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

               Text(
                "Confidence ",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),

           SizedBox(height: 30),

          /// Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 10,
              width: double.infinity,
              color: Colors.grey.shade300,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: result.confidence,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: result.result == Result.forged
                          ? [Colors.red, Colors.orange]
                          : [Colors.lightGreenAccent, Colors.green],
                    ),
                  ),
                ),
              ),
            ),
          ),

           SizedBox(height: 40),

          /// Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child:  Text("Try Another"),
                ),
              ),
               SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                          (route) => false, // 🔥 removes ALL previous routes
                    );
                  },                child:  Text("Done"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}