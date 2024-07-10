import 'package:chatacter/main.dart';
import 'package:chatacter/pages/chat_page.dart';
import 'package:chatacter/pages/chats_page.dart';
import 'package:chatacter/pages/edit_profile_page.dart';
import 'package:chatacter/pages/add_friends_page.dart';
import 'package:chatacter/pages/home_page.dart';
import 'package:chatacter/pages/login_page.dart';
import 'package:chatacter/pages/main_page.dart';
import 'package:chatacter/pages/nearby_page.dart';
import 'package:chatacter/pages/otp_page.dart';
import 'package:chatacter/pages/settings_page.dart';
import 'package:chatacter/pages/video_call_page.dart';
import 'package:chatacter/pages/video_page.dart';
import 'package:chatacter/pages/voice_call_page.dart';

class AppRoutes {
  static const checkUserSession = "/";
  static const login = "/login";
  static const home = "/home";
  static const main = "/main";
  static const editProfile = "/edit_profile";
  static const nearby = "/nearby";
  static const otp = "/otp";
  static const chat = "/chat";
  static const chats = "/chats";
  static const friends = "/friends";
  static const video = "/video";
  static const settings = "/settings";
  static const voiceCall = "/voice_call";
  static const videoCall = "/video_call";

  static final pages = {
    checkUserSession: (context) => CheckUserSessions(),
    login: (context) => LoginPage(),
    main: (context) => MainPage(),
    home: (context) => HomePage(),
    editProfile: (context) => EditProfilePage(),
    nearby: (context) => NearbyPage(),
    otp: (context) => OtpPage(),
    chat: (context) => ChatPage(),
    chats: (context) => ChatsPage(),
    friends: (context) => AddFriendsPage(),
    video: (context) => VideoPage(),
    settings: (context) => SettingsPage(),
    voiceCall: (context) => VoiceCallPage(),
    videoCall: (context) => VideoCallPage(),
  };
}
