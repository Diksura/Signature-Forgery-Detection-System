import 'package:flutter/material.dart';
import 'package:signx/view/prediction_screen.dart';
import 'package:signx/view/widgets/verify_type_selector.dart';

import '../constants/background_gradient.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: kBGLinearGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Header
                const Text(
                  'SignX',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                    color: Color(0xFF1F1F2E),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'AI Signature Forgery Detection System',
                  style: TextStyle(fontSize: 16, color: Color(0xFF66667A), height: 1.4),
                ),

                Spacer(),
                // Feature cards
                VerifyTypeSelector(
                  name: 'Signature Validation',
                  description: 'Check if a signature is genuine by comparing.',
                  color: const Color(0xFF6C63FF),
                  iconData: Icons.verified_user_outlined,
                  onTap: () {},
                  isEnabled: false,
                ),

                const SizedBox(height: 18),

                VerifyTypeSelector(
                  name: 'Forgery Prediction',
                  description: 'Predict whether the signature is forged.',
                  color: const Color(0xFF8B5CF6),
                  iconData: Icons.fact_check_outlined,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PredictionScreen()));
                  },
                  isEnabled: true,
                ),

                Spacer(),

                // Small info card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.security_outlined, color: Color(0xFF6C63FF)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Fast, clean, and secure verification workflow.',
                          style: TextStyle(fontSize: 14, color: Color(0xFF44445A)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                const Center(
                  child: Text(
                    '© 2026 SignX. All rights reserved.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF7A7A8C)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
