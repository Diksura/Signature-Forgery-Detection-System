import 'package:flutter/material.dart';
import 'package:signx/view/prediction_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F9FF),
              Color(0xFFF1F3FF),
              Color(0xFFEDE7FF),
            ],
          ),
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
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF66667A),
                    height: 1.4,
                  ),
                ),


                Spacer(),
                // Feature cards
                VerifyTypeSelector(
                  name: 'Signature Validation',
                  description: 'Check if a signature is genuine.',
                  color: const Color(0xFF6C63FF),
                  iconData: Icons.verified_user_outlined,
                  onTap: () {},
                  isEnabled: true,
                ),

                const SizedBox(height: 18),

                VerifyTypeSelector(
                  name: 'Forgery Prediction',
                  description: 'Predict whether the signature is forged.',
                  color: const Color(0xFF8B5CF6),
                  iconData: Icons.fact_check_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PredictionScreen(),
                      ),
                    );
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
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF44445A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                const Center(
                  child: Text(
                    '© 2026 SignX. All rights reserved.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7A7A8C),
                    ),
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

class VerifyTypeSelector extends StatelessWidget {
  const VerifyTypeSelector({
    super.key,
    required this.name,
    required this.description,
    required this.iconData,
    required this.color,
    required this.onTap,
    required this.isEnabled,
  });

  final String name;
  final String description;
  final IconData iconData;
  final Color color;
  final GestureTapCallback onTap;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: isEnabled ? onTap : null,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color,
                color.withValues(alpha: 0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                color: color.withValues(alpha: 0.25),
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(iconData, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white70,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}