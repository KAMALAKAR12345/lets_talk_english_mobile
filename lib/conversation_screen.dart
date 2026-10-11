import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'space_background.dart';
import 'breathing_orb.dart';

class ChatMessage {
  final String text;
  final String subtext;
  final bool isAi;

  ChatMessage({required this.text, required this.subtext, required this.isAi});
}

class ConversationScreen extends StatefulWidget {
  final String voice;
  final String scenario;

  const ConversationScreen({super.key, required this.voice, required this.scenario});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  late AudioPlayer _audioPlayer;
  
  bool _isListening = false;
  bool _isLoading = false;
  bool _isChatOpen = false;
  bool _isSpeaking = false; 

  final String _backendUrl = 'https://language-tutor-backend-hcyo.onrender.com/api/mobile/chat';
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _audioPlayer = AudioPlayer();

    _setupTts();
    _setupAudioPlayer();
    _initiateScenarioGreeting();
  }

  Future<void> _setupTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
      // BUGFIX: Removed chat box restriction so it always auto-listens
      if (mounted && !_isListening) _listen();
    });
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isSpeaking = false);
      // BUGFIX: Removed chat box restriction so it always auto-listens
      if (mounted && !_isListening) _listen();
    });
  }

  Future<void> _initiateScenarioGreeting() async {
    await _sendToBackend("INITIATE_SCENARIO_GREETING", isHidden: true, playAudio: true);
  }

  void _listen() async {
    await _audioPlayer.stop();
    await _flutterTts.stop();
    if (mounted) setState(() => _isSpeaking = false);

    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            if (mounted) setState(() => _isListening = false);
          }
        },
        onError: (val) {
          if (mounted) setState(() => _isListening = false);
        },
      );
      if (available) {
        if (mounted) setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            if (mounted) {
              setState(() {
                _textController.text = val.recognizedWords;
              });
            }
            if (val.finalResult && val.recognizedWords.trim().isNotEmpty) {
              if (mounted) setState(() => _isListening = false);
              _speech.stop();
              // BUGFIX: Tell backend to play audio since we used the mic
              _sendMessage(playAudioResponse: true); 
            }
          },
          listenOptions: stt.SpeechListenOptions(
            pauseFor: const Duration(seconds: 2),
            listenFor: const Duration(seconds: 30),
            partialResults: true,
          ),
        );
      }
    } else {
      if (mounted) setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // BUGFIX: Made playAudioResponse dynamic so text typing can be silent, but voice is spoken
  Future<void> _sendMessage({bool playAudioResponse = false}) async {
    final userText = _textController.text.trim();
    if (userText.isEmpty || _isLoading) return;

    if (_isListening) {
      _speech.stop();
      if (mounted) setState(() => _isListening = false);
    }

    setState(() {
      _messages.add(ChatMessage(text: userText, subtext: "", isAi: false));
    });

    _textController.clear();
    _scrollToBottom();
    
    await _sendToBackend(userText, isHidden: false, playAudio: playAudioResponse);
  }

  Future<void> _sendToBackend(String text, {required bool isHidden, bool playAudio = true}) async {
    if (mounted) setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_message': text, 'scenario': widget.scenario, 'voice': widget.voice}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String englishReply = data['english_reply'] ?? "I couldn't generate a reply.";
        final String teluguTranslation = data['telugu_translation'] ?? "";
        final String? base64Audio = data['audio_base64'];

        if (mounted) {
          setState(() {
            _messages.add(ChatMessage(text: englishReply, subtext: teluguTranslation, isAi: true));
          });
        }

        if (playAudio) {
          if (mounted) setState(() => _isSpeaking = true);
          if (base64Audio != null && base64Audio.isNotEmpty) {
            final audioBytes = base64Decode(base64Audio);
            await _audioPlayer.play(BytesSource(audioBytes));
          } else {
            await _flutterTts.speak(englishReply);
          }
        }
      } else {
        _addErrorMsg("Server error (${response.statusCode}).");
      }
    } catch (e) {
      _addErrorMsg("Connection failed. Check your internet.");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _scrollToBottom();
      }
    }
  }

  void _addErrorMsg(String errorText) {
    if (mounted) {
      setState(() {
        _messages.add(ChatMessage(text: errorText, subtext: "లోపం ఏర్పడింది. మళ్ళీ ప్రయత్నించండి.", isAi: true));
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _audioPlayer.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const SpaceBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildTopNav(),
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: _listen,
                      child: BreathingOrb(isSpeaking: _isSpeaking), 
                    ),
                  ),
                ),
                if (_isLoading)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text("AI is thinking...", style: TextStyle(color: Colors.blueGrey[200], fontSize: 16)),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40, left: 30, right: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FloatingActionButton(
                        heroTag: "end_session",
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        elevation: 0,
                        onPressed: () => Navigator.pop(context),
                        child: const Icon(Icons.close_rounded, color: Colors.white),
                      ),
                      FloatingActionButton(
                        heroTag: "mic_active",
                        backgroundColor: _isListening ? Colors.redAccent : const Color(0xFF7B2CBF),
                        elevation: _isListening ? 0 : 15,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        onPressed: _listen,
                        child: Icon(_isListening ? Icons.mic : Icons.mic_none, color: Colors.white, size: 32),
                      ),
                      FloatingActionButton(
                        heroTag: "open_chat",
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        elevation: 0,
                        onPressed: () {
                          setState(() {
                            _isChatOpen = !_isChatOpen;
                          });
                        },
                        child: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            bottom: _isChatOpen ? 0 : -(screenHeight * 0.85),
            left: 0,
            right: 0,
            height: screenHeight * 0.85,
            child: _buildChatOverlay(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNav() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(widget.scenario, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          const Icon(Icons.fiber_manual_record, color: Colors.greenAccent, size: 14),
          const SizedBox(width: 4),
          const Text("Live", style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildChatOverlay() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.85),
            border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1.5)),
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => setState(() => _isChatOpen = false),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: 10, bottom: 20),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return _buildGlassBubble(msg.text, msg.subtext, isAi: msg.isAi);
                  },
                ),
              ),
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 16,
        right: 16,
        top: 12
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: TextField(
                controller: _textController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Type to correct errors...",
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                  border: InputBorder.none,
                ),
                // BUGFIX: Force text input to reply silently
                onSubmitted: (_) => _sendMessage(playAudioResponse: false), 
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            // BUGFIX: Force text input to reply silently
            onTap: () => _sendMessage(playAudioResponse: false),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF7B2CBF), Color(0xFF48CAE4)]), shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassBubble(String text, String subtext, {required bool isAi}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isAi ? Colors.white.withValues(alpha: 0.08) : const Color(0xFF7B2CBF).withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                if (subtext.isNotEmpty) ...[
                  const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: Colors.white24, height: 1)),
                  Text(subtext, style: TextStyle(color: Colors.blueGrey[200], fontSize: 13)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}