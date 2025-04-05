import 'dart:math';

import 'package:flutter/material.dart';
import 'package:signature_forgery/view/signature_verification.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  List<String> options = ["security", "surveillance"];
  String imageName = "security";

  @override
  void initState() {
    super.initState();

    setState(() {
      imageName = options[Random().nextInt(options.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const Text(
                  "Welcome",
                  style: TextStyle(fontSize: 36.0),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 60.0),
                  child: Text(
                    "Signature Forgery Detection System",
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
                Image.asset("assets/images/$imageName.png"),
                Padding(
                  padding: const EdgeInsets.only(top: 120.0, bottom: 18.0),
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const SignatureVerification()),
                      );
                    },
                    child: const Text("Get Start"),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
