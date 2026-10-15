import 'dart:math';
import 'package:flutter/material.dart';

class SparkleBackground extends StatefulWidget {
  const SparkleBackground({super.key});

  @override
  State<SparkleBackground> createState() => _SparkleBackgroundState();
}

class _SparkleBackgroundState extends State<SparkleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late List<Particle> particles;

  final int particleCount = 25;
  final Random random = Random();

  @override
  void initState() {
    super.initState();

    particles = List.generate(particleCount, (_) => Particle(random));

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) {
        return CustomPaint(
          painter: SparklePainter(
            particles,
            controller.value,
            Theme.of(context).brightness,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class Particle {
  late double x;
  late double baseY;
  late double speed;
  late double size;
  late double opacity;

  Particle(Random random) {
    x = random.nextDouble();
    baseY = random.nextDouble();
    speed = 0.2 + random.nextDouble() * 0.4;
    size = 1 + random.nextDouble() * 2;
    opacity = 0.3 + random.nextDouble() * 0.5;
  }

  double getY(double progress) {
    double y = baseY - (progress * speed);

    // loop back to bottom smoothly
    if (y < 0) y += 1;

    return y;
  }
}

class SparklePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  final Brightness brightness;

  SparklePainter(this.particles, this.progress, this.brightness);

  @override
  void paint(Canvas canvas, Size size) {
    final isDark = brightness == Brightness.dark;

    for (final p in particles) {
      // slight horizontal floating (premium feel)
      final dx =
          (p.x + sin(progress * 6 + p.x * 10) * 0.01) * size.width;

      final dy = p.getY(progress) * size.height;

      final baseColor = isDark
          ? Colors.white
          : const Color(0xFF6C63FF);

      // 🌟 Outer glow (big blur)
      final glowPaint = Paint()
        ..color = baseColor.withValues(alpha: p.opacity * 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawCircle(
        Offset(dx, dy),
        p.size * 3.5,
        glowPaint,
      );

      // ✨ Inner glow
      final innerGlow = Paint()
        ..color = baseColor.withValues(alpha: p.opacity * 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawCircle(
        Offset(dx, dy),
        p.size * 2,
        innerGlow,
      );

      // 🔵 Core particle
      final corePaint = Paint()
        ..color = baseColor.withValues(alpha: p.opacity);

      canvas.drawCircle(
        Offset(dx, dy),
        p.size,
        corePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SparklePainter oldDelegate) => true;
}