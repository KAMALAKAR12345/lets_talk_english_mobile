import 'dart:ui';
import 'package:flutter/material.dart';
import 'conversation_screen.dart';

class ControlPanel extends StatefulWidget {
  const ControlPanel({super.key});

  @override
  State<ControlPanel> createState() => ControlPanelState();
}

class ControlPanelState extends State<ControlPanel> {
  String _selectedVoice = "en-IN-NeerjaNeural";
  String _selectedScenario = "Casual Conversation";

  final List<String> _scenarios = [
    "Casual Conversation",
    "Job Interview",
    "Coffee Shop Ordering",
    "Airport Customs",
    "Asking for Directions"
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
        child: Container(
          // DYNAMIC PADDING FIX: Pushes UI above the phone's bottom menu bar!
          padding: EdgeInsets.only(
            top: 24.0,
            left: 24.0,
            right: 24.0,
            bottom: MediaQuery.of(context).padding.bottom + 24.0,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.record_voice_over, color: Color(0xFF48CAE4)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedVoice,
                          dropdownColor: const Color(0xFF2D1B4E),
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedVoice = newValue!;
                            });
                          },
                          items: const [
                            DropdownMenuItem(value: "en-IN-NeerjaNeural", child: Text("Neerja (Indian Female)")),
                            DropdownMenuItem(value: "en-IN-PrabhatNeural", child: Text("Prabhat (Indian Male)")),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.movie_filter, color: Color(0xFF48CAE4)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedScenario,
                          dropdownColor: const Color(0xFF2D1B4E),
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          isExpanded: true,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedScenario = newValue!;
                            });
                          },
                          items: _scenarios.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(value: value, child: Text(value));
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF7B2CBF), Color(0xFF48CAE4)]),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7B2CBF).withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            ConversationScreen(voice: _selectedVoice, scenario: _selectedScenario),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text(
                    'సంభాషణ ప్రారంభించండి',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}