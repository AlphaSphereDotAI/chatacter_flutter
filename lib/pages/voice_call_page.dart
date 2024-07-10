import 'dart:async';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatacter/config/app_icons.dart';
import 'package:chatacter/models/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:chatacter/characters/characters.dart';
import 'package:chatacter/characters/llm.dart';

class VoiceCallPage extends StatefulWidget {
  const VoiceCallPage({Key? key}) : super(key: key);

  @override
  _VoiceCallPageState createState() => _VoiceCallPageState();
}

class _VoiceCallPageState extends State<VoiceCallPage> {
  final FlutterTts flutterTts = FlutterTts();
  final SpeechToText _speechToText = SpeechToText();
  bool _isSpeaking = false;
  late LLM _llm;
  List<Map<String, String>> chatHistory = [];
  String receiverId = 'dc57f5a807524d09ba6d';
  Timer? _activityTimer; // Timer to check activity
  Map? _CurrentVoice;

  @override
  void initState() {
    super.initState();
    _initializeSpeechRecognition();
    _startActivityTimer(); // Start the activity timer
  }

  @override
  void dispose() {
    _activityTimer?.cancel(); // Cancel the timer when the widget is disposed
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
      _handleSpokenText("what are your plans fpr today");
    }
  }

  void _startListening() {
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
            "You are ${AiCharacters.characters[receiverId]}. Respond to the user's questions and comments as ${AiCharacters.characters[receiverId]} would, without explicitly stating that you are ${AiCharacters.characters[receiverId]}. Use short sentences, be polite."
      }
    ];
    _llm = LLM();
    final response = await _llm.sendPostRequest(chatHistory);

    return response;
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setPitch(0.6);
    await flutterTts.speak(text);

    flutterTts.getVoices.then((data) {
      try {
        List<Map> _voices = List<Map>.from(data);
        _voices =
            _voices.where((_voice) => _voice['name'].contains('en')).toList();
        // print(_voices);
        setState(() {
          _CurrentVoice = _voices[10]; //7,
          print('_CurrentVoice: ${_CurrentVoice}');
          flutterTts.setVoice({
            'name': _CurrentVoice!['name'],
            'locale': _CurrentVoice!['locale']
          });
        });
      } catch (e) {}
    });

    setState(() {
      _isSpeaking = true;
    });
    flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
        _startListening();
      });
    });
  }

  void _cancelSpeaking() async {
    await flutterTts.stop();
    setState(() {
      _isSpeaking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    UserData receiver = ModalRoute.of(context)!.settings.arguments as UserData;
    receiverId = receiver.id;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AvatarGlow(
                animate: _isSpeaking,
                glowColor: Theme.of(context).primaryColor,
                duration: const Duration(milliseconds: 2000),
                repeat: true,
                child: Material(
                  elevation: 8.0,
                  shape: const CircleBorder(),
                  child: CircleAvatar(
                    backgroundColor: Colors.amber,
                    radius: 80.0,
                    backgroundImage: receiver.profilePicture == null ||
                            receiver.profilePicture == null
                        ? Image.asset(AppIcons.userIcon).image
                        : CachedNetworkImageProvider(
                            'https://cloud.appwrite.io/v1/storage/buckets/6683247c00056fdd9ceb/files/${receiver.profilePicture}/view?project=667d37b30023f69f7f74&mode=admin'),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(receiver.name!),
              const SizedBox(height: 20),
              Stack(
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
