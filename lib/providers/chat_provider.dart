import 'dart:async';

import 'package:chatacter/config/appwrire.dart';
import 'package:chatacter/models/chat.dart';
import 'package:chatacter/models/message.dart';
import 'package:chatacter/models/user_data.dart';
import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {
  Map<String, List<Chat>> _chats = {};

  //get all user chats
  Map<String, List<Chat>> get getAllChat => _chats;

  Timer? _debounce;

  // to load all current user chats
  void loadChats(String currentUser) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(seconds: 1), () async {
      Map<String, List<Chat>>? loadedChats =
          await currentUserChats(currentUser);

      if (loadedChats != null) {
        _chats = loadedChats;

        _chats.forEach((key, value) {
          // sorting in descending timestamp
          value.sort(
              (a, b) => a.message.timestamp.compareTo(b.message.timestamp));
        });
        print("chats updated in provider");

        notifyListeners();
      }
    });
  }

  //To add a message to page
  void addMessage(Message message, String currentUser, List<UserData> users) {
    try {
      if (message.sender == currentUser) {
        if (_chats[message.receiver] == null) {
          _chats[message.receiver] = [];
        }
        _chats[message.receiver]!.add(Chat(message: message, users: users));
      } else {
        if (_chats[message.sender] == null) {
          _chats[message.sender] = [];
        }
        _chats[message.receiver]!.add(Chat(message: message, users: users));
      }
      notifyListeners();
    } catch (e) {
      print('Error on adding message: $e');
    }
  }

  //Delete message from chat
  void deleteMessage(Message message, String currentUser) async {
    try {
      //user is deleting a message
      if (message.sender == currentUser) {
        _chats[message.receiver]!
            .removeWhere((element) => element.message == message);
        if (message.isImage == true) {
          deleteImageFromBucket(oldImage: message.message);
          print('Image deleted from bucket');
        }
        deleteCurrentUserChat(chatId: message.id!);
      } else {
        //current user is receiver
        _chats[message.sender]!
            .removeWhere((element) => element.message == message);
        print('Message deleted!');
      }
      notifyListeners();
    } catch (e) {
      print('Error on deleting a chat message: $e');
    }
  }

  // clear all chats
  void clearChats() {
    _chats = {};
    notifyListeners();
  }
}
