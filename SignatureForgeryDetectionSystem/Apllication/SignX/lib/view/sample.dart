import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:signx/model/result_enum.dart';

import '../model/verify_result.dart';

class PredictionResultScreen extends StatefulWidget {
  final File image;

  const PredictionResultScreen({super.key, required this.image});

  @override
  State<PredictionResultScreen> createState() => _PredictionResultScreenState();
}

class _PredictionResultScreenState extends State<PredictionResultScreen>
    with SingleTickerProviderStateMixin {
  VerifyResult? _result;
  bool _isLoading = true;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _runPrediction();
  }

  Future<void> _runPrediction() async {
    await Future.delayed(const Duration(seconds: 2));

    final mock = VerifyResult(
      status: 200,
      confidence: 0.82,
      result: Result.genuine,
    );

    setState(() {
      _result = mock;
      _isLoading = false;
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analysis Result')),
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
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

  /// ================= LOADING =================
  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text("Running AI analysis..."),
        ],
      ),
    );
  }

  /// ================= RESULT =================
  Widget _buildResult() {
    final result = _result!;
    final isGenuine = result.result == Result.genuine;

    final mainColor = isGenuine ? Colors.green : Colors.red;

    return FadeTransition(
      opacity: _controller,
      child: ListView(
        children: [
          /// Image Preview
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.file(widget.image, height: 180, fit: BoxFit.cover),
          ),

          const SizedBox(height: 20),

          /// Result Badge
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: mainColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                result.result.value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: mainColor,
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          /// ================= CONFIDENCE SECTION =================
          _card(
            child: Column(
              children: [
                const Text(
                  "Confidence Score",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                /// Circular Chart
                SizedBox(
                  height: 140,
                  width: 140,
                  child: CustomPaint(
                    painter: _CirclePainter(result.confidence, mainColor),
                    child: Center(
                      child: Text(
                        "${(result.confidence * 100).toStringAsFixed(0)}%",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// Linear Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: result.confidence,
                    minHeight: 10,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// ================= INSIGHTS =================
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "AI Insights",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                _insightItem("Stroke consistency", result.confidence > 0.7),
                _insightItem("Pressure variation", result.confidence > 0.6),
                _insightItem("Ink distribution", result.confidence > 0.65),
                _insightItem("Shape uniformity", result.confidence > 0.75),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// ================= ACTIONS =================
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Try Again"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text("Done"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ================= UI HELPERS =================

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: child,
    );
  }

  Widget _insightItem(String text, bool positive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            positive ? Icons.check_circle : Icons.cancel,
            color: positive ? Colors.green : Colors.red,
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }
}

/// ================= CUSTOM CIRCLE CHART =================
class _CirclePainter extends CustomPainter {
  final double value;
  final Color color;

  _CirclePainter(this.value, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 10.0;

    final bgPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final rect = Offset.zero & size;

    canvas.drawArc(rect, 0, 2 * pi, false, bgPaint);
    canvas.drawArc(rect, -pi / 2, 2 * pi * value, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}