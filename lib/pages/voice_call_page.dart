import 'dart:async';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatacter/characters/characters.dart';
import 'package:chatacter/config/app_icons.dart';
import 'package:chatacter/models/user_data.dart';
import 'package:chatacter/styles/app_colors.dart';
import 'package:chatacter/styles/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:chatacter/characters/llm.dart';

class VoiceCallPage extends StatefulWidget {
  const VoiceCallPage({Key? key}) : super(key: key);

  @override
  _VoiceCallPageState createState() => _VoiceCallPageState();
}

class _VoiceCallPageState extends State<VoiceCallPage> {
  AiCharacters? aiCharacter;
  final FlutterTts flutterTts = FlutterTts();
  final SpeechToText _speechToText = SpeechToText();
  bool _isSpeaking = false;
  LLM? _llm;
  List<Map<String, String>> chatHistory = [];
  late UserData receiver;
  Timer? _activityTimer; // Timer to check activity
  Map? _CurrentVoice;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    receiver = ModalRoute.of(context)!.settings.arguments as UserData;

    // Check if the receiver is an AiCharacter
    aiCharacter = AiCharacters.characters.firstWhere(
      (character) => character.id == receiver.id.toString().trim(),
      orElse: () => null as AiCharacters,
    );

    if (aiCharacter != null) {
      _initializeSpeechRecognition();
      _startActivityTimer(); // Start the activity timer
    } else {
      print("Normal User");
    }
  }

  @override
  void dispose() {
    _stopListening(); // Ensure listening is stopped
    _cancelSpeaking(); // Ensure speaking is stopped
    _activityTimer?.cancel(); // Cancel the timer
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
      setState(() {});
    }
  }

  void _stopListening() {
    if (_speechToText.isListening) {
      _speechToText.stop();
      if (mounted) {
        setState(() {});
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
    if (!mounted) return; // Check if the widget is still mounted
    _stopListening();
    String responseText = await _getLLMResponse(text);
    chatHistory.add({"role": "assistant", "content": responseText});
    await _speak(responseText);
  }

  Future<String> _getLLMResponse(String prompt) async {
    if (_llm == null) {
      _llm = LLM(); // Initialize LLM if not already initialized
      chatHistory.add({
        "role": "assistant",
        "content":
            "You are ${receiver.name} ${receiver.lastName} and you are in a voice chat. Respond to the user's questions and comments as ${receiver.name} ${receiver.lastName} would, without explicitly stating that you are ${receiver.name} ${receiver.lastName}. Use very very short sentences."
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
    if (!mounted) return; // Check if the widget is still mounted
    await flutterTts.setLanguage('en-US');
    await flutterTts.setPitch(aiCharacter!.voice['pitch']);
    await flutterTts.setSpeechRate(aiCharacter!.voice['rate']);
    flutterTts.setVoice({
      "name": aiCharacter!.voice['name'],
      "locale": aiCharacter!.voice['locale']
    });
    await flutterTts.speak(text);

    if (mounted) {
      setState(() {
        _isSpeaking = true;
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
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
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
                  Text(
                    '${receiver.name!} ${receiver.lastName!}',
                    style: AppText.voiceCallFont,
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            decoration: BoxDecoration(
              color: AppColors.foreground,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: IconButton(
                    onPressed: () {
                      if (mounted) {
                        _cancelSpeaking();
                        _stopListening();
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.call_end),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
