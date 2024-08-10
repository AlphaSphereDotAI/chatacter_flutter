import 'package:chatacter/config/app_animations.dart';
import 'package:chatacter/models/user_data.dart';

class AiCharacters extends UserData {
  String silentVideo;
  String talkingVideo;
  Map<String, dynamic> voice;

  AiCharacters({
    required this.silentVideo,
    required this.talkingVideo,
    required this.voice,
    String? name,
    String? lastName,
    DateTime? birthday,
    String? location,
    String? gender,
    required String phone,
    required String id,
    String? profilePicture,
    String? deviceToken,
    bool? isOnline,
  }) : super(
          name: name,
          lastName: lastName,
          birthday: birthday,
          location: location,
          gender: gender,
          phone: phone,
          id: id,
          profilePicture: profilePicture,
          deviceToken: deviceToken,
          isOnline: isOnline,
        );

  // List of predefined AiCharacters
  static List<AiCharacters> characters = [
    AiCharacters(
      id: 'd552fc97e0a34e3aa36e',
      silentVideo: AppAnimations.albertSilent,
      talkingVideo: AppAnimations.albertTalking,
      voice: {
        'name': 'en-us-x-iom-local',
        'locale': 'en-US',
        'pitch': 1.1,
        'rate': 0.4,
      },
      name: 'Albert',
      lastName: 'Einstein',
      phone: '+12222222222222',
    ),
    AiCharacters(
      silentVideo: 'appAnimation.napoleonSilent',
      talkingVideo: 'appAnimation.napoleonTalking',
      voice: {
        'name': 'en-us-x-sfg#male_1-local',
        'locale': 'en-US',
      },
      name: 'Napoleon',
      lastName: 'Bonaparte',
      phone: '123456789',
      id: 'dc57f5a807524d09ba6d',
    ),
    // Add more characters here
  ];
}
