import 'dart:math';
import 'package:flutter/material.dart';

class SpaceBackground extends StatefulWidget {
  const SpaceBackground({super.key});

  @override
  State<SpaceBackground> createState() => _SpaceBackgroundState();
}

class _SpaceBackgroundState extends State<SpaceBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // A 120-second linear loop creates that ultra-slow, premium cosmic drift
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 120),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _SpacePainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _SpacePainter extends CustomPainter {
  final double animationValue;
  // Using a fixed seed ensures the stars don't randomly jump around on hot reload
  final Random random = Random(42); 

  _SpacePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Deep Space Base (Gradient Void)
    final Rect rect = Offset.zero & size;
    final Paint basePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF0B0C10), // Deep Obsidian
          Color(0xFF1F2833), // Dark Slate Blue
          Color(0xFF240046), // Deep Cosmic Purple
        ],
      ).createShader(rect);
    canvas.drawRect(rect, basePaint);

    // 2. Floating Nebula Clouds (Animated radial gradients)
    final double nebulaMovement = animationValue * 2 * pi;
    
    // Purple Nebula (Top Left)
    _drawNebula(
      canvas, 
      size, 
      const Color(0x407B2CBF), 
      Offset(size.width * 0.2 + cos(nebulaMovement) * 50, size.height * 0.3 + sin(nebulaMovement) * 40)
    );
    
    // Cyan Nebula (Bottom Right)
    _drawNebula(
      canvas, 
      size, 
      const Color(0x3048CAE4), 
      Offset(size.width * 0.8 + sin(nebulaMovement) * 60, size.height * 0.7 + cos(nebulaMovement) * 50)
    );

    // 3. Parallax Starfield
    final Paint starPaint = Paint()..color = Colors.white;
    for (int i = 0; i < 150; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      double radius = random.nextDouble() * 1.5 + 0.5;
      
      // Larger stars move faster to create the illusion of depth (parallax)
      double yOffset = (y + (animationValue * size.height * radius * 0.8)) % size.height;
      
      // Twinkle effect based on the animation value
      double twinkle = sin(animationValue * pi * 2 * (random.nextInt(10) + 1) + random.nextDouble() * pi * 2);
      double opacity = 0.2 + (twinkle + 1) * 0.3; 

      starPaint.color = Colors.white.withValues(alpha:opacity.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(x, yOffset), radius, starPaint);
    }
  }

  void _drawNebula(Canvas canvas, Size size, Color color, Offset center) {
    final double radius = size.width * 0.8;
    final Paint nebulaPaint = Paint()
      ..shader = RadialGradient(
        colors: [color, Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, nebulaPaint);
  }

  @override
  bool shouldRepaint(covariant _SpacePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}