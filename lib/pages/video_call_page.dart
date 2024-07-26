import 'dart:async';
import 'package:chatacter/models/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
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
  SpeechToText? _speechToText;
  bool _isSpeaking = false;
  bool _isListening = false;
  late LLM _llm;
  List<Map<String, String>> chatHistory = [];
  UserData? receiver;
  Timer? _activityTimer; // Timer to check activity
  VideoPlayerController? _silentController;
  VideoPlayerController? _talkingController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeSpeechRecognition();
    _startActivityTimer(); // Start the activity timer
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize chat history with system message
    receiver = ModalRoute.of(context)!.settings.arguments as UserData;
    chatHistory = [
      {
        "role": "assistant",
        "content":
            "You are ${receiver!.name} ${receiver!.lastName}. Respond to the user's questions and comments as ${receiver!.name} ${receiver!.lastName} would, without explicitly stating that you are ${receiver!.name} ${receiver!.lastName}. Use very very short sentences. Be polite and don't be rude."
      }
    ];
  }

  @override
  void dispose() {
    _stopControllers(); // Ensure controllers are stopped
    _disposeControllers(); // Dispose controllers
    _speechToText?.stop(); // Stop speech recognition
    _activityTimer?.cancel(); // Cancel the activity timer
    flutterTts.stop(); // Stop text-to-speech
    super.dispose();
  }

  void _initializeControllers() {
    _disposeControllers(); // Ensure old controllers are disposed

    _silentController = VideoPlayerController.asset(AppAnimations.albertSilent)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _silentController?.setVolume(0);
            _silentController?.play();
          });
        }
      });

    _talkingController =
        VideoPlayerController.asset(AppAnimations.albertTalking)
          ..initialize().then((_) {
            if (mounted) {
              setState(() {
                _talkingController?.setVolume(1); // Ensure volume is audible
              });
            }
          });
  }

  void _disposeControllers() {
    _silentController?.dispose();
    _talkingController?.dispose();
    _silentController = null;
    _talkingController = null;
  }

  void _initializeSpeechRecognition() async {
    _speechToText = SpeechToText(); // Initialize SpeechToText
    bool available = await _speechToText!.initialize();
    if (available) {
      _startListening();
    } else {
      // Handle the error of not being able to initialize speech recognition
    }
  }

  void _startActivityTimer() {
    _activityTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (mounted) {
        _checkActivity();
      }
    });
  }

  void _checkActivity() {
    if (!(_speechToText?.isListening ?? false) && !_isSpeaking) {
      _handleSpokenText("*I speak with low voice and you can't hear me*");
    }
  }

  Future<void> _startListening() async {
    if (_isSpeaking) {
      return; // Prevent starting listening if currently speaking
    }

    _initializeControllers(); // Reinitialize controllers if needed
    await _speechToText?.listen(
      onResult: _onSpeechResult,
      pauseFor: Duration(seconds: 5),
    );
    if (mounted) {
      setState(() {
        _isListening = true;
      });
    }
  }

  Future<void> _stopListening() async {
    await _speechToText?.stop();
    if (mounted) {
      setState(() {
        _isListening = false;
      });
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (result.finalResult) {
      String spokenText = result.recognizedWords;
      _handleSpokenText(spokenText);
    }
  }

  Future<void> _handleSpokenText(String text) async {
    await _stopListening();
    chatHistory.add({
      "role": "user",
      "content": text,
    });
    String responseText = await _getLLMResponse();
    chatHistory.add({
      "role": "assistant",
      "content": responseText,
    });
    await _speak(responseText);
  }

  Future<String> _getLLMResponse() async {
    _llm = LLM();
    final response = await _llm.sendPostRequest(chatHistory);
    return response;
  }

  Future<void> _speak(String text) async {
    _stopControllers(); // Stop both controllers before speaking
    _initializeControllers(); // Ensure talking video controller is initialized
    _talkingController?.seekTo(Duration.zero);
    _talkingController?.play();
    await flutterTts.setLanguage('en-US');
    await flutterTts.setPitch(1.0);
    if (mounted) {
      setState(() {
        _isSpeaking = true;
      });
    }
    await flutterTts.speak(text);
    flutterTts.setCompletionHandler(() async {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
        await Future.delayed(
            Duration(milliseconds: 500)); // Delay before listening
        _startListening();
      }
    });
  }

  void _stopControllers() {
    _silentController?.pause();
    _talkingController?.pause();
  }

  void _stopTextToSpeech() {
    flutterTts.stop();
    if (mounted) {
      setState(() {
        _isSpeaking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppAnimations
                      .albertImage), // Replace with your background image path
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          // Video playback
          Positioned.fill(
            child: _isSpeaking
                ? (_talkingController != null &&
                        _talkingController!.value.isInitialized &&
                        _talkingController!.value.isPlaying
                    ? VideoPlayer(_talkingController!)
                    : Container()) // Empty container if not initialized
                : (_silentController != null &&
                        _silentController!.value.isInitialized &&
                        _silentController!.value.isPlaying
                    ? VideoPlayer(_silentController!)
                    : Container()), // Empty container if not initialized
          ),
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
                          _stopListening();
                          _stopControllers(); // Ensure controllers are stopped
                          _stopTextToSpeech(); // Stop text-to-speech
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
