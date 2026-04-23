import 'package:flutter/material.dart';

class PsPrivacyPolice extends StatelessWidget {
  const PsPrivacyPolice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
            ),

            const Text("Privacy & Data Usage", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

            const SizedBox(height: 16),

            const Text(
              "Your privacy is important to us. Here's how your data is handled:",
              style: TextStyle(fontSize: 14, height: 1.5),
            ),

            const SizedBox(height: 16),

            _item(
              icon: Icons.upload_file,
              title: "Image Processing",
              desc: "Your uploaded signature is securely sent to our server for analysis.",
            ),

            _item(
              icon: Icons.memory,
              title: "AI Model",
              desc: "We use a hybrid AI model (CNN - InceptionV3 + RNN - LSTM) trained on publicly available datasets.",
            ),

            _item(
              icon: Icons.auto_graph,
              title: "Analysis",
              desc: "The system evaluates stroke patterns, pressure, and structural consistency to detect forgery.",
            ),

            _item(
              icon: Icons.delete_outline,
              title: "No Data Storage",
              desc: "We do NOT store, save, or share your signature. Processing happens in-memory only.",
            ),

            _item(
              icon: Icons.lock_outline,
              title: "Privacy First",
              desc: "Your data is used only for real-time prediction and is immediately discarded after processing.",
            ),

            const SizedBox(height: 20),

            const Text(
              "By using this feature, you agree to temporary processing of your image solely for prediction purposes.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _item({required IconData icon, required String title, required String desc}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Color(0xFF6C63FF)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
