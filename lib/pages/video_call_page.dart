import 'dart:async';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:chatacter/config/app_animations.dart';
import 'package:chatacter/models/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:chatacter/characters/llm.dart';
import 'package:video_player/video_player.dart';

class VideoCallPage extends StatefulWidget {
  const VideoCallPage({Key? key}) : super(key: key);

  @override
  _VideoCallPageState createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  final FlutterTts flutterTts = FlutterTts();
  final SpeechToText _speechToText = SpeechToText();
  bool _isSpeaking = false;
  LLM? _llm;
  List<Map<String, String>> chatHistory = [];
  late String receiverId;
  Timer? _activityTimer;
  Map? _CurrentVoice;
  VideoPlayerController? _listeningController;
  VideoPlayerController? _speakingController;

  @override
  void initState() {
    super.initState();
    _initializeSpeechRecognition();
    _startActivityTimer();
    _initializeVideoControllers();
  }

  void _initializeVideoControllers() {
    _listeningController =
        VideoPlayerController.asset(AppAnimations.albertSilent)
          ..initialize().then((_) {
            setState(() {});
            _listeningController?.play(); // Start playing the listening video
          });
    _speakingController =
        VideoPlayerController.asset(AppAnimations.albertTalking)
          ..initialize().then((_) {
            setState(() {});
          });
  }

  @override
  void dispose() {
    _stopListening();
    _cancelSpeaking();
    _activityTimer?.cancel();
    _listeningController?.dispose();
    _speakingController?.dispose();
    super.dispose();
  }

  void _initializeSpeechRecognition() async {
    bool available = await _speechToText.initialize();
    if (available) {
      _startListening();
    } else {
      // Handle error
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
    if (!_speechToText.isListening && !_isSpeaking) {
      _handleSpokenText("*I speak with low voice and you can't hear me*");
    }
  }

  void _startListening() {
    _speechToText.listen(
        onResult: _onSpeechResult, listenFor: Duration(seconds: 5));
    if (mounted) {
      setState(() {
        _listeningController?.play();
        _speakingController?.pause();
      });
    }
  }

  void _stopListening() {
    if (_speechToText.isListening) {
      _speechToText.stop();
      if (mounted) {
        setState(() {
          _listeningController?.pause();
        });
      }
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (result.finalResult) {
      String spokenText = result.recognizedWords;
      _handleSpokenText(spokenText);
    }
  }

  Future<void> _handleSpokenText(String text) async {
    if (!mounted) return;
    _stopListening();
    String responseText = await _getLLMResponse(text);
    chatHistory.add({"role": "assistant", "content": responseText});
    await _speak(responseText);
  }

  Future<String> _getLLMResponse(String prompt) async {
    UserData receiver = ModalRoute.of(context)!.settings.arguments as UserData;
    if (_llm == null) {
      _llm = LLM();
      chatHistory.add({
        "role": "assistant",
        "content":
            "You are ${receiver.name} ${receiver.lastName} and you are in a video chat..."
      });
    }
    chatHistory.add({
      "role": "user",
      "content": prompt,
    });

    final response = await _llm!.sendPostRequest(chatHistory);
    return response;
  }

  Future<void> _speak(String text) async {
    if (!mounted) return;
    await flutterTts.setLanguage('en-US');
    await flutterTts.setPitch(0.1);
    await flutterTts.speak(text);

    flutterTts.getVoices.then((data) {
      try {
        List<Map> _voices = List<Map>.from(data);
        _voices =
            _voices.where((_voice) => _voice['name'].contains('en')).toList();
        if (mounted) {
          setState(() {
            _CurrentVoice = _voices[5]; //10
            print(_CurrentVoice);
            flutterTts.setVoice({
              'name': _CurrentVoice!['name'],
              'locale': _CurrentVoice!['locale']
            });
          });
        }
      } catch (e) {}
    });

    if (mounted) {
      setState(() {
        _isSpeaking = true;
        _speakingController?.play();
        _listeningController?.pause();
      });
    }

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
    if (_isSpeaking) {
      await flutterTts.stop();
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _speakingController?.pause();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    UserData receiver = ModalRoute.of(context)!.settings.arguments as UserData;
    receiverId = receiver.id;

    return Scaffold(
      body: Stack(
        children: [
          // Video player container that fills the screen
          Positioned.fill(
            child: _isSpeaking
                ? _speakingController != null &&
                        _speakingController!.value.isInitialized
                    ? VideoPlayer(_speakingController!)
                    : Container(color: Colors.black)
                : _listeningController != null &&
                        _listeningController!.value.isInitialized
                    ? VideoPlayer(_listeningController!)
                    : Container(color: Colors.black),
          ),
          // End call button at the bottom center
          Positioned(
            bottom: 50, // Adjust the distance from the bottom
            left: 0,
            right: 0,
            child: Center(
              child: AvatarGlow(
                animate: _isSpeaking,
                glowColor: Theme.of(context).primaryColor,
                duration: const Duration(milliseconds: 2000),
                repeat: true,
                child: Material(
                  elevation: 8.0,
                  shape: const CircleBorder(),
                  child: CircleAvatar(
                    backgroundColor: Colors.red,
                    radius: 40.0, // Adjust the radius for button size
                    child: IconButton(
                      onPressed: () {
                        if (mounted) {
                          _cancelSpeaking();
                          _stopListening();
                          Navigator.pop(context);
                        }
                      },
                      icon: Icon(Icons.call_end),
                      color: Colors.white,
                      iconSize: 40.0, // Adjust icon size as needed
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
