import 'package:flutter/material.dart';

class BreathingOrb extends StatefulWidget {
  final bool isSpeaking; 

  const BreathingOrb({
    super.key,
    this.isSpeaking = false,
  });

  @override
  State<BreathingOrb> createState() => _BreathingOrbState();
}

class _BreathingOrbState extends State<BreathingOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), 
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 10.0, end: 40.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(BreathingOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isSpeaking != oldWidget.isSpeaking) {
      if (widget.isSpeaking) {
        // Fast flicker speed, but tightly restricted to a ~3mm glow range
        _controller.duration = const Duration(milliseconds: 150); 
        _glowAnimation = Tween<double>(begin: 4.0, end: 12.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        _controller.repeat(reverse: true);
      } else {
        // Return to the normal, wider calm glow when silent
        _controller.duration = const Duration(seconds: 2);
        _glowAnimation = Tween<double>(begin: 10.0, end: 40.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        _controller.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF7B2CBF), Color(0xFF48CAE4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF48CAE4).withValues(alpha: widget.isSpeaking ? 0.8 : 0.5),
                blurRadius: _glowAnimation.value,
                spreadRadius: _glowAnimation.value / 2, // Keeps spread extremely tight during speech
              ),
              BoxShadow(
                color: const Color(0xFF7B2CBF).withValues(alpha: widget.isSpeaking ? 0.8 : 0.5),
                blurRadius: _glowAnimation.value * 1.2,
                spreadRadius: _glowAnimation.value / 3, // Restricts outer bounds of the shadow
              ),
            ],
          ),
          child: const Icon(
            Icons.graphic_eq_rounded,
            color: Colors.white,
            size: 60,
          ),
        );
      },
    );
  }
}