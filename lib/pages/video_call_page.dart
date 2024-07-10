import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:chatacter/characters/characters.dart';
import 'package:chatacter/characters/llm.dart';
import 'package:video_player/video_player.dart';
import 'package:chatacter/config/app_animations.dart';

class VideoCallPage extends StatefulWidget {
  const VideoCallPage({Key? key}) : super(key: key);

  @override
  _VideoCallPageState createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  final FlutterTts flutterTts = FlutterTts();
  final SpeechToText _speechToText = SpeechToText();
  bool _isSpeaking = false;
  late LLM _llm;
  List<Map<String, String>> chatHistory = [];
  String receiverId = 'dc57f5a807524d09ba6d';
  Timer? _activityTimer; // Timer to check activity
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _initializeSpeechRecognition();
    _startActivityTimer(); // Start the activity timer

    _controller = VideoPlayerController.asset(AppAnimations.albert_silent)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _controller.setVolume(0);
            _controller.play();
            _controller.pause();
          });
        }
      });
  }

  @override
  void dispose() {
    _activityTimer?.cancel(); // Cancel the timer when the widget is disposed
    _controller.dispose();
    super.dispose();
  }

  void _initializeSpeechRecognition() async {
    bool available = await _speechToText.initialize();
    if (available) {
      _startListening();
    } else {
      // Handle the error of not being able to initialize speech recognition
    }
  }

  void _startActivityTimer() {
    _activityTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      _checkActivity();
    });
  }

  void _checkActivity() {
    if (!_speechToText.isListening && !_isSpeaking) {
      _handleSpokenText("what are your plans for today");
    }
  }

  void _startListening() {
    _controller.pause();
    _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _stopListening() {
    _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (result.finalResult) {
      String spokenText = result.recognizedWords;
      _handleSpokenText(spokenText);
    }
  }

  Future<void> _handleSpokenText(String text) async {
    _stopListening();
    String responseText = await _getLLMResponse(text);
    await _speak(responseText);
  }

  Future<String> _getLLMResponse(String prompt) async {
    chatHistory = [
      {
        "role": "system",
        "content":
            "You are ${AiCharacters.characters[receiverId]}. Respond to the user's questions and comments as ${AiCharacters.characters[receiverId]} would, without explicitly stating that you are ${AiCharacters.characters[receiverId]}. Use short sentences. be polite and don't be rude."
      }
    ];
    _llm = LLM();
    final response = await _llm.sendPostRequest(chatHistory);

    return response;
  }

  Future<void> _speak(String text) async {
    _controller.seekTo(Duration.zero);
    _controller.play();
    await flutterTts.setLanguage('en-US');
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
    setState(() {
      _isSpeaking = true;
    });
    flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _startListening();
        });
      }
    });
  }

  void _cancelSpeaking() async {
    await flutterTts.stop();
    if (mounted) {
      setState(() {
        _isSpeaking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // UserData receiver = ModalRoute.of(context)!.settings.arguments as UserData;
    // receiverId = receiver.id;

    return Scaffold(
      body: Stack(
        children: [
          if (_controller.value.isInitialized)
            Positioned.fill(
              child: VideoPlayer(_controller),
            )
          else
            Container(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Stack(
                clipBehavior: Clip.none, // Allow overflow for the red circle
                children: [
                  Container(
                    width: 56, // Adjust size of red circle as needed
                    height: 56, // Adjust size of red circle as needed
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: IconButton(
                        onPressed: () {
                          _cancelSpeaking();
                          _stopListening();
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.call),
                        color: Colors.white, // Icon color
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
