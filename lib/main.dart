import 'package:flutter/material.dart';
import 'package:lets_talk_english_mobile/space_background.dart';
import 'package:lets_talk_english_mobile/breathing_orb.dart';
import 'package:lets_talk_english_mobile/control_panel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lets talk English',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        // Removed any stray 'const' from the children array
        children: [
          // Z-Index 1: The Cosmic Background
          const SpaceBackground(),
          
          // Z-Index 2: Text Content Overlay
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Column(
                    children: [
                      Text(
                        "Let's Talk English",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              // Updated to .withValues() to clear the deprecation warning
                              color: Colors.white.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "మీ ఇంగ్లీష్ మాట్లాడే సహచరుడు",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blueGrey[200],
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),  

          // Z-Index 3: The Breathing AI Orb (Removed const wrapper)
          Center(
            child: BreathingOrb(),
          ),

          // Z-Index 4: The Glassmorphism Control Panel (Removed const wrapper)
          Align(
            alignment: Alignment.bottomCenter,
            child: ControlPanel(),
          ),
        ],
      ),
    );
  }
}