import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../model/result_enum.dart';
import '../model/verify_results.dart';
import '../view/welcome_page.dart';
import '../view_model/connectivity.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key, required this.image});

  final File image;

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  bool _isProcessDone = false;
  late VerifyResults _results;

  Future<void> _getResults() async {
    _results = await Connectivity(image: widget.image).sendRequest();
    setState(() {
      _isProcessDone = true;
    });
  }

  @override
  void initState() {
    _getResults();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text((_isProcessDone) ? "" : "Results"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: (!_isProcessDone)
              ? Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset("assets/animations/processing-anim.json"),
                    Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: Text(
                        "Waiting for Response",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Please wait, out server processing your image. This might take few seconds.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    )
                  ],
                )
              : (_results.status == 200)
                  ? SizedBox(
                      width: double.maxFinite,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),
                          Lottie.asset(
                            (_results.result == Result.genuine)
                                ? "assets/animations/done-anim.json"
                                : "assets/animations/warn-anim.json",
                            height: 250,
                            fit: BoxFit.fill,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 18.0),
                            child: Text(
                              _results.result.value,
                              style: TextStyle(
                                color: (_results.result == Result.genuine) ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 28.0,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "Confidence: ${_results.confidence.toStringAsFixed(2)}",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          Text(
                            "This result is a prediction based on the provided signature and may not be 100% accurate.",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 10.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const WelcomePage()),
                                );
                              },
                              child: const Text("Go to Home"),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        const Spacer(),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/images/error.png"),
                            const Text(
                              "There was an error processing your request. \nPlease try again",
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const WelcomePage()),
                              );
                            },
                            child: const Text("Go to Home"),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
